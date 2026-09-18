import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data_state.dart';
import '../../../../core/domain/model/order/order.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../seller_home/presentation/views/widgets/section_card.dart';
import '../cubits/order_detail_cubit/order_detail_cubit.dart';
import 'widgets/order_status_pill.dart';
import 'widgets/ship_sheet.dart';

/// One order, and everything the seller can do to it.
class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderDetailCubit>(
      create: (_) => OrderDetailCubit(orderId)..load(),
      child: const _OrderDetailBody(),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody();

  Future<void> _run(
    BuildContext context,
    Future<DataError?> Function() action,
    String success,
  ) async {
    final error = await action();
    if (!context.mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    showSuccessSnackBar(context, success);
  }

  Future<void> _ship(BuildContext context, Order order) async {
    final cubit = OrderDetailCubit.get(context);
    final draft = await showShipSheet(
      context,
      suggestedCourierCode: order.courierCode,
    );
    if (draft == null || !context.mounted) return;
    await _run(
      context,
      () => cubit.ship(
        courierCode: draft.courierCode,
        awbNumber: draft.awbNumber,
      ),
      'Pesanan ditandai dikirim.',
    );
  }

  Future<void> _cancel(BuildContext context) async {
    final cubit = OrderDetailCubit.get(context);
    final reason = await _askReason(context);
    if (reason == null || !context.mounted) return;
    await _run(context, () => cubit.cancel(reason), 'Pesanan dibatalkan.');
  }

  Future<String?> _askReason(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan pesanan'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Alasannya tersimpan di riwayat pesanan dan terlihat pembeli. '
                'Pesanan yang sudah dibayar akan dikembalikan ke saldo mereka.',
                style: AppStyles.styleRegular12(dialogContext)
                    .copyWith(color: kLightThirdColor),
              ),
              16.sbh,
              CustomTextFormField(
                controller: controller,
                labelText: 'Alasan',
                validator: Validators.required('Alasan'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tidak jadi'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogContext).pop(controller.text.trim());
            },
            child: const Text('Batalkan pesanan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Detail pesanan'),
      body: SafeArea(
        child: BlocBuilder<OrderDetailCubit, OrderDetailState>(
          builder: (context, state) => switch (state) {
            OrderDetailInProgress() => const LoadingIndicatorView(),
            OrderDetailFailure(:final error) => ErrorStateView(
                error: error,
                onRetry: () => OrderDetailCubit.get(context).load(),
              ),
            OrderDetailLoaded() => _content(context, state),
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, OrderDetailLoaded state) {
    final order = state.order;

    return Column(
      children: <Widget>[
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => OrderDetailCubit.get(context).load(),
            child: ListView(
              padding: 20.pa,
              children: <Widget>[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                order.orderNumber,
                                style: AppStyles.styleSemiBold18(context),
                              ),
                            ),
                            OrderStatusPill(status: order.status),
                          ],
                        ),
                        4.sbh,
                        Text(
                          formatDateTime(order.createdAt),
                          style: AppStyles.styleRegular12(context)
                              .copyWith(color: kLightThirdColor),
                        ),
                        if (order.isAwaitingPayment) ...<Widget>[
                          12.sbh,
                          const _AwaitingPaymentNotice(),
                        ],
                        if (order.refund != null) ...<Widget>[
                          12.sbh,
                          _RefundCard(
                            refund: order.refund!,
                            canResolve: order.canResolveRefund && !state.isBusy,
                            onApprove: () => _run(
                              context,
                              () => OrderDetailCubit.get(context)
                                  .resolveRefund(approve: true),
                              'Refund disetujui.',
                            ),
                            onReject: () => _run(
                              context,
                              () => OrderDetailCubit.get(context)
                                  .resolveRefund(approve: false),
                              'Refund ditolak.',
                            ),
                          ),
                        ],
                        12.sbh,
                        SectionCard(
                          title: 'Barang',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (final item in order.items)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              item.productName,
                                              style: AppStyles.styleRegular14(
                                                  context),
                                            ),
                                            Text(
                                              <String>[
                                                if (item.optionsLabel.isNotEmpty)
                                                  item.optionsLabel,
                                                '${item.quantity} × '
                                                    '${formatRupiah(item.price)}',
                                              ].join(' · '),
                                              style: AppStyles.styleRegular10(
                                                      context)
                                                  .copyWith(
                                                      color: kLightThirdColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        formatRupiah(item.subtotal),
                                        style:
                                            AppStyles.styleMedium14(context),
                                      ),
                                    ],
                                  ),
                                ),
                              const Divider(height: 20),
                              StatRow(
                                label: 'Subtotal',
                                value: formatRupiah(order.subtotal),
                              ),
                              StatRow(
                                label: 'Ongkir',
                                value: formatRupiah(order.shippingCost),
                              ),
                              if (order.discountTotal > 0)
                                StatRow(
                                  label: 'Diskon',
                                  value: '-${formatRupiah(order.discountTotal)}',
                                ),
                              StatRow(
                                label: 'Total',
                                value: formatRupiah(order.grandTotal),
                                emphasis: true,
                              ),
                            ],
                          ),
                        ),
                        12.sbh,
                        SectionCard(
                          title: 'Pengiriman',
                          child: Column(
                            children: <Widget>[
                              StatRow(
                                label: 'Penerima',
                                value: order.recipientName.isEmpty
                                    ? '-'
                                    : order.recipientName,
                              ),
                              StatRow(
                                label: 'Alamat',
                                value: _addressLine(order),
                              ),
                              StatRow(
                                label: 'Kurir',
                                value: <String?>[
                                  order.courierCode?.toUpperCase(),
                                  order.courierService,
                                ].whereType<String>().join(' · ').isEmpty
                                    ? 'Belum dipilih'
                                    : <String?>[
                                        order.courierCode?.toUpperCase(),
                                        order.courierService,
                                      ].whereType<String>().join(' · '),
                              ),
                              StatRow(
                                label: 'Nomor resi',
                                value: order.trackingNumber ?? 'Belum ada',
                              ),
                              if (state.shipment?.status != null)
                                StatRow(
                                  label: 'Status kiriman',
                                  value: state.shipment!.status!,
                                ),
                            ],
                          ),
                        ),
                        if (order.statusHistory.isNotEmpty) ...<Widget>[
                          12.sbh,
                          SectionCard(
                            title: 'Riwayat',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                for (final event in order.statusHistory.reversed)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                OrderStatus.label(
                                                    event.toStatus),
                                                style:
                                                    AppStyles.styleRegular12(
                                                        context),
                                              ),
                                              if (event.notes != null)
                                                Text(
                                                  event.notes!,
                                                  style: AppStyles
                                                          .styleRegular10(
                                                              context)
                                                      .copyWith(
                                                          color:
                                                              kLightThirdColor),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          formatDateTime(event.createdAt),
                                          style:
                                              AppStyles.styleRegular10(context)
                                                  .copyWith(
                                                      color: kLightThirdColor),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        32.sbh,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _ActionBar(state: state, onShip: () => _ship(context, order),
            onCancel: () => _cancel(context)),
      ],
    );
  }

  String _addressLine(Order order) {
    final parts = <String>[
      '${order.shippingAddress['full_address'] ?? ''}',
      '${order.shippingAddress['city'] ?? ''}',
      '${order.shippingAddress['province'] ?? ''}',
      '${order.shippingAddress['postal_code'] ?? ''}',
    ].where((part) => part.trim().isNotEmpty).toList();
    return parts.isEmpty ? '-' : parts.join(', ');
  }
}

