import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/route/app_route_seller.dart';
import '../../../../core/domain/model/order/order_model.dart';
import '../../../../core/function/components.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/orders_cubit/orders_cubit.dart';
import 'widgets/deadline_chip.dart';
import 'widgets/reject_reason_sheet.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrdersCubit>(
      create: (_) => OrdersCubit()..load(),
      child: const _OrdersBody(),
    );
  }
}

class _OrdersBody extends StatelessWidget {
  const _OrdersBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text('Pesanan', style: AppStyles.styleMedium18(context)),
              ),
              IconButton(
                tooltip: 'Muat ulang',
                color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => OrdersCubit.get(context).load(),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<OrdersCubit, OrdersState>(
            builder: (context, state) => switch (state) {
              OrdersLoadInProgress() => const LoadingIndicatorView(),
              OrdersLoadFailure(:final error) => ErrorStateView(
                  error: error,
                  onRetry: () => OrdersCubit.get(context).load(),
                ),
              OrdersLoadSuccess() => _OrdersContent(state: state),
            },
          ),
        ),
      ],
    );
  }
}

class _OrdersContent extends StatelessWidget {
  const _OrdersContent({required this.state});

  final OrdersLoadSuccess state;

  @override
  Widget build(BuildContext context) {
    final visible = state.visible;

    return Column(
      children: <Widget>[
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: 16.psh,
            children: OrderFilter.values
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter == OrderFilter.needsAction &&
                                state.needsActionCount > 0
                            ? '${filter.label} (${state.needsActionCount})'
                            : filter.label,
                      ),
                      selected: state.filter == filter,
                      onSelected: (_) =>
                          OrdersCubit.get(context).setFilter(filter),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => OrdersCubit.get(context).load(showSpinner: false),
            child: visible.isEmpty
                ? ListView(
                    children: <Widget>[
                      SizedBox(height: context.screenHeight * 0.2),
                      EmptyStateView(
                        icon: Icons.receipt_long_outlined,
                        message: state.subOrders.isEmpty
                            ? 'Belum ada pesanan masuk.'
                            : 'Tidak ada pesanan pada filter ini.',
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: 20.pa,
                    itemCount: visible.length,
                    itemBuilder: (context, index) => Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: _SubOrderCard(
                          subOrder: visible[index],
                          isBusy: state.busySubOrderId == visible[index].id,
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

class _SubOrderCard extends StatelessWidget {
  const _SubOrderCard({required this.subOrder, required this.isBusy});

  final SubOrder subOrder;
  final bool isBusy;

  Future<void> _confirm(BuildContext context) async {
    final error = await OrdersCubit.get(context).confirm(subOrder.id);
    if (!context.mounted) return;
    if (error != null) return showErrorSnackBar(context, error);
    showSuccessSnackBar(context, 'Pesanan dikonfirmasi.');
  }

  Future<void> _reject(BuildContext context) async {
    final reason = await showRejectReasonSheet(context);
    if (reason == null || !context.mounted) return;

    final error = await OrdersCubit.get(context).reject(subOrder.id, reason);
    if (!context.mounted) return;
    if (error != null) return showErrorSnackBar(context, error);
    showSuccessSnackBar(context, 'Pesanan ditolak. Skor toko berkurang 2.');
  }

  Future<void> _readyToShip(BuildContext context) async {
    final error = await OrdersCubit.get(context).readyToShip(subOrder.id);
    if (!context.mounted) return;
    if (error != null) return showErrorSnackBar(context, error);
    showSuccessSnackBar(
      context,
      'Sub-pesanan berjalan. Sekarang buat pengiriman.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isAppDarkMode();
    final deadline = subOrder.activeDeadline;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: 16.pa,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: subOrder.awaitingConfirmation
              ? kWarningColor
              : (isDark ? Colors.white12 : kBorderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  subOrder.subOrderNo ?? 'Sub-pesanan ${subOrder.id}',
                  style: AppStyles.styleSemiBold14(context),
                ),
              ),
              8.sbw,
              Text(
                SubOrderStatus.label(subOrder.status),
                style: AppStyles.styleMedium12(context)
                    .copyWith(color: _statusColor(subOrder.status)),
              ),
            ],
          ),
          8.sbh,
          ...subOrder.items.take(3).map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${item.qtyLabel} × ${item.itemNameSnapshot ?? 'Item'}'
                    ' — ${formatRupiah(item.lineSubtotal)}',
                    style: AppStyles.styleRegular12(context)
                        .copyWith(color: kLightThirdColor),
                  ),
                ),
              ),
          if (subOrder.items.length > 3)
            Text(
              '+${subOrder.items.length - 3} item lain',
              style: AppStyles.styleRegular10(context)
                  .copyWith(color: kLightThirdColor),
            ),
          8.sbh,
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Total ${formatRupiah(subOrder.total)}'
                  '  ·  ongkir ${formatRupiah(subOrder.shippingTotal)}',
                  style: AppStyles.styleMedium12(context),
                ),
              ),
            ],
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
          if (subOrder.hasCustomItem) ...<Widget>[
            8.sbh,
            Text(
              'Berisi barang custom — tidak bisa dibatalkan setelah '
              'dikonfirmasi.',
              style: AppStyles.styleRegular10(context)
                  .copyWith(color: kWarningColor),
            ),
          ],
          12.sbh,
          if (isBusy)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            _Actions(
              subOrder: subOrder,
              onConfirm: () => _confirm(context),
              onReject: () => _reject(context),
              onReadyToShip: () => _readyToShip(context),
              onOpenDetail: () => context.push(
                SellerRoutes.subOrderDetail,
                extra: subOrder.id,
              ),
            ),
        ],
      ),
    );
  }

  static Color _statusColor(String? status) => switch (status) {
        SubOrderStatus.menungguKonfirmasi => kWarningColor,
        SubOrderStatus.selesai => kSuccessColor,
        SubOrderStatus.batalToko ||
        SubOrderStatus.batalBuyer ||
        SubOrderStatus.batalSistem ||
        SubOrderStatus.dihentikan =>
          kErrorColor,
        _ => kLightThirdColor,
      };
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.subOrder,
    required this.onConfirm,
    required this.onReject,
    required this.onReadyToShip,
    required this.onOpenDetail,
  });

  final SubOrder subOrder;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onReadyToShip;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        if (subOrder.awaitingConfirmation)
          _ActionButton(label: 'Konfirmasi', onPressed: onConfirm),
        if (subOrder.canReject)
          _ActionButton(
            label: 'Tolak',
            onPressed: onReject,
            color: kErrorColor,
          ),
        if (subOrder.canMarkReady)
          _ActionButton(label: 'Siap kirim', onPressed: onReadyToShip),
        _ActionButton(
          label: subOrder.canCreateShipment ? 'Buat pengiriman' : 'Detail',
          onPressed: onOpenDetail,
          outlined: true,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.color,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final accent = color ??
        (isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor);

    return CustomButton(
      width: 150,
      height: 40,
      elevation: 0,
      onPressed: onPressed,
      backColor: outlined ? Colors.transparent : accent,
      borderColor: outlined ? accent : Colors.transparent,
      txtColor: outlined ? accent : kWhiteColor,
      borderRadius: BorderRadius.circular(12),
      child: Text(label, style: AppStyles.styleMedium12(context).copyWith(
        color: outlined ? accent : kWhiteColor,
      )),
    );
  }
}
