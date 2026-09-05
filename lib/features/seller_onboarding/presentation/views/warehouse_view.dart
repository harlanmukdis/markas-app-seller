import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/model/seller/warehouse.dart';
import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/warehouse_cubit/warehouse_cubit.dart';

/// Not a gate, but a hard requirement: without at least one warehouse a buyer's
/// checkout fails with `409 NO_WAREHOUSE` even when all four gates are green.
class WarehouseView extends StatelessWidget {
  const WarehouseView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WarehouseCubit>(
      create: (_) => WarehouseCubit()..load(),
      child: const _WarehouseBody(),
    );
  }
}

class _WarehouseBody extends StatefulWidget {
  const _WarehouseBody();

  @override
  State<_WarehouseBody> createState() => _WarehouseBodyState();
}

class _WarehouseBodyState extends State<_WarehouseBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await WarehouseCubit.get(context).create(
      name: _nameController.text.trim(),
      addressId: int.tryParse(_addressIdController.text.trim()),
    );

    if (!mounted) return;

    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }

    _nameController.clear();
    _addressIdController.clear();
    showSuccessSnackBar(context, 'Gudang ditambahkan.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Gudang'),
      body: SafeArea(
        child: BlocBuilder<WarehouseCubit, WarehouseState>(
          builder: (context, state) {
            return switch (state) {
              WarehouseLoadInProgress() => const LoadingIndicatorView(),
              WarehouseLoadFailure(:final error) => ErrorStateView(
                  error: error,
                  onRetry: () => WarehouseCubit.get(context).load(),
                ),
              WarehouseLoadSuccess() => _content(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WarehouseLoadSuccess state) {
    return SingleChildScrollView(
      padding: 20.pa,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (state.warehouses.isEmpty)
                Container(
                  padding: 16.pa,
                  decoration: BoxDecoration(
                    color: kWarningColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.warehouse_outlined,
                          size: 18, color: kWarningColor),
                      8.sbw,
                      Expanded(
                        child: Text(
                          'Toko wajib punya minimal satu gudang. Tanpa gudang, '
                          'checkout pembeli gagal dengan 409 NO_WAREHOUSE '
                          'walaupun keempat gerbang sudah lolos.',
                          style: AppStyles.styleRegular12(context),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...state.warehouses.map(
                  (warehouse) => _WarehouseRow(warehouse: warehouse),
                ),
              28.sbh,
              Text('Tambah gudang',
                  style: AppStyles.styleSemiBold16(context)),
              16.sbh,
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Nama gudang',
                        style: AppStyles.styleMedium14(context)),
                    8.sbh,
                    CustomTextFormField(
                      controller: _nameController,
                      hintText: 'Gudang Utama',
                      filled: true,
                      validator: Validators.required('Nama gudang'),
                    ),
                    16.sbh,
                    Text('ID alamat (opsional)',
                        style: AppStyles.styleMedium14(context)),
                    8.sbh,
                    CustomTextFormField(
                      controller: _addressIdController,
                      hintText: 'Kosongkan',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      filled: true,
                      onSubmitted: (_) => _submit(),
                      // Optional on the backend, so an empty box is valid.
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) return null;
                        if (int.tryParse(trimmed) == null) {
                          return 'ID alamat harus berupa angka';
                        }
                        if (int.parse(trimmed) <= 0) {
                          return 'ID alamat harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                    6.sbh,
                    // The field used to suggest "5", which sent people
                    // straight into a foreign-key violation: the id must match
                    // an existing address, and `GET /addresses` is empty on
                    // this backend. The failure surfaces as an HTTP 500 with
                    // an HTML error page rather than a validation error.
                    Text(
                      'Biarkan kosong kecuali alamat dengan ID tersebut '
                      'benar-benar ada. ID yang tidak terdaftar membuat server '
                      'membalas error 500, bukan pesan validasi.',
                      style: AppStyles.styleRegular10(context)
                          .copyWith(color: kWarningColor),
                    ),
                    24.sbh,
                    CustomButton(
                      onPressed: state.isBusy ? null : _submit,
                      child: state.isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kWhiteColor,
                              ),
                            )
                          : const Text('Tambah gudang'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarehouseRow extends StatelessWidget {
  const _WarehouseRow({required this.warehouse});

  final Warehouse warehouse;

  @override
  Widget build(BuildContext context) {
    final isDark = isAppDarkMode();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: 16.pa,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : kBorderColor),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.warehouse_outlined, size: 20),
          12.sbw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(warehouse.name,
                    style: AppStyles.styleSemiBold14(context)),
                4.sbh,
                Text(
                  'ID ${warehouse.id}'
                  '${warehouse.addressId == null ? '' : ' • alamat ${warehouse.addressId}'}',
                  style: AppStyles.styleRegular12(context)
                      .copyWith(color: kLightThirdColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
