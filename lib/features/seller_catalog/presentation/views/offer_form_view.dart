import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/route/app_route_seller.dart';
import '../../../../core/data_state.dart';
import '../../../../core/domain/model/catalog/category.dart';
import '../../../../core/domain/model/catalog/offer.dart';
import '../../../../core/domain/model/catalog/sku_master.dart';
import '../../../../core/domain/model/catalog/sku_request.dart';
import '../../../../core/domain/model/shipment/shipment.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../seller_home/presentation/views/widgets/section_card.dart';
import '../cubits/offer_form_cubit/offer_form_cubit.dart';
import 'widgets/photo_editor.dart';
import 'widgets/price_tier_editor.dart';

/// Creates a new offer.
///
/// The whole form is one screen rather than a wizard because the decisions are
/// interdependent — the category decides whether a master SKU is required, and
/// the SKU decides the weight the store cannot change.
class OfferFormView extends StatelessWidget {
  const OfferFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OfferFormCubit>(
      create: (_) => OfferFormCubit()..load(),
      child: const _OfferFormBody(),
    );
  }
}

class _OfferFormBody extends StatefulWidget {
  const _OfferFormBody();

  @override
  State<_OfferFormBody> createState() => _OfferFormBodyState();
}

class _OfferFormBodyState extends State<_OfferFormBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _moqController = TextEditingController(text: '1');
  final TextEditingController _descriptionController = TextEditingController();

  List<OfferPhoto> _photos = <OfferPhoto>[];
  List<PriceTier> _tiers = <PriceTier>[];
  String? _handlingClass;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _moqController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit(OfferFormReady state) async {
    if (!_formKey.currentState!.validate()) return;

    if (state.needsSku && state.sku == null) {
      showErrorSnackBar(
        context,
        const DataError(
          code: DataErrorCode.validationError,
          message: 'Kategori ini wajib pakai SKU master. Cari dan pilih '
              'SKU-nya dulu, atau ajukan SKU baru.',
        ),
      );
      return;
    }

    final cubit = OfferFormCubit.get(context);
    final outcome = await cubit.submit(
      photos: _photos,
      tiers: _tiers,
      minOrderQty: double.tryParse(_moqController.text.trim()),
      handlingClass: _handlingClass,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      freeformName: state.isFreeform ? _nameController.text.trim() : null,
      freeformWeightKg: state.isFreeform
          ? double.tryParse(_weightController.text.trim().replaceAll(',', '.'))
          : null,
      freeformLengthCm: _parseOptional(_lengthController.text),
      freeformWidthCm: _parseOptional(_widthController.text),
      freeformHeightCm: _parseOptional(_heightController.text),
    );

    if (!mounted) return;

    switch (outcome) {
      case OfferCreateFailed(:final error):
        showErrorSnackBar(context, error);
      case OfferCreatedWithoutPrice(:final offerId, :final error):
        // The offer exists and cannot be deleted, so say so rather than let
        // the store retry the whole form and end up with two listings.
        showErrorSnackBar(
          context,
          DataError(
            code: error.code,
            message: 'Produk dibuat, tapi harga gagal disimpan: '
                '${error.message} Atur harga dari halaman produk.',
            details: error.details,
          ),
        );
        _openDetail(offerId);
      case OfferCreated(:final offerId):
        showSuccessSnackBar(context, 'Produk dibuat sebagai draft.');
        _openDetail(offerId);
    }
  }

  void _openDetail(int offerId) {
    context.pushReplacement(SellerRoutes.offerDetail, extra: offerId);
  }

  static double? _parseOptional(String input) {
    final text = input.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Produk baru'),
      body: SafeArea(
        child: BlocBuilder<OfferFormCubit, OfferFormState>(
          builder: (context, state) => switch (state) {
            OfferFormLoadInProgress() => const LoadingIndicatorView(),
            OfferFormLoadFailure(:final error) => ErrorStateView(
                error: error,
                onRetry: () => OfferFormCubit.get(context).load(),
              ),
            OfferFormReady() => _content(context, state),
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, OfferFormReady state) {
    return SingleChildScrollView(
      padding: 20.pa,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _NoDeleteNotice(),
                16.sbh,
                SectionCard(
                  title: 'Kategori',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppDropdownField<Category>(
                        label: 'Kategori produk',
                        value: state.category,
                        items: state.categories,
                        itemLabel: (category) => category.name,
                        hint: 'Pilih kategori',
                        onChanged: (value) =>
                            OfferFormCubit.get(context).selectCategory(value),
                        validator: (value) =>
                            value == null ? 'Pilih kategori' : null,
                      ),
                      if (state.category != null) ...<Widget>[
                        8.sbh,
                        Text(
                          CategoryJalur.label(state.category!.jalur),
                          style: AppStyles.styleRegular12(context)
                              .copyWith(color: kLightThirdColor),
                        ),
                        if (state.category!.isRisky) ...<Widget>[
                          4.sbh,
                          Text(
                            'Kategori berisiko — listing bisa masuk moderasi '
                            'sebelum tayang.',
                            style: AppStyles.styleRegular10(context)
                                .copyWith(color: kWarningColor),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                if (state.needsSku) ...<Widget>[
                  12.sbh,
                  _SkuPicker(state: state),
                ],
                if (state.isFreeform) ...<Widget>[
                  12.sbh,
                  SectionCard(
                    title: 'Produk sendiri',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        CustomTextFormField(
                          controller: _nameController,
                          labelText: 'Nama produk',
                          validator: Validators.required('Nama produk'),
                        ),
                        12.sbh,
                        CustomTextFormField(
                          controller: _weightController,
                          labelText: 'Berat per unit (kg)',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            final parsed = _parseOptional(value ?? '');
                            if (parsed == null || parsed <= 0) {
                              return 'Isi berat dalam kg';
                            }
                            return null;
                          },
                        ),
                        12.sbh,
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: CustomTextFormField(
                                controller: _lengthController,
                                labelText: 'P (cm)',
                                keyboardType: TextInputType.number,
                                validator: Validators.optional,
                              ),
                            ),
                            8.sbw,
                            Expanded(
                              child: CustomTextFormField(
                                controller: _widthController,
                                labelText: 'L (cm)',
                                keyboardType: TextInputType.number,
                                validator: Validators.optional,
                              ),
                            ),
                            8.sbw,
                            Expanded(
                              child: CustomTextFormField(
                                controller: _heightController,
                                labelText: 'T (cm)',
                                keyboardType: TextInputType.number,
                                validator: Validators.optional,
                              ),
                            ),
                          ],
                        ),
                        8.sbh,
                        Text(
                          'Berat dipakai untuk memilih armada dan menghitung '
                          'ongkir. Salah isi berarti sopir yang menanggung '
                          'selisihnya di lokasi.',
                          style: AppStyles.styleRegular10(context)
                              .copyWith(color: kLightThirdColor),
                        ),
                      ],
                    ),
                  ),
                ],
                12.sbh,
                SectionCard(
                  title: 'Foto',
                  child: PhotoEditor(
                    photos: _photos,
                    onChanged: (photos) => setState(() => _photos = photos),
                  ),
                ),
                12.sbh,
                SectionCard(
                  title: 'Harga',
                  child: PriceTierEditor(
                    tiers: _tiers,
                    onChanged: (tiers) => setState(() => _tiers = tiers),
                  ),
                ),
                12.sbh,
                SectionCard(
                  title: 'Detail penjualan',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      CustomTextFormField(
                        controller: _moqController,
                        labelText: 'Minimal pembelian',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Minimal 1';
                          }
                          return null;
                        },
                      ),
                      12.sbh,
                      AppDropdownField<String>(
                        label: 'Kelas penanganan',
                        value: _handlingClass,
                        items: HandlingClass.all,
                        itemLabel: HandlingClass.label,
                        hint: 'Ikuti bawaan SKU',
                        helperText: 'Menentukan armada dan biaya bongkar.',
                        onChanged: (value) =>
                            setState(() => _handlingClass = value),
                      ),
                      12.sbh,
                      CustomTextFormField(
                        controller: _descriptionController,
                        labelText: 'Deskripsi (opsional)',
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        validator: Validators.optional,
                      ),
                    ],
                  ),
                ),
                24.sbh,
                FilledButton(
                  onPressed: state.isSubmitting ? null : () => _submit(state),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kWhiteColor,
                          ),
                        )
                      : const Text('Buat produk'),
                ),
                12.sbh,
                Text(
                  'Produk dibuat sebagai draft. Tayangkan dari halaman produk '
                  'setelah keempat syarat terpenuhi.',
                  textAlign: TextAlign.center,
                  style: AppStyles.styleRegular10(context)
                      .copyWith(color: kLightThirdColor),
                ),
                32.sbh,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The API has no endpoint that deletes an offer, and `PUT` will not set a
