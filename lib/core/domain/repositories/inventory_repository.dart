import '../../data_state.dart';
import '../model/inventory/inventory.dart';

abstract class InventoryRepository {
  Future<DataState<StockMovementResult>> stockIn({
    required int offerId,
    required int warehouseId,
    required double qty,
    String? note,
  });

  Future<DataState<StockMovementResult>> adjust({
    required int offerId,
    required int warehouseId,
    required double qtyDelta,
    required String reason,
    String? refDoc,
  });

  Future<DataState<List<InventoryLedgerEntry>>> getLedger(int offerId);

  Future<DataState<StockAvailability>> getAvailable(int offerId);
}
