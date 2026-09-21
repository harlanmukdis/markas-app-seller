import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/inventory/stock_movement.dart';
import '../../../../domain/model/inventory/warehouse.dart';
import '../../../../domain/model/inventory/warehouse_stock.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

/// Warehouses and the stock ledger.
///
/// Two things about this module are easy to get wrong:
///
/// * **Warehouse writes are not whitelisted.** The controller passes the request
///   body straight into the SQL insert/update, so one field that is not a
///   column answers `500` with an HTML "Database Error" page. Every body built
///   here therefore names only real columns.
/// * **Stock is never set, only moved.** `warehouse_stocks` is derived from an
///   append-only ledger, so a correction is an `adjustment` with a delta, not a
///   new total.
class InventoryService extends BaseService {
  const InventoryService(super.dio);

  // ------------------------------------------------------------ warehouses

  Future<List<Warehouse>> getWarehouses(int storeId) async {
    final envelope = await getRequest(
      ApiEndpoints.storeWarehouses(storeId),
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return envelope.list.map(Warehouse.fromJson).toList(growable: false);
  }

  Future<Warehouse> getWarehouse(int warehouseId) async {
    final envelope = await getRequest(ApiEndpoints.warehouse(warehouseId));
    return Warehouse.fromJson(envelope.map);
  }

  /// Answers `{ "id": N }`.
  ///
  /// `is_default` is deliberately not sent: the server decides it — the first
  /// warehouse a store creates is the default and every later one is not —
  /// and sending it only creates the impression that the client chose.
  Future<int> createWarehouse(
    int storeId, {
    required String name,
    required String address,
    required String city,
    required String province,
    required String postalCode,
    int? cityId,
    double? latitude,
    double? longitude,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.storeWarehouses(storeId),
      body: <String, dynamic>{
        'name': name,
        'address': address,
        'city': city,
        'province': province,
        'city_id': cityId,
        'postal_code': postalCode,
        'latitude': latitude,
        'longitude': longitude,
      },
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return asInt(envelope.map['id']);
  }

  /// Patches and re-reads — the patch answers `data: null`.
  Future<Warehouse> updateWarehouse(
    int warehouseId, {
    String? name,
    String? address,
    String? city,
    String? province,
    int? cityId,
    String? postalCode,
    String? status,
  }) async {
    await patchRequest(
      ApiEndpoints.warehouse(warehouseId),
      body: <String, dynamic>{
        'name': name,
        'address': address,
        'city': city,
        'province': province,
        'city_id': cityId,
        'postal_code': postalCode,
        'status': status,
      },
    );
    return getWarehouse(warehouseId);
  }

  // ----------------------------------------------------------------- stock

  Future<List<WarehouseStock>> getStocks(int warehouseId) async {
    final envelope = await getRequest(ApiEndpoints.warehouseStocks(warehouseId));
    return envelope.list.map(WarehouseStock.fromJson).toList(growable: false);
  }

  /// One page of the ledger, newest first. Like every list on this backend that
  /// sends no `meta`, it is still capped — a short page is the end.
  Future<List<StockMovement>> getMovements(
    int warehouseId, {
    int page = 1,
  }) async {
    final envelope = await getRequest(
      ApiEndpoints.warehouseMovements(warehouseId),
      query: <String, dynamic>{'page': page},
    );
    return envelope.list.map(StockMovement.fromJson).toList(growable: false);
  }

  /// Goods arriving. [quantity] is taken as a magnitude — the server applies
  /// `abs()` — so a negative here would silently become an increase.
  Future<void> stockIn(
    int warehouseId, {
    required int productVariantId,
    required int quantity,
    String? notes,
  }) =>
      postRequest(
        ApiEndpoints.warehouseStockIn(warehouseId),
        body: <String, dynamic>{
          'product_variant_id': productVariantId,
          'quantity': quantity,
          'notes': notes,
        },
      );

  /// Goods leaving for a reason that is not an order — damage, samples, loss.
  ///
  /// Fails `422 STOCK_INSUFFICIENT` when the amount would cut into stock that
  /// checkout has reserved, so a seller reading "on hand" can be refused an
  /// amount that looks available. Show `quantity_available`, not on-hand.
  Future<void> stockOut(
    int warehouseId, {
    required int productVariantId,
    required int quantity,
    String? notes,
  }) =>
      postRequest(
        ApiEndpoints.warehouseStockOut(warehouseId),
        body: <String, dynamic>{
          'product_variant_id': productVariantId,
          'quantity': quantity,
          'notes': notes,
        },
      );

  /// A correction, expressed as a **delta** rather than a new total: `-2` means
  /// two fewer than the ledger currently says.
  Future<int> adjustStock({
    required int warehouseId,
    required int productVariantId,
    required int quantityDelta,
    required String reason,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.stockAdjustments,
      body: <String, dynamic>{
        'warehouse_id': warehouseId,
        'product_variant_id': productVariantId,
        'quantity_delta': quantityDelta,
        'reason': reason,
      },
    );
    return asInt(envelope.map['id']);
  }

  // -------------------------------------------------------------- transfer

  /// Moving stock between two of the store's own warehouses.
  ///
  /// The source is debited **immediately**, at create; the destination is only
  /// credited by [completeTransfer]. Until then the stock is in neither place,
  /// which is what a van looks like in a ledger. Source and destination must
  /// differ — the server rejects equal ids with `VALIDATION_ERROR`.
  Future<int> createTransfer({
    required int sourceWarehouseId,
    required int destinationWarehouseId,
    required int productVariantId,
    required int quantity,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.stockTransfers,
      body: <String, dynamic>{
        'source_warehouse_id': sourceWarehouseId,
        'destination_warehouse_id': destinationWarehouseId,
        'product_variant_id': productVariantId,
        'quantity': quantity,
      },
    );
    return asInt(envelope.map['id']);
  }

  Future<void> completeTransfer(int transferId) =>
      postRequest(ApiEndpoints.stockTransferComplete(transferId));

  // ----------------------------------------------------------------- audit

  /// Opens a counting session. Answers `{ "id": N }`.
  Future<int> startAudit(int warehouseId) async {
    final envelope = await postRequest(ApiEndpoints.warehouseAudits(warehouseId));
    return asInt(envelope.map['id']);
  }

  /// Records a physical count for one variant. The variance is not applied yet.
  Future<void> recordAuditCount(
    int auditId, {
    required int productVariantId,
    required int actualQuantity,
  }) =>
      postRequest(
        ApiEndpoints.auditItems(auditId),
        body: <String, dynamic>{
          'product_variant_id': productVariantId,
          'actual_quantity': actualQuantity,
        },
      );

  /// Closes the session and writes the variance as an `adjustment` movement per
  /// counted variant — so an audit shows up in the ledger as adjustments, not
  /// as a type of its own.
  Future<void> completeAudit(int auditId) =>
      postRequest(ApiEndpoints.auditComplete(auditId));
}
