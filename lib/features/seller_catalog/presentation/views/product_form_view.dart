import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data_state.dart';
import '../../../../core/domain/model/catalog/category.dart';
import '../../../../core/domain/model/catalog/product.dart';
import '../../../../core/domain/model/catalog/product_variant.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../seller_home/presentation/views/widgets/section_card.dart';
import '../cubits/product_form_cubit/product_form_cubit.dart';
import 'widgets/product_card.dart';
import 'widgets/variant_sheet.dart';

/// Creates a product, or edits one that exists.
///
/// [productId] null means create. The two modes differ more than usual here:
/// category and type can only be set at creation, and variants and publishing
/// only exist once the product does.
class ProductFormView extends StatelessWidget {
  const ProductFormView({super.key, this.productId});

  final int? productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductFormCubit>(
      create: (_) => ProductFormCubit(productId: productId)..load(),
      child: _ProductFormBody(productId: productId),
    );
  }
}

class _ProductFormBody extends StatefulWidget {
  const _ProductFormBody({this.productId});

  final int? productId;

  @override
  State<_ProductFormBody> createState() => _ProductFormBodyState();
}

class _ProductFormBodyState extends State<_ProductFormBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _compareAtController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  int? _categoryId;
  String _type = ProductType.physical;

  /// Set once from the loaded product, so a rebuild mid-edit does not overwrite
  /// what is being typed.
  bool _prefilled = false;

  bool get _isEditing => widget.productId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _compareAtController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _prefill(Product product) {
    if (_prefilled) return;
    _prefilled = true;
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _priceController.text = product.basePrice.toString();
    _compareAtController.text = product.compareAtPrice?.toString() ?? '';
    _weightController.text = product.weightGrams?.toString() ?? '';
    _type = product.productType;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final categoryId = _categoryId;
    if (!_isEditing && categoryId == null) {
      showErrorSnackBar(
        context,
        const DataError(
          code: 'VALIDATION_LOCAL',
          message: 'Kategori wajib dipilih.',
        ),
      );
      return;
    }

    final description = _descriptionController.text.trim();
    final (error, id) = await ProductFormCubit.get(context).save(
      name: _nameController.text.trim(),
      categoryId: categoryId ?? 0,
      basePrice: parseRupiahInput(_priceController.text) ?? 0,
      compareAtPrice: parseRupiahInput(_compareAtController.text),
      productType: _type,
      description: description.isEmpty ? null : description,
      weightGrams: int.tryParse(_weightController.text.trim()),
    );

    if (!mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }

    showSuccessSnackBar(
      context,
      _isEditing
          ? 'Perubahan tersimpan.'
          : 'Produk dibuat sebagai draf. Terbitkan kalau sudah siap dijual.',
    );
    if (!_isEditing && id != null) Navigator.of(context).pop();
  }

  Future<void> _setStatus(String status) async {
    final error = await ProductFormCubit.get(context).setStatus(status);
    if (!mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    showSuccessSnackBar(
      context,
      status == ProductStatus.active ? 'Produk terbit.' : 'Produk nonaktif.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        _isEditing ? 'Ubah produk' : 'Produk baru',
      ),
      body: SafeArea(
        child: BlocBuilder<ProductFormCubit, ProductFormState>(
          builder: (context, state) => switch (state) {
            ProductFormInProgress() => const LoadingIndicatorView(),
            ProductFormFailure(:final error) => ErrorStateView(
                error: error,
                onRetry: () => ProductFormCubit.get(context).load(),
              ),
            ProductFormReady() => _form(context, state),
          },
        ),
      ),
    );
  }

  Widget _form(BuildContext context, ProductFormReady state) {
    final product = state.product;
    if (product != null) _prefill(product);

    final options = state.categoryOptions;

    return SingleChildScrollView(
      padding: 20.pa,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (product != null) ...<Widget>[
                  _StatusBar(
                    product: product,
                    isBusy: state.isSaving,
                    onPublish: () => _setStatus(ProductStatus.active),
                    onUnpublish: () => _setStatus(ProductStatus.inactive),
                  ),
                  16.sbh,
                ],
                CustomTextFormField(
                  controller: _nameController,
                  labelText: 'Nama produk',
                  textInputAction: TextInputAction.next,
                  validator: Validators.required('Nama produk'),
                ),
                16.sbh,
                if (_isEditing)
                  _ReadOnlyRow(
                    label: 'Kategori & jenis',
                    value: '${ProductType.label(product?.productType)} '
                        '(tidak bisa diubah setelah dibuat)',
                  )
                else ...<Widget>[
                  AppDropdownField<int>(
                    label: 'Kategori',
                    value: _categoryId,
                    hint: 'Pilih kategori',
                    items: options.map((option) => option.id).toList(),
                    itemLabel: (id) => _labelFor(options, id),
                    onChanged: (value) => setState(() => _categoryId = value),
                    validator: (value) =>
                        value == null ? 'Kategori wajib dipilih' : null,
                  ),
                  16.sbh,
                  AppDropdownField<String>(
                    label: 'Jenis produk',
                    value: _type,
                    items: ProductType.all,
                    itemLabel: ProductType.label,
                    onChanged: (value) => setState(
                      () => _type = value ?? ProductType.physical,
                    ),
                  ),
                ],
                16.sbh,
                CustomTextFormField(
                  controller: _priceController,
                  labelText: 'Harga (Rp)',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: Validators.positiveAmount('Harga'),
                ),
                16.sbh,
                CustomTextFormField(
                  controller: _compareAtController,
                  labelText: 'Harga coret (opsional)',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: Validators.optionalAmount,
                ),
                16.sbh,
                CustomTextFormField(
                  controller: _weightController,
                  labelText: 'Berat (gram)',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: _type == ProductType.physical
                      ? Validators.positiveAmount('Berat')
                      : Validators.optional,
                ),
                16.sbh,
                CustomTextFormField(
                  controller: _descriptionController,
                  labelText: 'Deskripsi (opsional)',
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  validator: Validators.optional,
                ),
                24.sbh,
                FilledButton(
                  onPressed: state.isSaving ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: state.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kWhiteColor,
                          ),
                        )
                      : Text(_isEditing ? 'Simpan perubahan' : 'Buat produk'),
                ),
                if (product != null) ...<Widget>[
                  24.sbh,
                  _VariantSection(product: product, isBusy: state.isSaving),
                ],
                32.sbh,
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _labelFor(List<CategoryOption> options, int id) {
    for (final option in options) {
      if (option.id == id) return option.label;
    }
    return '#$id';
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.product,
    required this.isBusy,
    required this.onPublish,
    required this.onUnpublish,
  });

  final Product product;
  final bool isBusy;
  final VoidCallback onPublish;
  final VoidCallback onUnpublish;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text('Status', style: AppStyles.styleMedium14(context)),
              ),
              ProductStatusPill(status: product.status),
            ],
          ),
          8.sbh,
          Text(
            product.isActive
                ? 'Produk terlihat pembeli.'
                : 'Produk belum terlihat pembeli.',
            style: AppStyles.styleRegular12(context)
                .copyWith(color: kLightThirdColor),
          ),
          if (product.stock != null) ...<Widget>[
            4.sbh,
            Text(
              'Stok tersedia: ${product.stock}',
              style: AppStyles.styleRegular12(context)
                  .copyWith(color: kLightThirdColor),
            ),
          ],
          8.sbh,
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: product.isActive
                ? TextButton(
                    onPressed: isBusy ? null : onUnpublish,
                    child: const Text('Nonaktifkan'),
                  )
                : FilledButton.tonal(
                    onPressed: isBusy ? null : onPublish,
                    child: const Text('Terbitkan'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppStyles.styleMedium14(context)),
        4.sbh,
        Text(
          value,
          style: AppStyles.styleRegular12(context)
              .copyWith(color: kLightThirdColor),
        ),
      ],
    );
  }
}

