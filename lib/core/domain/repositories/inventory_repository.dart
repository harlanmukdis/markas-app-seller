import '../../data_state.dart';
import '../model/inventory/stock_movement.dart';
import '../model/inventory/warehouse.dart';
import '../model/inventory/warehouse_stock.dart';

/// Warehouses and the stock ledger.
abstract class InventoryRepository {
  Future<DataState<List<Warehouse>>> getWarehouses(int storeId);

  Future<DataState<Warehouse>> getWarehouse(int warehouseId);

  /// Returns the new warehouse's id. The server, not the caller, decides
  /// whether it becomes the store's default.
  Future<DataState<int>> createWarehouse(
    int storeId, {
    required String name,
    required String address,
    required String city,
    required String province,
    required String postalCode,
  });

  Future<DataState<Warehouse>> updateWarehouse(
    int warehouseId, {
    String? name,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? status,
  });

  Future<DataState<List<WarehouseStock>>> getStocks(int warehouseId);

  Future<DataState<List<StockMovement>>> getMovements(
    int warehouseId, {
    int page,
  });

  /// Each of these writes one ledger row and returns the warehouse's stock as
  /// it stands afterwards — the writes themselves answer with nothing, and a
  /// stock screen is worthless if it shows a number from before the change.
  Future<DataState<List<WarehouseStock>>> stockIn(
    int warehouseId, {
    required int productVariantId,
    required int quantity,
    String? notes,
  });

  Future<DataState<List<WarehouseStock>>> stockOut(
    int warehouseId, {
    required int productVariantId,
    required int quantity,
    String? notes,
  });

  /// [quantityDelta] is a difference, not a new total.
  Future<DataState<List<WarehouseStock>>> adjustStock(
    int warehouseId, {
    required int productVariantId,
    required int quantityDelta,
    required String reason,
  });

  /// Debits the source at once; the destination is credited on completion.
  Future<DataState<int>> createTransfer({
    required int sourceWarehouseId,
    required int destinationWarehouseId,
    required int productVariantId,
    required int quantity,
  });

  Future<DataState<void>> completeTransfer(int transferId);

  Future<DataState<int>> startAudit(int warehouseId);

  Future<DataState<void>> recordAuditCount(
    int auditId, {
    required int productVariantId,
    required int actualQuantity,
  });

  /// Applies every counted variance as an adjustment.
  Future<DataState<void>> completeAudit(int auditId);
}
