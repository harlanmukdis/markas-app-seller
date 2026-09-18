import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/inventory/warehouse.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/inventory_repository.dart';
import '../../../../../di/injector.dart';

part 'warehouse_state.dart';

/// The active store's warehouses.
///
/// A store needs at least one before any of its products can hold stock, which
/// makes this the step between "catalogue exists" and "catalogue is sellable".
class WarehouseCubit extends Cubit<WarehouseState> {
  WarehouseCubit() : super(const WarehouseInProgress());

  static WarehouseCubit get(BuildContext context) => BlocProvider.of(context);

  final InventoryRepository _inventory = injector<InventoryRepository>();
  final AuthRepository _auth = injector<AuthRepository>();

  Future<void> load() async {
    if (isClosed) return;

    final storeId = _auth.activeStoreId;
    if (storeId == null) {
      emit(const WarehouseNoStore());
      return;
    }

    emit(const WarehouseInProgress());

    final result = await _inventory.getWarehouses(storeId);
    if (isClosed) return;

    switch (result) {
      case DataSuccess<List<Warehouse>>(:final value):
        emit(WarehouseLoaded(value));
      case DataEmpty<List<Warehouse>>():
        emit(const WarehouseLoaded(<Warehouse>[]));
      case DataFailed<List<Warehouse>>(:final failure):
        emit(WarehouseFailure(failure));
      case DataLoading<List<Warehouse>>():
        break;
    }
  }

  /// Creates a warehouse and returns its id.
  ///
  /// Whether it becomes the store's default is the server's call — the first
  /// one is, later ones are not — so nothing here offers that as a choice.
  Future<(DataError?, int?)> create({
    required String name,
    required String address,
    required String city,
    required String province,
    required String postalCode,
  }) async {
    final storeId = _auth.activeStoreId;
    if (storeId == null) {
      return (
        const DataError(
          code: DataErrorCode.unexpected,
          message: 'Belum ada toko yang dipilih.',
        ),
        null,
      );
    }

    _setBusy(true);
    final result = await _inventory.createWarehouse(
      storeId,
      name: name,
      address: address,
      city: city,
      province: province,
      postalCode: postalCode,
    );
    if (isClosed) return (null, null);

    switch (result) {
      case DataSuccess<int>(:final value):
        await load();
        return (null, value);
      case DataFailed<int>(:final failure):
        _setBusy(false);
        return (failure, null);
      default:
        _setBusy(false);
        return (
          const DataError(
            code: DataErrorCode.unexpected,
            message: 'Server tidak mengembalikan gudang yang dibuat.',
          ),
          null,
        );
    }
  }

  Future<DataError?> update(
    int warehouseId, {
    String? name,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? status,
  }) async {
    _setBusy(true);
    final result = await _inventory.updateWarehouse(
      warehouseId,
      name: name,
      address: address,
      city: city,
      province: province,
      postalCode: postalCode,
      status: status,
    );
    if (isClosed) return null;

    switch (result) {
      case DataSuccess<Warehouse>():
        await load();
        return null;
      case DataFailed<Warehouse>(:final failure):
        _setBusy(false);
        return failure;
      default:
        await load();
        return null;
    }
  }

  void _setBusy(bool isBusy) {
    final current = state;
    if (current is WarehouseLoaded) emit(current.copyWith(isBusy: isBusy));
  }
}