/// Stock lives on variants, never on the product, so this is where an inventory
/// screen will eventually hang off.
class _VariantSection extends StatelessWidget {
  const _VariantSection({required this.product, required this.isBusy});

  final Product product;
  final bool isBusy;

  Future<void> _add(BuildContext context) async {
    final cubit = ProductFormCubit.get(context);
    final result = await showVariantSheet(context);
    if (result == null || !context.mounted) return;

    final error = await cubit.addVariant(
      sku: result.sku,
      price: result.price,
      options: result.options,
      weightGrams: result.weightGrams,
    );
    if (!context.mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    showSuccessSnackBar(context, 'Varian ditambahkan.');
  }

  @override
  Widget build(BuildContext context) {
    // The generated default first: it is the one stock actually lands on for a
    // product with no real options, so hiding it would hide the thing being
    // stocked.
    final ordered = <ProductVariant>[
      ...product.variants.where((variant) => variant.isGenerated),
      ...product.authoredVariants,
    ];

    return SectionCard(
      title: 'Varian',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Stok selalu menempel ke varian, bukan ke produk. Server sudah '
            'membuat satu varian bawaan saat produk dibuat.',
            style: AppStyles.styleRegular12(context)
                .copyWith(color: kLightThirdColor),
          ),
          12.sbh,
          for (final variant in ordered)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          variant.sku,
                          style: AppStyles.styleRegular14(context),
                        ),
                        if (variant.optionsLabel.isNotEmpty)
                          Text(
                            variant.optionsLabel,
                            style: AppStyles.styleRegular10(context)
                                .copyWith(color: kLightThirdColor),
                          )
                        else
                          Text(
                            'Varian bawaan',
                            style: AppStyles.styleRegular10(context)
                                .copyWith(color: kLightThirdColor),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    formatRupiah(variant.price),
                    style: AppStyles.styleMedium14(context),
                  ),
                  if (variant.stock != null) ...<Widget>[
                    12.sbw,
                    Text(
                      '${variant.stock}',
                      style: AppStyles.styleRegular12(context)
                          .copyWith(color: kLightThirdColor),
                    ),
                  ],
                ],
              ),
            ),
          8.sbh,
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: isBusy ? null : () => _add(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah varian'),
            ),
          ),
        ],
      ),
    );
  }
}
