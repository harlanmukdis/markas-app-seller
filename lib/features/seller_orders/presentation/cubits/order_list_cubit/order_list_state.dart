part of 'order_list_cubit.dart';

sealed class OrderListState {
  const OrderListState();
}

final class OrderListInProgress extends OrderListState {
  const OrderListInProgress();
}

final class OrderListNoStore extends OrderListState {
  const OrderListNoStore();
}

final class OrderListFailure extends OrderListState {
  const OrderListFailure(this.error);

  final DataError error;
}

final class OrderListLoaded extends OrderListState {
  const OrderListLoaded({required this.orders, required this.filter});

  final List<Order> orders;
  final OrderFilter filter;

  bool get isEmpty => orders.isEmpty;
}

/// What the seller is looking at.
///
/// The server filters on one exact status, so anything broader is several
/// requests stitched together. `needsAction` is the one that matters daily —
/// the three states where the order is waiting on the seller and nobody else.
enum OrderFilter {
  needsAction('Perlu tindakan', <String>[
    OrderStatus.paid,
    OrderStatus.processed,
    OrderStatus.packed,
  ]),
  awaitingPayment('Belum dibayar', <String>[OrderStatus.pending]),
  shipped('Dikirim', <String>[OrderStatus.shipped, OrderStatus.delivered]),
  refund('Refund', <String>[
    OrderStatus.refundRequested,
    OrderStatus.refundApproved,
    OrderStatus.refundRejected,
  ]),
  done('Selesai', <String>[OrderStatus.completed, OrderStatus.cancelled]);

  const OrderFilter(this.label, this.statuses);

  final String label;

  /// The exact statuses this filter asks the server for, one request each.
  final List<String> statuses;
}
