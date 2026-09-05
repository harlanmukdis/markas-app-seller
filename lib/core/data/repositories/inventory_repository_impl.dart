import '../../data_state.dart';
import '../../domain/model/inventory/inventory.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/remote/service/inventory_service.dart';
import 'repository_guard.dart';

class InventoryRepositoryImpl
    with RepositoryGuard
    implements InventoryRepository {
  const InventoryRepositoryImpl(this._service);

  final InventoryService _service;

  @override
  Future<DataState<StockMovementResult>> stockIn({
    required int offerId,
    required int warehouseId,
    required double qty,
    String? note,
  }) =>
      guard(() => _service.stockIn(
            offerId: offerId,
            warehouseId: warehouseId,
            qty: qty,
            note: note,
          ));

  @override
  Future<DataState<StockMovementResult>> adjust({
    required int offerId,
    required int warehouseId,
    required double qtyDelta,
    required String reason,
    String? refDoc,
  }) =>
      guard(() => _service.adjust(
            offerId: offerId,
            warehouseId: warehouseId,
            qtyDelta: qtyDelta,
            reason: reason,
            refDoc: refDoc,
          ));

  @override
  Future<DataState<List<InventoryLedgerEntry>>> getLedger(int offerId) =>
      guard(() => _service.getLedger(offerId));

  @override
  Future<DataState<StockAvailability>> getAvailable(int offerId) =>
      guard(() => _service.getAvailable(offerId));
}
