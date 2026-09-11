part of 'pod_cubit.dart';

sealed class PodState {
  const PodState();
}

final class PodLoadInProgress extends PodState {
  const PodLoadInProgress();
}

final class PodLoadFailure extends PodState {
  const PodLoadFailure(this.error);

  final DataError error;
}

final class PodReady extends PodState {
  const PodReady({
    required this.shipment,
    this.itemNames = const <int, String>{},
    this.itemUnits = const <int, String>{},
    this.isSubmitting = false,
  });

  final Shipment shipment;

  /// Product names keyed by `sub_order_item_id`. `GET /shipments/{id}` returns
  /// lines without a name, so they are read from the sub-order.
  final Map<int, String> itemNames;
  final Map<int, String> itemUnits;

  final bool isSubmitting;

  String nameFor(ShipmentItem item) {
    final subOrderItemId = item.subOrderItemId;
    if (subOrderItemId == null) return 'Barang #${item.id}';
    return itemNames[subOrderItemId] ?? 'Barang #$subOrderItemId';
  }

  String unitFor(ShipmentItem item) {
    final subOrderItemId = item.subOrderItemId;
    if (subOrderItemId == null) return '';
    return itemUnits[subOrderItemId] ?? '';
  }

  PodReady copyWith({
    Shipment? shipment,
    Map<int, String>? itemNames,
    Map<int, String>? itemUnits,
    bool? isSubmitting,
  }) =>
      PodReady(
        shipment: shipment ?? this.shipment,
        itemNames: itemNames ?? this.itemNames,
        itemUnits: itemUnits ?? this.itemUnits,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}
