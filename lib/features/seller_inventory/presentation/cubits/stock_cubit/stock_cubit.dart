import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/inventory/stock_movement.dart';
import '../../../../../core/domain/model/inventory/warehouse_stock.dart';
import '../../../../../core/domain/repositories/inventory_repository.dart';
import '../../../../../di/injector.dart';

part 'stock_state.dart';

/// One warehouse's stock, and the ledger that explains it.
///
/// Nothing here ever sets a quantity. `warehouse_stocks` is derived from an
/// append-only ledger, so every action is a movement — in, out, or a signed
/// adjustment — and the totals are re-read afterwards rather than computed
/// locally.
class StockCubit extends Cubit<StockState> {
  StockCubit(this.warehouseId) : super(const StockInProgress());

  static StockCubit get(BuildContext context) => BlocProvider.of(context);

  final int warehouseId;

  final InventoryRepository _inventory = injector<InventoryRepository>();

  Future<void> load() async {
    if (isClosed) return;
    emit(const StockInProgress());

    final stocks = await _inventory.getStocks(warehouseId);
    if (isClosed) return;

    if (stocks is DataFailed<List<WarehouseStock>>) {
      emit(StockFailure(stocks.failure));
      return;
    }

    final movements = await _inventory.getMovements(warehouseId);
    if (isClosed) return;

    emit(StockLoaded(
      stocks: switch (stocks) {
        DataSuccess<List<WarehouseStock>>(:final value) => value,
        _ => const <WarehouseStock>[],
      },
      movements: switch (movements) {
        DataSuccess<List<StockMovement>>(:final value) => value,
        _ => const <StockMovement>[],
      },
    ));
  }

  Future<DataError?> stockIn({
    required int productVariantId,
    required int quantity,
    String? notes,
  }) =>
      _write(() => _inventory.stockIn(
            warehouseId,
            productVariantId: productVariantId,
            quantity: quantity,
            notes: notes,
          ));

  /// Refused with `STOCK_INSUFFICIENT` when the amount would eat into stock a
  /// checkout has reserved — which can be less than what "on hand" suggests.
  Future<DataError?> stockOut({
    required int productVariantId,
    required int quantity,
    String? notes,
  }) =>
      _write(() => _inventory.stockOut(
            warehouseId,
            productVariantId: productVariantId,
            quantity: quantity,
            notes: notes,
          ));

  /// [quantityDelta] is a difference: `-2` removes two.
  Future<DataError?> adjust({
    required int productVariantId,
    required int quantityDelta,
    required String reason,
  }) =>
      _write(() => _inventory.adjustStock(
            warehouseId,
            productVariantId: productVariantId,
            quantityDelta: quantityDelta,
            reason: reason,
          ));

  /// Sends stock to another warehouse. The source is debited now; the
  /// destination only receives it when the transfer is completed there.
  Future<DataError?> transferOut({
    required int destinationWarehouseId,
    required int productVariantId,
    required int quantity,
  }) async {
    _setBusy(true);
    final result = await _inventory.createTransfer(
      sourceWarehouseId: warehouseId,
      destinationWarehouseId: destinationWarehouseId,
      productVariantId: productVariantId,
      quantity: quantity,
    );
    if (isClosed) return null;

    if (result is DataFailed<int>) {
      _setBusy(false);
      return result.failure;
    }
    await load();
    return null;
  }

  Future<DataError?> _write(
    Future<DataState<List<WarehouseStock>>> Function() action,
  ) async {
    _setBusy(true);
    final result = await action();
    if (isClosed) return null;

    if (result is DataFailed<List<WarehouseStock>>) {
      _setBusy(false);
      return result.failure;
    }

    // The ledger changed too, so both halves of the screen are stale.
    await load();
    return null;
  }

  void _setBusy(bool isBusy) {
    final current = state;
    if (current is StockLoaded) emit(current.copyWith(isBusy: isBusy));
  }
}
