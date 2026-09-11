import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data_state.dart';
import '../../../../core/domain/model/shipment/shipment.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../seller_home/presentation/views/widgets/section_card.dart';
import '../cubits/pod_cubit/pod_cubit.dart';

/// Proof of delivery — the one screen used away from the shop.
///
/// Until the Driver app exists, the store's own driver records delivery here,
/// standing at the drop-off point. So it is a full screen with large targets
/// rather than a dialog, and the quantity counters work by tapping rather than
/// by typing.
class PodView extends StatelessWidget {
  const PodView({super.key, required this.shipmentId});

  final int shipmentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PodCubit>(
      create: (_) => PodCubit(shipmentId)..load(),
      child: const _PodBody(),
    );
  }
}

class _PodBody extends StatefulWidget {
  const _PodBody();

  @override
  State<_PodBody> createState() => _PodBodyState();
}

class _PodBodyState extends State<_PodBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _photoController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _signatureController = TextEditingController();

  /// Counted quantity per `shipment_item_id`, only for lines the store
  /// actually recounted. An untouched line sends nothing.
  final Map<int, double> _counted = <int, double>{};

  @override
  void dispose() {
    _photoController.dispose();
    _receiverController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _submit(PodReady state) async {
    if (!_formKey.currentState!.validate()) return;

    final signature = _signatureController.text.trim();
    final outcome = await PodCubit.get(context).submit(
      photoUrl: _photoController.text.trim(),
      receiverName: _receiverController.text.trim(),
      signatureUrl: signature.isEmpty ? null : signature,
      podItems: <PodItem>[
        for (final entry in _counted.entries)
          PodItem(shipmentItemId: entry.key, actualQtyReceived: entry.value),
      ],
    );

    if (!mounted) return;
    final error = outcome.error;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }

    Navigator.of(context).pop(true);

    if (outcome.countsDropped) {
      // The delivery is recorded, but the store does not have the evidence it
      // thinks it has. Say so while it can still photograph the pile.
      showErrorSnackBar(
        context,
        const DataError(
          code: 'POD_ITEMS_NOT_STORED',
          message: 'Bukti terima tersimpan, tapi jumlah yang Anda hitung '
              'TIDAK ikut tersimpan di server. Simpan bukti lain (foto, '
              'timbangan) kalau jumlahnya kurang — laporkan ke admin.',
        ),
      );
      return;
    }

    showSuccessSnackBar(
      context,
      outcome.result?.hadToleranceRefund ?? false
          // The payout will not match the order. Say why, so it does not read
          // as an unexplained deduction weeks later.
          ? 'Bukti terima tersimpan. Selisih curah dalam toleransi '
              'dikembalikan otomatis '
              '${formatRupiah(outcome.result!.bulkToleranceRefund)}.'
          : 'Bukti terima tersimpan. Pengiriman dinyatakan sampai.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Bukti terima'),
      body: SafeArea(
        child: BlocBuilder<PodCubit, PodState>(
          builder: (context, state) => switch (state) {
            PodLoadInProgress() => const LoadingIndicatorView(),
            PodLoadFailure(:final error) => ErrorStateView(
                error: error,
                onRetry: () => PodCubit.get(context).load(),
              ),
            PodReady() => _content(context, state),
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, PodReady state) {
    final items = state.shipment.items;

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: 20.pa,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        state.shipment.shipmentNo ??
                            'Pengiriman #${state.shipment.id}',
                        style: AppStyles.styleSemiBold16(context),
                      ),
                      4.sbh,
                      Text(
                        'Tanpa bukti terima, pengiriman tidak bisa dinyatakan '
                        'sampai dan dananya tidak masuk antrean pencairan.',
                        style: AppStyles.styleRegular12(context)
                            .copyWith(color: kLightThirdColor),
                      ),
                      16.sbh,
                      if (items.isNotEmpty) ...<Widget>[
                        SectionCard(
                          title: 'Jumlah diterima',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                'Isi hanya kalau jumlah yang diterima berbeda '
                                'dari yang dikirim. Untuk material curah, '
                                'selisih kecil dikembalikan otomatis dan '
                                'tercatat — itu yang melindungi toko dari '
                                'klaim "kurang kirim".',
                                style: AppStyles.styleRegular10(context)
                                    .copyWith(color: kLightThirdColor),
                              ),
                              12.sbh,
                              for (final item in items)
                                _QtyRow(
                                  label: state.nameFor(item),
                                  unit: state.unitFor(item),
                                  shipped: item.qty,
                                  counted: _counted[item.id],
                                  onChanged: (value) => setState(() {
                                    if (value == null) {
                                      _counted.remove(item.id);
                                    } else {
                                      _counted[item.id] = value;
                                    }
                                  }),
                                ),
                            ],
                          ),
                        ),
                        12.sbh,
                      ],
                      SectionCard(
                        title: 'Penerima',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            CustomTextFormField(
                              controller: _receiverController,
                              labelText: 'Nama penerima',
                              hintText: 'Nama orang yang menerima barang',
                              textInputAction: TextInputAction.next,
                              validator: Validators.required('Nama penerima'),
                            ),
                            12.sbh,
                            CustomTextFormField(
                              controller: _photoController,
                              labelText: 'URL foto barang di lokasi',
                              hintText: 'https://storage.contoh/pod.jpg',
                              keyboardType: TextInputType.url,
                              validator: Validators.fileUrl,
                            ),
                            12.sbh,
                            CustomTextFormField(
                              controller: _signatureController,
                              labelText: 'URL tanda tangan (opsional)',
                              keyboardType: TextInputType.url,
                              validator: Validators.optional,
                            ),
                            8.sbh,
                            Text(
                              'Foto dan tanda tangan dikirim sebagai URL — '
                              'belum ada endpoint unggah berkas di API, jadi '
                              'kamera dan tanda tangan di layar baru bisa '
                              'dipakai setelah aplikasi punya penyimpanan '
                              'sendiri.',
                              style: AppStyles.styleRegular10(context)
                                  .copyWith(color: kWarningColor),
                            ),
                          ],
                        ),
                      ),
                      24.sbh,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Pinned so the driver never has to scroll to finish.
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isSubmitting ? null : () => _submit(state),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kWhiteColor,
                          ),
                        )
                      : Text(
                          'Simpan bukti terima',
                          style: AppStyles.styleMedium16(context)
                              .copyWith(color: kWhiteColor),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One delivery line. Counting happens with +/− buttons because this is used
/// outdoors, one-handed, often with gloves on.
class _QtyRow extends StatelessWidget {
  const _QtyRow({
    required this.label,
    required this.unit,
    required this.shipped,
    required this.counted,
    required this.onChanged,
  });

  final String label;
  final String unit;
  final double shipped;
  final double? counted;
  final ValueChanged<double?> onChanged;

  static String _qty(double value) =>
      value == value.roundToDouble() ? value.round().toString() : '$value';

  @override
  Widget build(BuildContext context) {
    final current = counted ?? shipped;
    final isShort = current < shipped;
    final unitLabel = unit.isEmpty || unit == 'unit' ? '' : ' $unit';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppStyles.styleRegular12(context)),
          4.sbh,
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Dikirim ${_qty(shipped)}$unitLabel',
                  style: AppStyles.styleRegular10(context)
                      .copyWith(color: kLightThirdColor),
                ),
              ),
              _StepButton(
                icon: Icons.remove_rounded,
                onPressed: current <= 0
                    ? null
                    : () => onChanged((current - 1).clamp(0, shipped)),
              ),
              SizedBox(
                width: 72,
                child: Text(
                  '${_qty(current)}$unitLabel',
                  textAlign: TextAlign.center,
                  style: AppStyles.styleSemiBold14(context).copyWith(
                    color: isShort ? kWarningColor : null,
                  ),
                ),
              ),
              _StepButton(
                icon: Icons.add_rounded,
                onPressed:
                    current >= shipped ? null : () => onChanged(current + 1),
              ),
            ],
          ),
          if (counted != null && isShort)
            Text(
              'Kurang ${_qty(shipped - current)}$unitLabel dari yang dikirim.',
              style: AppStyles.styleRegular10(context)
                  .copyWith(color: kWarningColor),
            ),
          if (counted != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => onChanged(null),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Batalkan hitungan'),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      iconSize: 20,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      icon: Icon(icon),
    );
  }
}
