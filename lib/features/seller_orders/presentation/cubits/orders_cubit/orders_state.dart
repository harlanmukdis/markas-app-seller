part of 'orders_cubit.dart';

sealed class OrdersState {
  const OrdersState();
}

final class OrdersLoadInProgress extends OrdersState {
  const OrdersLoadInProgress();
}

final class OrdersLoadSuccess extends OrdersState {
  const OrdersLoadSuccess({
    required this.subOrders,
    this.filter = OrderFilter.all,
    this.busySubOrderId,
  });

  final List<SubOrder> subOrders;
  final OrderFilter filter;

  /// The sub-order currently being acted on, so only its row shows a spinner.
  final int? busySubOrderId;

  List<SubOrder> get visible => switch (filter) {
        OrderFilter.all => subOrders,
        OrderFilter.needsAction => subOrders
            .where((subOrder) =>
                subOrder.awaitingConfirmation ||
                subOrder.isConfirmed ||
                subOrder.isRunning)
            .toList(),
        OrderFilter.awaitingConfirmation =>
          subOrders.where((subOrder) => subOrder.awaitingConfirmation).toList(),
        OrderFilter.running =>
          subOrders.where((subOrder) => subOrder.isRunning).toList(),
        OrderFilter.done => subOrders
            .where((subOrder) => subOrder.status == SubOrderStatus.selesai)
            .toList(),
      };

  int get needsActionCount =>
      subOrders.where((subOrder) => subOrder.awaitingConfirmation).length;

  OrdersLoadSuccess copyWith({
    List<SubOrder>? subOrders,
    OrderFilter? filter,
    int? busySubOrderId,
    bool clearBusy = false,
  }) =>
      OrdersLoadSuccess(
        subOrders: subOrders ?? this.subOrders,
        filter: filter ?? this.filter,
        busySubOrderId: clearBusy ? null : (busySubOrderId ?? this.busySubOrderId),
      );
}

final class OrdersLoadFailure extends OrdersState {
  const OrdersLoadFailure(this.error);

  final DataError error;
}

enum OrderFilter {
  needsAction,
  awaitingConfirmation,
  running,
  done,
  all;

  String get label => switch (this) {
        needsAction => 'Perlu tindakan',
        awaitingConfirmation => 'Menunggu konfirmasi',
        running => 'Berjalan',
        done => 'Selesai',
        all => 'Semua',
      };
}
