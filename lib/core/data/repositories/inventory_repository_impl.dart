import '../../data_state.dart';
import '../../domain/model/inventory/stock_movement.dart';
import '../../domain/model/inventory/warehouse.dart';
import '../../domain/model/inventory/warehouse_stock.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/remote/service/inventory_service.dart';
import 'repository_guard.dart';

class InventoryRepositoryImpl
    with RepositoryGuard
    implements InventoryRepository {
  const InventoryRepositoryImpl(this._service);

  final InventoryService _service;

  @override
  Future<DataState<List<Warehouse>>> getWarehouses(int storeId) =>
      guard(() => _service.getWarehouses(storeId));

  @override
  Future<DataState<Warehouse>> getWarehouse(int warehouseId) =>
      guard(() => _service.getWarehouse(warehouseId));

  @override
  Future<DataState<int>> createWarehouse(
    int storeId, {
    required String name,
    required String address,
    required String city,
    required String province,
    required String postalCode,
  }) =>
      guard(() => _service.createWarehouse(
            storeId,
            name: name,
            address: address,
            city: city,
            province: province,
            postalCode: postalCode,
          ));

  @override
  Future<DataState<Warehouse>> updateWarehouse(
    int warehouseId, {
    String? name,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? status,
  }) =>
      guard(() => _service.updateWarehouse(
            warehouseId,
            name: name,
            address: address,
            city: city,
            province: province,
            postalCode: postalCode,
            status: status,
          ));

  @override
  Future<DataState<List<WarehouseStock>>> getStocks(int warehouseId) =>
      guard(() => _service.getStocks(warehouseId));

  @override
  Future<DataState<List<StockMovement>>> getMovements(
    int warehouseId, {
    int page = 1,
  }) =>
      guard(() => _service.getMovements(warehouseId, page: page));

  @override
  Future<DataState<List<WarehouseStock>>> stockIn(
    int warehouseId, {
    required int productVariantId,
    required int quantity,
    String? notes,
  }) =>
      guard(() async {
        await _service.stockIn(
          warehouseId,
          productVariantId: productVariantId,
          quantity: quantity,
          notes: notes,
        );
        return _service.getStocks(warehouseId);
      });

  @override
  Future<DataState<List<WarehouseStock>>> stockOut(
    int warehouseId, {
    required int productVariantId,
    required int quantity,
    String? notes,
  }) =>
      guard(() async {
        await _service.stockOut(
          warehouseId,
          productVariantId: productVariantId,
          quantity: quantity,
          notes: notes,
        );
        return _service.getStocks(warehouseId);
      });

  @override
  Future<DataState<List<WarehouseStock>>> adjustStock(
    int warehouseId, {
    required int productVariantId,
    required int quantityDelta,
    required String reason,
  }) =>
      guard(() async {
        await _service.adjustStock(
          warehouseId: warehouseId,
          productVariantId: productVariantId,
          quantityDelta: quantityDelta,
          reason: reason,
        );
        return _service.getStocks(warehouseId);
      });

  @override
  Future<DataState<int>> createTransfer({
    required int sourceWarehouseId,
    required int destinationWarehouseId,
    required int productVariantId,
    required int quantity,
  }) =>
      guard(() => _service.createTransfer(
            sourceWarehouseId: sourceWarehouseId,
            destinationWarehouseId: destinationWarehouseId,
            productVariantId: productVariantId,
            quantity: quantity,
          ));

  @override
  Future<DataState<void>> completeTransfer(int transferId) =>
      guard(() => _service.completeTransfer(transferId));

  @override
  Future<DataState<int>> startAudit(int warehouseId) =>
      guard(() => _service.startAudit(warehouseId));

  @override
  Future<DataState<void>> recordAuditCount(
    int auditId, {
    required int productVariantId,
    required int actualQuantity,
  }) =>
      guard(() => _service.recordAuditCount(
            auditId,
            productVariantId: productVariantId,
            actualQuantity: actualQuantity,
          ));

  @override
  Future<DataState<void>> completeAudit(int auditId) =>
      guard(() => _service.completeAudit(auditId));
}