/// status either — a mistake here is permanent, so it is worth one line.
class _NoDeleteNotice extends StatelessWidget {
  const _NoDeleteNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 16.pa,
      decoration: BoxDecoration(
        color: kWarningColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline_rounded,
              size: 18, color: kWarningColor),
          8.sbw,
          Expanded(
            child: Text(
              'Produk yang sudah dibuat tidak bisa dihapus, hanya '
              'dinonaktifkan. Pastikan kategori dan SKU-nya benar sebelum '
              'menyimpan.',
              style: AppStyles.styleRegular12(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkuPicker extends StatefulWidget {
  const _SkuPicker({required this.state});

  final OfferFormReady state;

  @override
  State<_SkuPicker> createState() => _SkuPickerState();
}

class _SkuPickerState extends State<_SkuPicker> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _requestNewSku() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _SkuRequestDialog(
        cubit: OfferFormCubit.get(context),
        initialName: _queryController.text.trim(),
      ),
    );
    if (created != true || !mounted) return;
    showSuccessSnackBar(
      context,
      'Permintaan SKU dikirim. Tim katalog menjawab dalam 1×24 jam kerja.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final selected = state.sku;

    return SectionCard(
      title: 'SKU master',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (selected != null) ...<Widget>[
            _SelectedSku(
              sku: selected,
              onClear: () => OfferFormCubit.get(context).selectSku(null),
            ),
            12.sbh,
          ],
          CustomTextFormField(
            controller: _queryController,
            labelText: 'Cari SKU',
            hintText: 'semen, pipa pvc, …',
            textInputAction: TextInputAction.search,
            validator: Validators.optional,
            onSubmitted: (value) =>
                OfferFormCubit.get(context).searchSku(value),
          ),
          8.sbh,
          OutlinedButton.icon(
            onPressed: state.isSearchingSku
                ? null
                : () => OfferFormCubit.get(context)
                    .searchSku(_queryController.text),
            icon: state.isSearchingSku
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search_rounded, size: 18),
            label: Text(state.isSearchingSku ? 'Mencari…' : 'Cari'),
          ),
          if (state.skuResults.isNotEmpty) ...<Widget>[
            12.sbh,
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: state.skuResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sku = state.skuResults[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      sku.name,
                      style: AppStyles.styleRegular12(context),
                    ),
                    subtitle: Text(
                      '${sku.baseUnit ?? '-'} · '
                      '${sku.weightKg?.toStringAsFixed(2) ?? '-'} kg',
                      style: AppStyles.styleRegular10(context)
                          .copyWith(color: kLightThirdColor),
                    ),
                    trailing: selected?.id == sku.id
                        ? const Icon(Icons.check_circle,
                            size: 18, color: kSuccessColor)
                        : null,
                    onTap: () => OfferFormCubit.get(context).selectSku(sku),
                  );
                },
              ),
            ),
          ] else if (state.hasSearched && !state.isSearchingSku) ...<Widget>[
            12.sbh,
            Text(
              'Tidak ada SKU yang cocok.',
              style: AppStyles.styleRegular12(context)
                  .copyWith(color: kWarningColor),
            ),
          ],
          8.sbh,
          _RequestSkuButton(onPressed: _requestNewSku),
        ],
      ),
    );
  }
}

