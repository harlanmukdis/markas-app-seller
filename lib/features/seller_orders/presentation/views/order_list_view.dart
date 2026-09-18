import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/route/app_route_seller.dart';
import '../../../../core/domain/model/order/order.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/order_list_cubit/order_list_cubit.dart';
import 'widgets/order_status_pill.dart';

/// Incoming orders — the store's daily work.
class OrderListView extends StatelessWidget {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderListCubit>(
      create: (_) => OrderListCubit()..load(),
      child: const _OrderListBody(),
    );
  }
}

class _OrderListBody extends StatelessWidget {
  const _OrderListBody();

  Future<void> _open(BuildContext context, Order order) async {
    final cubit = OrderListCubit.get(context);
    await context.push(SellerRoutes.orderDetailPath(order.id));
    // The detail screen acts on its own cubit, so a status may have moved.
    if (cubit.isClosed) return;
    await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Pesanan'),
      body: SafeArea(
        child: BlocBuilder<OrderListCubit, OrderListState>(
          builder: (context, state) => switch (state) {
            OrderListInProgress() => const LoadingIndicatorView(),
            OrderListNoStore() => const EmptyStateView(
                icon: Icons.storefront_outlined,
                message: 'Pilih toko dulu untuk melihat pesanannya.',
              ),
            OrderListFailure(:final error) => ErrorStateView(
                error: error,
                onRetry: () => OrderListCubit.get(context).load(),
              ),
            OrderListLoaded() => _content(context, state),
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, OrderListLoaded state) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: OrderFilter.values.length,
            separatorBuilder: (_, __) => 8.sbw,
            itemBuilder: (context, index) {
              final filter = OrderFilter.values[index];
              return ChoiceChip(
                label: Text(filter.label),
                selected: state.filter == filter,
                onSelected: (_) => OrderListCubit.get(context).setFilter(filter),
              );
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => OrderListCubit.get(context).load(),
            child: state.isEmpty
                ? ListView(
                    children: <Widget>[
                      SizedBox(height: context.screenHeight * 0.15),
                      EmptyStateView(
                        icon: Icons.receipt_long_outlined,
                        message: switch (state.filter) {
                          OrderFilter.needsAction =>
                            'Tidak ada pesanan yang menunggu tindakan. '
                                'Semua sudah tertangani.',
                          _ => 'Tidak ada pesanan berstatus '
                              '"${state.filter.label}".',
                        },
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    itemCount: state.orders.length,
                    separatorBuilder: (_, __) => 12.sbh,
                    itemBuilder: (context, index) {
                      final order = state.orders[index];
                      return _OrderCard(
                        order: order,
                        onTap: () => _open(context, order),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: 16.pa,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kLightThirdColor.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: AppStyles.styleMedium14(context),
                  ),
                ),
                OrderStatusPill(status: order.status),
              ],
            ),
            6.sbh,
            Text(
              <String>[
                if (order.recipientName.isNotEmpty) order.recipientName,
                if (order.shippingCity.isNotEmpty) order.shippingCity,
                formatDate(order.createdAt),
              ].join(' · '),
              style: AppStyles.styleRegular12(context)
                  .copyWith(color: kLightThirdColor),
            ),
            8.sbh,
            Row(
              children: <Widget>[
                Text(
                  formatRupiah(order.grandTotal),
                  style: AppStyles.styleSemiBold16(context),
                ),
                const Spacer(),
                if (order.needsAction)
                  Text(
                    _nextStep(order),
                    style: AppStyles.styleRegular12(context)
                        .copyWith(color: kLightPrimaryColor),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The one thing the seller should do next, named plainly.
  String _nextStep(Order order) {
    if (order.canAccept) return 'Perlu diterima';
    if (order.canPack) return 'Perlu dikemas';
    if (order.canShip) return 'Perlu dikirim';
    if (order.canResolveRefund) return 'Refund menunggu';
    return '';
  }
}
