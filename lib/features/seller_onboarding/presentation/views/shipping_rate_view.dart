import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data_state.dart';
import '../../../../core/domain/model/enums.dart';
import '../../../../core/domain/model/shipping/fleet_type.dart';
import '../../../../core/domain/model/shipping/shipping_rate.dart';
import '../../../../core/domain/model/shipping/zone.dart';
import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/shipping_rate_cubit/shipping_rate_cubit.dart';

/// Gate 3, and the only gate a store can clear entirely on its own in one
/// sitting. The platform fixes the shape of the form; the store sets the
/// numbers.
class ShippingRateView extends StatelessWidget {
  const ShippingRateView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShippingRateCubit>(
      create: (_) => ShippingRateCubit()..load(),
      child: const _ShippingRateBody(),
    );
  }
}

class _ShippingRateBody extends StatefulWidget {
  const _ShippingRateBody();

  @override
  State<_ShippingRateBody> createState() => _ShippingRateBodyState();
}

class _ShippingRateBodyState extends State<_ShippingRateBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _baseRateController = TextEditingController();
  final TextEditingController _zoneIdController = TextEditingController();
  final TextEditingController _kuliController = TextEditingController();
  final TextEditingController _lantaiController = TextEditingController();
  final TextEditingController _aksesController = TextEditingController();

  int? _zoneId;
  String _fleetTypeCode = FleetTypeCode.cdd;
  String _mode = ShippingRateMode.simple;

  @override
  void dispose() {
    _baseRateController.dispose();
    _zoneIdController.dispose();
    _kuliController.dispose();
    _lantaiController.dispose();
    _aksesController.dispose();
    super.dispose();
  }

  Future<void> _submit(ShippingRateLoadSuccess state) async {
    if (!_formKey.currentState!.validate()) return;

    // When the zone list could not be fetched the picker is replaced by a plain
    // id field, so the value comes from whichever input is on screen.
    final zoneId = state.referenceDataError == null
        ? _zoneId
        : int.tryParse(_zoneIdController.text.trim());

    if (zoneId == null) {
      showErrorSnackBar(
        context,
        const DataError(
          code: DataErrorCode.validationError,
          message: 'Pilih zona terlebih dahulu.',
        ),
      );
      return;
    }

    final error = await ShippingRateCubit.get(context).create(
      zoneId: zoneId,
      fleetTypeCode: _fleetTypeCode,
      baseRate: parseRupiahInput(_baseRateController.text) ?? 0,
      mode: _mode,
      kuliBongkarFee: parseRupiahInput(_kuliController.text),
      lantaiAtasFee: parseRupiahInput(_lantaiController.text),
      aksesSulitFee: parseRupiahInput(_aksesController.text),
    );

    if (!mounted) return;

    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }

    _baseRateController.clear();
    _kuliController.clear();
    _lantaiController.clear();
    _aksesController.clear();
    showSuccessSnackBar(
      context,
      'Tarif tersimpan. Menambah tarif pertama membuka gerbang 3.',
    );
  }

  Future<void> _delete(ShippingRate rate) async {
    final error = await ShippingRateCubit.get(context).delete(rate.id);
    if (!mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    showSuccessSnackBar(context, 'Tarif dihapus.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Tarif Ongkir'),
      body: SafeArea(
        child: BlocBuilder<ShippingRateCubit, ShippingRateState>(
          builder: (context, state) {
            return switch (state) {
              ShippingRateLoadInProgress() => const LoadingIndicatorView(),
              ShippingRateLoadFailure(:final error) => ErrorStateView(
                  error: error,
                  onRetry: () => ShippingRateCubit.get(context).load(),
                ),
              ShippingRateLoadSuccess() => _content(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, ShippingRateLoadSuccess state) {
    return SingleChildScrollView(
      padding: 20.pa,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DeclaredCostNotice(),
              20.sbh,
              Text('Tarif terdaftar',
                  style: AppStyles.styleSemiBold16(context)),
              12.sbh,
              if (state.rates.isEmpty)
                Text(
                  'Belum ada tarif. Menambahkan minimal satu zona membuka '
                  'gerbang aktivasi ketiga.',
                  style: AppStyles.styleRegular12(context)
                      .copyWith(color: kLightThirdColor),
                )
              else
                ...state.rates.map(
                  (rate) => _RateRow(
                    rate: rate,
                    zoneName: state.zoneNameFor(rate.zoneId),
                    onDelete: state.isBusy ? null : () => _delete(rate),
                  ),
                ),
              28.sbh,
              Text('Tambah / ubah tarif',
                  style: AppStyles.styleSemiBold16(context)),
              4.sbh,
              Text(
                'Tersimpan per kombinasi zona dan jenis armada. Mengirim ulang '
                'kombinasi yang sama akan menimpa tarif lama.',
                style: AppStyles.styleRegular12(context)
                    .copyWith(color: kLightThirdColor),
              ),
              16.sbh,
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (state.referenceDataError != null) ...<Widget>[
                      _ReferenceDataFallbackNotice(
                        code: state.referenceDataError!.code,
                      ),
                      12.sbh,
                      Text('ID zona',
                          style: AppStyles.styleMedium14(context)),
                      8.sbh,
                      CustomTextFormField(
                        controller: _zoneIdController,
                        hintText: '12',
                        keyboardType: TextInputType.number,
                        filled: true,
                        validator: Validators.positiveAmount('ID zona'),
                      ),
                    ] else
                      AppDropdownField<Zone>(
                        label: 'Zona',
                        hint: 'Pilih zona',
                        value: _selectedZone(state),
                        items: state.selectableZones,
                        itemLabel: state.zonePathLabel,
                        onChanged: (zone) =>
                            setState(() => _zoneId = zone?.id),
                        validator: (zone) =>
                            zone == null ? 'Zona wajib dipilih' : null,
                      ),
                    16.sbh,
                    AppDropdownField<String>(
                      label: 'Jenis armada',
                      value: _fleetTypeCode,
                      items: _fleetCodes(state),
                      itemLabel: (code) => _fleetLabel(state.fleetTypes, code),
                      onChanged: (code) => setState(
                        () => _fleetTypeCode = code ?? FleetTypeCode.cdd,
                      ),
                    ),
                    16.sbh,
                    AppDropdownField<String>(
                      label: 'Mode tarif',
                      value: _mode,
                      items: ShippingRateMode.all,
                      itemLabel: ShippingRateMode.label,
                      onChanged: (mode) => setState(
                        () => _mode = mode ?? ShippingRateMode.simple,
                      ),
                    ),
                    16.sbh,
                    Text('Tarif dasar',
                        style: AppStyles.styleMedium14(context)),
                    8.sbh,
                    CustomTextFormField(
                      controller: _baseRateController,
                      hintText: '750000',
                      keyboardType: TextInputType.number,
                      filled: true,
                      validator: Validators.positiveAmount('Tarif dasar'),
                    ),
                    24.sbh,
                    Text('Biaya tambahan',
                        style: AppStyles.styleSemiBold14(context)),
                    4.sbh,
                    Text(
                      'Kosongkan bila tidak dikenakan. Biaya yang tidak diisi '
                      'di sini tidak boleh ditagih di lokasi.',
                      style: AppStyles.styleRegular10(context)
                          .copyWith(color: kLightThirdColor),
                    ),
                    12.sbh,
                    _SurchargeField(
                      label: 'Kuli bongkar',
                      controller: _kuliController,
                    ),
                    12.sbh,
                    _SurchargeField(
                      label: 'Lantai atas',
                      controller: _lantaiController,
                    ),
                    12.sbh,
                    _SurchargeField(
                      label: 'Akses sulit',
                      controller: _aksesController,
                    ),
                    24.sbh,
                    CustomButton(
                      onPressed:
                          state.isBusy ? null : () => _submit(state),
                      child: state.isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kWhiteColor,
                              ),
                            )
                          : const Text('Simpan tarif'),
                    ),
                    24.sbh,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Zone? _selectedZone(ShippingRateLoadSuccess state) {
    final id = _zoneId;
    if (id == null) return null;
    for (final zone in state.selectableZones) {
      if (zone.id == id) return zone;
    }
    return null;
  }

  /// Falls back to the documented code list when `/fleet-types` is unavailable,
  /// so the form still works.
  List<String> _fleetCodes(ShippingRateLoadSuccess state) {
    if (state.fleetTypes.isEmpty) return FleetTypeCode.all;
    return state.fleetTypes
        .map((fleetType) => fleetType.code)
        .toList(growable: false);
  }

  String _fleetLabel(List<FleetType> fleetTypes, String code) {
    for (final fleetType in fleetTypes) {
      if (fleetType.code == code) return fleetType.displayLabel;
    }
    return code;
  }
}

/// The platform's central promise to buyers, and the rule most likely to cost a
/// store money if it is not understood before tariffs are set.
class _DeclaredCostNotice extends StatelessWidget {
  const _DeclaredCostNotice();

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
          const Icon(Icons.price_check_rounded,
              size: 18, color: kWarningColor),
          8.sbw,
          Expanded(
            child: Text(
              'Semua biaya wajib muncul sebelum pembeli membayar. Biaya yang '
              'tidak dideklarasikan di sini dilarang ditagih di lokasi — '
              'melanggar berarti biayanya ditanggung toko dan skor turun.',
              style: AppStyles.styleRegular12(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceDataFallbackNotice extends StatelessWidget {
  const _ReferenceDataFallbackNotice({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 12.pa,
      decoration: BoxDecoration(
        color: kErrorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Daftar zona/armada gagal dimuat ($code). Masukkan ID zona secara '
        'manual, atau muat ulang halaman ini.',
        style: AppStyles.styleRegular12(context),
      ),
    );
  }
}

class _SurchargeField extends StatelessWidget {
  const _SurchargeField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(label, style: AppStyles.styleRegular14(context)),
        ),
        Expanded(
          flex: 3,
          child: CustomTextFormField(
            controller: controller,
            hintText: '0',
            keyboardType: TextInputType.number,
            filled: true,
            validator: Validators.optionalAmount,
          ),
        ),
      ],
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({
    required this.rate,
    required this.zoneName,
    required this.onDelete,
  });

  final ShippingRate rate;
  final String zoneName;
  final VoidCallback? onDelete;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${rate.zoneName ?? zoneName} • ${rate.fleetTypeCode}',
                  style: AppStyles.styleSemiBold14(context),
                ),
                4.sbh,
                Text(
                  formatRupiah(rate.baseRate),
                  style: AppStyles.styleMedium14(context),
                ),
                if (rate.totalSurcharge > 0) ...<Widget>[
                  4.sbh,
                  Text(
                    _surchargeSummary(rate),
                    style: AppStyles.styleRegular12(context)
                        .copyWith(color: kLightThirdColor),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Hapus tarif',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded,
                color: kDeleteColor),
          ),
        ],
      ),
    );
  }

  String _surchargeSummary(ShippingRate rate) {
    final parts = <String>[];
    if (rate.kuliBongkarFee > 0) {
      parts.add('kuli ${formatRupiah(rate.kuliBongkarFee)}');
    }
    if (rate.lantaiAtasFee > 0) {
      parts.add('lantai atas ${formatRupiah(rate.lantaiAtasFee)}');
    }
    if (rate.aksesSulitFee > 0) {
      parts.add('akses sulit ${formatRupiah(rate.aksesSulitFee)}');
    }
    return parts.join(' • ');
  }
}
