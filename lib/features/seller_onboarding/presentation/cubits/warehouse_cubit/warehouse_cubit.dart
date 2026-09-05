import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/seller/warehouse.dart';
import '../../../../../core/domain/repositories/seller_repository.dart';
import '../../../../../di/injector.dart';

part 'warehouse_state.dart';

class WarehouseCubit extends Cubit<WarehouseState> {
  WarehouseCubit() : super(const WarehouseLoadInProgress());

  static WarehouseCubit get(BuildContext context) => BlocProvider.of(context);

  final SellerRepository _sellerRepository = injector<SellerRepository>();

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) emit(const WarehouseLoadInProgress());

    final result = await _sellerRepository.getWarehouses();
    if (isClosed) return;

    switch (result) {
      case DataSuccess<List<Warehouse>>(:final value):
        emit(WarehouseLoadSuccess(warehouses: value));
      case DataEmpty<List<Warehouse>>():
        emit(const WarehouseLoadSuccess(warehouses: <Warehouse>[]));
      case DataFailed<List<Warehouse>>(:final failure):
        emit(WarehouseLoadFailure(failure));
      case DataLoading<List<Warehouse>>():
        break;
    }
  }

  Future<DataError?> create({required String name, int? addressId}) async {
    final current = state;
    if (current is WarehouseLoadSuccess) emit(current.copyWith(isBusy: true));

    final result = await _sellerRepository.createWarehouse(
      name: name,
      addressId: addressId,
    );

    if (isClosed) return null;

    switch (result) {
      case DataSuccess<Warehouse>():
        await load(showSpinner: false);
        return null;
      case DataFailed<Warehouse>(:final failure):
        if (current is WarehouseLoadSuccess) emit(current.copyWith(isBusy: false));
        return failure;
      case DataLoading<Warehouse>():
      case DataEmpty<Warehouse>():
        if (current is WarehouseLoadSuccess) emit(current.copyWith(isBusy: false));
        return const DataError(
          code: DataErrorCode.unexpected,
          message: 'Server tidak mengembalikan data gudang.',
        );
    }
  }
}
