part of 'warehouse_cubit.dart';

sealed class WarehouseState {
  const WarehouseState();
}

final class WarehouseLoadInProgress extends WarehouseState {
  const WarehouseLoadInProgress();
}

final class WarehouseLoadSuccess extends WarehouseState {
  const WarehouseLoadSuccess({required this.warehouses, this.isBusy = false});

  final List<Warehouse> warehouses;
  final bool isBusy;

  WarehouseLoadSuccess copyWith({
    List<Warehouse>? warehouses,
    bool? isBusy,
  }) =>
      WarehouseLoadSuccess(
        warehouses: warehouses ?? this.warehouses,
        isBusy: isBusy ?? this.isBusy,
      );
}

final class WarehouseLoadFailure extends WarehouseState {
  const WarehouseLoadFailure(this.error);

  final DataError error;
}
