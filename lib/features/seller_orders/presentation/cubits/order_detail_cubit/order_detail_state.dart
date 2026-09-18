part of 'order_detail_cubit.dart';

sealed class OrderDetailState {
  const OrderDetailState();
}

final class OrderDetailInProgress extends OrderDetailState {
  const OrderDetailInProgress();
}

final class OrderDetailFailure extends OrderDetailState {
  const OrderDetailFailure(this.error);

  final DataError error;
}

final class OrderDetailLoaded extends OrderDetailState {
  const OrderDetailLoaded(this.order, {this.shipment, this.isBusy = false});

  final Order order;

  /// Fetched separately and only once the order has shipped; null otherwise.
  final OrderShipment? shipment;

  final bool isBusy;

  OrderDetailLoaded copyWith({
    Order? order,
    OrderShipment? shipment,
    bool? isBusy,
  }) =>
      OrderDetailLoaded(
        order ?? this.order,
        shipment: shipment ?? this.shipment,
        isBusy: isBusy ?? this.isBusy,
      );
}