class _RequestSkuButton extends StatelessWidget {
  const _RequestSkuButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
        label: const Text('SKU tidak ada — ajukan ke tim katalog'),
      ),
    );
  }
}

class _SelectedSku extends StatelessWidget {
  const _SelectedSku({required this.sku, required this.onClear});

  final SkuMaster sku;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 12.pa,
      decoration: BoxDecoration(
        color: kSuccessColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(sku.name, style: AppStyles.styleMedium14(context)),
                4.sbh,
                Text(
                  'Satuan ${sku.baseUnit ?? '-'} · '
                  '${sku.weightKg?.toStringAsFixed(2) ?? '-'} kg · '
                  '${sku.dimensionsLabel}',
                  style: AppStyles.styleRegular10(context)
                      .copyWith(color: kLightThirdColor),
                ),
                4.sbh,
                Text(
                  'Berat dan dimensi dikunci platform — toko tidak bisa '
                  'mengubahnya.',
                  style: AppStyles.styleRegular10(context)
                      .copyWith(color: kLightThirdColor),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ganti SKU',
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

/// `POST /sku-requests` answers HTTP 200 when it created **nothing**, so this
/// dialog branches on `similar_found` and shows the lookalikes before letting
/// the store force the request through.
class _SkuRequestDialog extends StatefulWidget {
  const _SkuRequestDialog({required this.cubit, required this.initialName});

  final OfferFormCubit cubit;
  final String initialName;

  @override
  State<_SkuRequestDialog> createState() => _SkuRequestDialogState();
}

class _SkuRequestDialogState extends State<_SkuRequestDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initialName);
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  bool _isSending = false;
  List<SkuMaster>? _similar;
  String? _hint;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _send({bool force = false}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    final result = await widget.cubit.requestSku(
      name: _nameController.text.trim(),
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      weightKg: double.tryParse(
        _weightController.text.trim().replaceAll(',', '.'),
      ),
      force: force,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    switch (result) {
      case DataFailed<SkuRequestResult>(:final failure):
        showErrorSnackBar(context, failure);
      case DataSuccess<SkuRequestResult>(:final value):
        switch (value) {
          case SkuRequestSimilarFound(:final similar, :final hint):
            setState(() {
              _similar = similar;
              _hint = hint;
            });
          case SkuRequestCreated():
            Navigator.of(context).pop(true);
        }
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final similar = _similar;

    return AlertDialog(
      title: const Text('Ajukan SKU baru'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Nama produk usulan',
                validator: Validators.required('Nama produk'),
              ),
              12.sbh,
              CustomTextFormField(
                controller: _brandController,
                labelText: 'Merek (opsional)',
                validator: Validators.optional,
              ),
              12.sbh,
              CustomTextFormField(
                controller: _weightController,
                labelText: 'Berat per unit (kg, opsional)',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.optional,
              ),
              if (similar != null) ...<Widget>[
                16.sbh,
                Text(
                  'Belum ada yang dibuat — server menemukan SKU mirip. Pakai '
                  'salah satunya, atau kirim paksa kalau memang berbeda.',
                  style: AppStyles.styleRegular12(context)
                      .copyWith(color: kWarningColor),
                ),
                if (_hint != null) ...<Widget>[
                  4.sbh,
                  Text(
                    _hint!,
                    style: AppStyles.styleRegular10(context)
                        .copyWith(color: kLightThirdColor),
                  ),
                ],
                8.sbh,
                for (final sku in similar)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      sku.name,
                      style: AppStyles.styleRegular12(context),
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        widget.cubit.selectSku(sku);
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Pakai ini'),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isSending ? null : () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isSending ? null : () => _send(force: similar != null),
          child: Text(
            _isSending
                ? 'Mengirim…'
                : similar != null
                    ? 'Tetap ajukan'
                    : 'Ajukan',
          ),
        ),
      ],
    );
  }
}
