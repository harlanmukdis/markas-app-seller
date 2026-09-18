part of 'warehouse_cubit.dart';

sealed class WarehouseState {
  const WarehouseState();
}

final class WarehouseInProgress extends WarehouseState {
  const WarehouseInProgress();
}

final class WarehouseNoStore extends WarehouseState {
  const WarehouseNoStore();
}

final class WarehouseFailure extends WarehouseState {
  const WarehouseFailure(this.error);

  final DataError error;
}

final class WarehouseLoaded extends WarehouseState {
  const WarehouseLoaded(this.warehouses, {this.isBusy = false});

  final List<Warehouse> warehouses;
  final bool isBusy;

  bool get isEmpty => warehouses.isEmpty;

  /// Where stock lands unless something says otherwise. Null only if the store
  /// has no warehouses at all — the server always marks the first one.
  Warehouse? get defaultWarehouse =>
      warehouses.where((warehouse) => warehouse.isDefault).firstOrNull;

  /// A transfer needs somewhere to send stock to, so the action is only
  /// offered once there are two.
  bool get canTransfer => warehouses.length > 1;

  WarehouseLoaded copyWith({List<Warehouse>? warehouses, bool? isBusy}) =>
      WarehouseLoaded(
        warehouses ?? this.warehouses,
        isBusy: isBusy ?? this.isBusy,
      );
}
