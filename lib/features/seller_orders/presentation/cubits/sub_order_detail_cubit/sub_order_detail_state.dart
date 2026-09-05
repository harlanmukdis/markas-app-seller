part of 'sub_order_detail_cubit.dart';

sealed class SubOrderDetailState {
  const SubOrderDetailState();
}

final class SubOrderDetailLoadInProgress extends SubOrderDetailState {
  const SubOrderDetailLoadInProgress();
}

final class SubOrderDetailLoadSuccess extends SubOrderDetailState {
  const SubOrderDetailLoadSuccess({
    required this.subOrder,
    this.shipments = const <Shipment>[],
    this.isBusy = false,
  });

  final SubOrder subOrder;

  /// Shipments for this sub-order. Kept separate from `subOrder.shipments`
  /// because the sub-order endpoint does not always populate them.
  final List<Shipment> shipments;

  final bool isBusy;

  /// How much of each item is already covered by a shipment, so a partial
  /// shipment form can default to what is left.
  Map<int, double> get shippedQtyByItem {
    final shipped = <int, double>{};
    for (final shipment in shipments) {
      for (final item in shipment.items) {
        final itemId = item.subOrderItemId;
        if (itemId == null) continue;
        shipped[itemId] = (shipped[itemId] ?? 0) + item.qty;
      }
    }
    return shipped;
  }

  double remainingFor(SubOrderItem item) {
    final shipped = shippedQtyByItem[item.id] ?? 0;
    final remaining = item.qty - shipped;
    return remaining < 0 ? 0 : remaining;
  }

  bool get hasUnshippedItems =>
      subOrder.items.any((item) => remainingFor(item) > 0);

  SubOrderDetailLoadSuccess copyWith({
    SubOrder? subOrder,
    List<Shipment>? shipments,
    bool? isBusy,
  }) =>
      SubOrderDetailLoadSuccess(
        subOrder: subOrder ?? this.subOrder,
        shipments: shipments ?? this.shipments,
        isBusy: isBusy ?? this.isBusy,
      );
}

final class SubOrderDetailLoadFailure extends SubOrderDetailState {
  const SubOrderDetailLoadFailure(this.error);

  final DataError error;
}