/// Only the move that is actually available is offered. The server answers an
/// out-of-turn action with an HTML error page at HTTP 200, so a button shown at
/// the wrong moment cannot fail gracefully.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.state,
    required this.onShip,
    required this.onCancel,
  });

  final OrderDetailLoaded state;
  final VoidCallback onShip;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final order = state.order;
    final busy = state.isBusy;

    final primary = switch (order) {
      Order(canAccept: true) => (
          'Terima pesanan',
          () => OrderDetailCubit.get(context).accept(),
          'Pesanan diterima dan mulai diproses.',
        ),
      Order(canPack: true) => (
          'Tandai sudah dikemas',
          () => OrderDetailCubit.get(context).pack(),
          'Pesanan ditandai siap kirim.',
        ),
      _ => null,
    };

    if (primary == null && !order.canShip && !order.canCancel) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: 20.pa,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: kLightThirdColor.withValues(alpha: 0.2)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Row(
            children: <Widget>[
              if (order.canCancel)
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Batalkan'),
                  ),
                ),
              if (order.canCancel && (primary != null || order.canShip)) 12.sbw,
              if (primary != null)
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: busy
                        ? null
                        : () async {
                            final error = await primary.$2();
                            if (!context.mounted) return;
                            if (error != null) {
                              showErrorSnackBar(context, error);
                              return;
                            }
                            showSuccessSnackBar(context, primary.$3);
                          },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(primary.$1),
                  ),
                ),
              if (order.canShip)
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: busy ? null : onShip,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Serahkan ke kurir'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AwaitingPaymentNotice extends StatelessWidget {
  const _AwaitingPaymentNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 16.pa,
      decoration: BoxDecoration(
        color: kLightThirdColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.schedule_outlined, size: 18, color: kLightThirdColor),
          8.sbw,
          Expanded(
            child: Text(
              'Pembeli belum membayar. Stok sudah ditahan untuk pesanan ini, '
              'tapi belum ada yang perlu Anda kerjakan sampai pembayaran masuk.',
              style: AppStyles.styleRegular12(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _RefundCard extends StatelessWidget {
  const _RefundCard({
    required this.refund,
    required this.canResolve,
    required this.onApprove,
    required this.onReject,
  });

  final OrderRefund refund;
  final bool canResolve;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 16.pa,
      decoration: BoxDecoration(
        color: kWarningColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Pengajuan refund ${formatRupiah(refund.amount)}',
            style: AppStyles.styleMedium14(context),
          ),
          if (refund.reason != null) ...<Widget>[
            4.sbh,
            Text(refund.reason!, style: AppStyles.styleRegular12(context)),
          ],
          if (canResolve) ...<Widget>[
            8.sbh,
            Text(
              'Menyetujui langsung mengembalikan dana ke saldo pembeli.',
              style: AppStyles.styleRegular10(context)
                  .copyWith(color: kLightThirdColor),
            ),
            8.sbh,
            Row(
              children: <Widget>[
                TextButton(onPressed: onReject, child: const Text('Tolak')),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: onApprove,
                  child: const Text('Setujui refund'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
