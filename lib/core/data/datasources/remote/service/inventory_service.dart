import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/inventory/inventory.dart';
import 'base_service.dart';

/// Stock is never overwritten — every change is a new ledger row and the
/// quantity is their sum (INV-02).
class InventoryService extends BaseService {
  const InventoryService(super.dio);

  /// `qty` is always taken as its absolute value by the backend.
  Future<StockMovementResult> stockIn({
    required int offerId,
    required int warehouseId,
    required double qty,
    String? note,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.inventoryStockIn,
      body: <String, dynamic>{
        'offer_id': offerId,
        'warehouse_id': warehouseId,
        'qty': qty,
        'note': note,
      },
    );
    return StockMovementResult.fromJson(envelope.map);
  }

  /// [reason] is mandatory (INV-06) — damage, shrinkage, a stocktake
  /// correction. [qtyDelta] may be negative.
  Future<StockMovementResult> adjust({
    required int offerId,
    required int warehouseId,
    required double qtyDelta,
    required String reason,
    String? refDoc,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.inventoryAdjust,
      body: <String, dynamic>{
        'offer_id': offerId,
        'warehouse_id': warehouseId,
        'qty_delta': qtyDelta,
        'reason': reason,
        'ref_doc': refDoc,
      },
    );
    return StockMovementResult.fromJson(envelope.map);
  }

  Future<List<InventoryLedgerEntry>> getLedger(int offerId) async {
    final envelope = await getRequest(
      ApiEndpoints.inventoryLedger,
      query: <String, dynamic>{'offer_id': offerId},
    );
    return envelope
        .listAt('ledger')
        .map(InventoryLedgerEntry.fromJson)
        .toList(growable: false);
  }

  Future<StockAvailability> getAvailable(int offerId) async {
    final envelope = await getRequest(
      ApiEndpoints.inventoryAvailable,
      query: <String, dynamic>{'offer_id': offerId},
    );
    return StockAvailability.fromJson(envelope.map);
  }
}
