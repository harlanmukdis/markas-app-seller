import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data_state.dart';
import '../../../../core/domain/model/order/order_model.dart';
import '../../../../core/domain/model/shipment/shipment.dart';
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
import '../../../seller_home/presentation/views/widgets/section_card.dart';
import '../cubits/sub_order_detail_cubit/sub_order_detail_cubit.dart';
import 'widgets/deadline_chip.dart';

class SubOrderDetailView extends StatelessWidget {
  const SubOrderDetailView({super.key, required this.subOrderId});

  final int subOrderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubOrderDetailCubit>(
      create: (_) => SubOrderDetailCubit(subOrderId)..load(),
      child: const _SubOrderDetailBody(),
    );
  }
}

class _SubOrderDetailBody extends StatelessWidget {
  const _SubOrderDetailBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Detail Pesanan'),
      body: SafeArea(
        child: BlocBuilder<SubOrderDetailCubit, SubOrderDetailState>(
          builder: (context, state) => switch (state) {
            SubOrderDetailLoadInProgress() => const LoadingIndicatorView(),
            SubOrderDetailLoadFailure(:final error) => ErrorStateView(
                error: error,
                onRetry: () => SubOrderDetailCubit.get(context).load(),
              ),
            SubOrderDetailLoadSuccess() => _Content(state: state),
          },
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final SubOrderDetailLoadSuccess state;

  @override
  Widget build(BuildContext context) {
    final subOrder = state.subOrder;
    final deadline = subOrder.activeDeadline;

    return ListView(
      padding: 20.pa,
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SectionCard(
                  title: subOrder.subOrderNo ?? 'Sub-pesanan ${subOrder.id}',
                  trailing: Text(
                    SubOrderStatus.label(subOrder.status),
                    style: AppStyles.styleMedium12(context)
                        .copyWith(color: kLightThirdColor),
                  ),
                  child: Column(
                    children: <Widget>[
                      ...subOrder.items.map(
                        (item) => StatRow(
                          label: '${item.qtyLabel} × '
                              '${item.itemNameSnapshot ?? 'Item'}'
                              '${state.remainingFor(item) > 0 ? '' : ' (terkirim)'}',
                          value: formatRupiah(item.lineSubtotal),
                        ),
                      ),
                      const Divider(height: 20),
                      StatRow(
                        label: 'Subtotal',
                        value: formatRupiah(subOrder.subtotal),
                      ),
                      StatRow(
                        label: 'Ongkir (100% milik toko)',
                        value: formatRupiah(subOrder.shippingTotal),
                        valueColor: kSuccessColor,
                      ),
                      StatRow(
                        label: 'Total',
                        value: formatRupiah(subOrder.total),
                        emphasis: true,
                      ),
                    ],
                  ),
                ),
                if (deadline != null) ...<Widget>[
                  12.sbh,
                  DeadlineChip(
                    deadline: deadline,
                    label: subOrder.awaitingConfirmation
                        ? 'Batas konfirmasi'
                        : 'Batas serah ke armada',
                    consequence: 'auto-batal, skor −3',
                  ),
                ],
                12.sbh,

                if (subOrder.canMarkReady)
                  SectionCard(
                    accent: kWarningColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Tandai siap kirim dulu',
                          style: AppStyles.styleSemiBold14(context),
                        ),
                        4.sbh,
                        Text(
                          'Pengiriman hanya bisa dibuat setelah sub-pesanan '
                          'berstatus BERJALAN.',
                          style: AppStyles.styleRegular12(context)
                              .copyWith(color: kLightThirdColor),
                        ),
                        12.sbh,
                        CustomButton(
                          height: 42,
                          elevation: 0,
                          borderRadius: BorderRadius.circular(12),
                          onPressed: state.isBusy
                              ? null
                              : () async {
                                  final error = await SubOrderDetailCubit.get(
                                    context,
                                  ).readyToShip();
                                  if (!context.mounted) return;
                                  if (error != null) {
                                    return showErrorSnackBar(context, error);
                                  }
                                  showSuccessSnackBar(
                                    context,
                                    'Sub-pesanan berjalan.',
                                  );
                                },
                          child: const Text('Siap kirim'),
                        ),
                      ],
                    ),
                  ),

                if (subOrder.canCreateShipment && state.hasUnshippedItems) ...[
                  12.sbh,
                  _CreateShipmentCard(state: state),
                ],

                12.sbh,
                Text('Pengiriman', style: AppStyles.styleSemiBold16(context)),
                8.sbh,
                if (state.shipments.isEmpty)
                  Text(
                    'Belum ada pengiriman. Uang cair per pengiriman, jadi '
                    'mengirim bertahap berarti menerima uang bertahap.',
                    style: AppStyles.styleRegular12(context)
                        .copyWith(color: kLightThirdColor),
                  )
                else
                  ...state.shipments.map(
                    (shipment) => _ShipmentCard(
                      shipment: shipment,
                      isBusy: state.isBusy,
                    ),
                  ),
                24.sbh,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateShipmentCard extends StatefulWidget {
  const _CreateShipmentCard({required this.state});

  final SubOrderDetailLoadSuccess state;

  @override
  State<_CreateShipmentCard> createState() => _CreateShipmentCardState();
}

class _CreateShipmentCardState extends State<_CreateShipmentCard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _costController = TextEditingController();
  final Map<int, TextEditingController> _qtyControllers =
      <int, TextEditingController>{};

  String _shippingMethod = ShippingMethod.armadaToko;

  @override
  void initState() {
    super.initState();
    for (final item in widget.state.subOrder.items) {
      _qtyControllers[item.id] = TextEditingController(
        text: widget.state.remainingFor(item).round().toString(),
      );
    }
    _costController.text =
        widget.state.subOrder.shippingTotal.toString();
  }

  @override
  void dispose() {
    _costController.dispose();
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final lines = <ShipmentLine>[];
    for (final item in widget.state.subOrder.items) {
      final qty = double.tryParse(
            _qtyControllers[item.id]?.text.trim() ?? '',
          ) ??
          0;
      if (qty > 0) lines.add(ShipmentLine(subOrderItemId: item.id, qty: qty));
    }

    if (lines.isEmpty) {
      return showErrorSnackBar(
        context,
        const DataError(
          code: DataErrorCode.validationError,
          message: 'Isi minimal satu item dengan jumlah lebih dari 0.',
        ),
      );
    }

    final error = await SubOrderDetailCubit.get(context).createShipment(
      shippingMethod: _shippingMethod,
      items: lines,
      shippingCost: parseRupiahInput(_costController.text),
    );

    if (!mounted) return;
    if (error != null) return showErrorSnackBar(context, error);
    showSuccessSnackBar(context, 'Pengiriman dibuat.');
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Buat pengiriman',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Boleh sebagian — sisa item bisa dikirim menyusul, dan setiap '
              'pengiriman cair sendiri-sendiri.',
              style: AppStyles.styleRegular10(context)
                  .copyWith(color: kLightThirdColor),
            ),
            12.sbh,
            ...widget.state.subOrder.items.map((item) {
              final remaining = widget.state.remainingFor(item);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${item.itemNameSnapshot ?? 'Item'}\n'
                        'sisa ${remaining.round()} dari ${item.qtyLabel}',
                        style: AppStyles.styleRegular12(context),
                      ),
                    ),
                    8.sbw,
                    Expanded(
                      flex: 2,
                      child: CustomTextFormField(
                        controller: _qtyControllers[item.id],
                        keyboardType: TextInputType.number,
                        filled: true,
                        hintText: '0',
                        validator: (value) {
                          final qty =
                              double.tryParse(value?.trim() ?? '') ?? 0;
                          if (qty < 0) return 'Tidak boleh negatif';
                          if (qty > remaining) {
                            return 'Maks ${remaining.round()}';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
            8.sbh,
            AppDropdownField<String>(
              label: 'Metode kirim',
              value: _shippingMethod,
              items: ShippingMethod.all,
              itemLabel: ShippingMethod.label,
              helperText: 'Barang berbahaya diblokir dari kurir 3PL.',
              onChanged: (method) => setState(
                () => _shippingMethod = method ?? ShippingMethod.armadaToko,
              ),
            ),
            16.sbh,
            Text('Ongkir', style: AppStyles.styleMedium14(context)),
            8.sbh,
            CustomTextFormField(
              controller: _costController,
              keyboardType: TextInputType.number,
              filled: true,
              hintText: '750000',
              validator: Validators.optionalAmount,
            ),
            4.sbh,
            Text(
              'Checkout pembeli memakai tarif termurah toko sebagai estimasi, '
              'jadi angka di sini yang mengoreksinya.',
              style: AppStyles.styleRegular10(context)
                  .copyWith(color: kLightThirdColor),
            ),
            16.sbh,
            CustomButton(
              height: 44,
              elevation: 0,
              borderRadius: BorderRadius.circular(12),
              onPressed: widget.state.isBusy ? null : _submit,
              child: widget.state.isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: kWhiteColor,
                      ),
                    )
                  : const Text('Buat pengiriman'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  const _ShipmentCard({required this.shipment, required this.isBusy});

  final Shipment shipment;
  final bool isBusy;

  Future<void> _run(
    BuildContext context,
    Future<DataError?> Function() action,
    String successMessage,
  ) async {
    final error = await action();
    if (!context.mounted) return;
    if (error != null) return showErrorSnackBar(context, error);
    showSuccessSnackBar(context, successMessage);
  }

  Future<void> _recordPod(BuildContext context) async {
    final result = await showDialog<_PodInput>(
      context: context,
      builder: (dialogContext) => const _PodDialog(),
    );
    if (result == null || !context.mounted) return;

    await _run(
      context,
      () => SubOrderDetailCubit.get(context).recordPod(
        shipment.id,
        photoUrl: result.photoUrl,
        receiverName: result.receiverName,
      ),
      'Bukti terima tersimpan. Pengiriman sampai.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = SubOrderDetailCubit.get(context);

    return SectionCard(
      title: 'Pengiriman #${shipment.id}',
      trailing: Text(
        ShipmentStatus.label(shipment.status),
        style: AppStyles.styleMedium12(context)
            .copyWith(color: kLightThirdColor),
      ),
      padding: 16.pa,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (shipment.suratJalanNo != null)
            StatRow(label: 'Surat jalan', value: shipment.suratJalanNo!),
          StatRow(
            label: 'Metode',
            value: ShippingMethod.label(shipment.shippingMethod),
          ),
          StatRow(label: 'Ongkir', value: formatRupiah(shipment.shippingCost)),
          if (shipment.handlingClassSnapshot != null)
            StatRow(
              label: 'Kelas penanganan',
              value: HandlingClass.label(shipment.handlingClassSnapshot),
            ),
          if (shipment.holdReleaseAt != null)
            StatRow(
              label: 'Dana cair',
              value: formatDateTime(shipment.holdReleaseAt),
            ),
          if (shipment.deliveryAttemptCount > 0)
            StatRow(
              label: 'Percobaan kirim',
              value: '${shipment.deliveryAttemptCount} dari 3',
              valueColor: kWarningColor,
            ),
          12.sbh,
          if (isBusy)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                if (shipment.canProcess)
                  _SmallButton(
                    label: 'Proses',
                    onPressed: () => _run(
                      context,
                      () => cubit.processShipment(shipment.id),
                      'Pengiriman diproses.',
                    ),
                  ),
                if (shipment.canShip)
                  _SmallButton(
                    label: 'Kirim',
                    onPressed: () => _run(
                      context,
                      () => cubit.shipShipment(shipment.id),
                      'Dikirim. Stok terpotong dan surat jalan terbit.',
                    ),
                  ),
                if (shipment.canRecordPod)
                  _SmallButton(
                    label: 'Bukti terima',
                    onPressed: () => _recordPod(context),
                  ),
                if (shipment.canFailDelivery)
                  _SmallButton(
                    label: 'Gagal kirim',
                    color: kErrorColor,
                    onPressed: () => _run(
                      context,
                      () => cubit.failDelivery(shipment.id),
                      'Percobaan kirim dicatat.',
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.onPressed,
    this.color,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent =
        color ?? (isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor);
    return CustomButton(
      width: 140,
      height: 38,
      elevation: 0,
      backColor: accent,
      borderRadius: BorderRadius.circular(10),
      onPressed: onPressed,
      child: Text(
        label,
        style: AppStyles.styleMedium12(context).copyWith(color: kWhiteColor),
      ),
    );
  }
}

class _PodInput {
  const _PodInput({required this.photoUrl, required this.receiverName});

  final String photoUrl;
  final String receiverName;
}

/// POD is mandatory before a delivery counts as arrived (SHP-08), so both
/// fields are required. The photo is a URL because this API never receives
/// files — the app must upload it elsewhere first.
class _PodDialog extends StatefulWidget {
  const _PodDialog();

  @override
  State<_PodDialog> createState() => _PodDialogState();
}

class _PodDialogState extends State<_PodDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _photoController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();

  @override
  void dispose() {
    _photoController.dispose();
    _receiverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: isAppDarkMode() ? kDarkColor : kWhiteColor,
      title: Text('Bukti terima', style: AppStyles.styleSemiBold16(context)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Foto dan nama penerima wajib. Tanpa bukti terima, pengiriman '
              'tidak boleh dinyatakan sampai.',
              style: AppStyles.styleRegular12(context)
                  .copyWith(color: kLightThirdColor),
            ),
            16.sbh,
            CustomTextFormField(
              controller: _photoController,
              hintText: 'https://storage.contoh/pod.jpg',
              filled: true,
              validator: Validators.fileUrl,
            ),
            12.sbh,
            CustomTextFormField(
              controller: _receiverController,
              hintText: 'Nama penerima',
              filled: true,
              validator: Validators.required('Nama penerima'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              _PodInput(
                photoUrl: _photoController.text.trim(),
                receiverName: _receiverController.text.trim(),
              ),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
