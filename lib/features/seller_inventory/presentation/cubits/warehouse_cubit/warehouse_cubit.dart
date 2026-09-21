import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/inventory/warehouse.dart';
import '../../../../../core/domain/model/location/master_location.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/inventory_repository.dart';
import '../../../../../core/domain/repositories/location_repository.dart';
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
  final LocationRepository _locations = injector<LocationRepository>();
  final AuthRepository _auth = injector<AuthRepository>();

  /// Master data for the address fields, fetched once. Both lists are small —
  /// eleven provinces and fifteen cities in the current seed — and change
  /// rarely, so the whole city list is held rather than re-queried per
  /// province.
  List<MasterProvince>? _provinces;
  List<MasterCity>? _cities;

  /// Empty when the master data cannot be read, which the form treats as "fall
  /// back to free text" rather than as an error: the columns behind these are
  /// still nullable and the text ones were kept.
  Future<List<MasterProvince>> provinces() async {
    final cached = _provinces;
    if (cached != null) return cached;

    final result = await _locations.getProvinces();
    final list = switch (result) {
      DataSuccess<List<MasterProvince>>(:final value) => value,
      _ => const <MasterProvince>[],
    };
    _provinces = list;
    return list;
  }

  Future<List<MasterCity>> citiesOf(int provinceId) async {
    final cached = _cities;
    if (cached != null) {
      return cached
          .where((city) => city.provinceId == provinceId)
          .toList(growable: false);
    }

    final result = await _locations.getCities();
    final list = switch (result) {
      DataSuccess<List<MasterCity>>(:final value) => value,
      _ => const <MasterCity>[],
    };
    _cities = list;
    return list
        .where((city) => city.provinceId == provinceId)
        .toList(growable: false);
  }

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
    int? cityId,
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
      cityId: cityId,
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
    int? cityId,
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
      cityId: cityId,
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
