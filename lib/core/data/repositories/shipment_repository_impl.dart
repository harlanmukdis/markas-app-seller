import '../../data_state.dart';
import '../../domain/model/shipment/shipment.dart';
import '../../domain/repositories/shipment_repository.dart';
import '../datasources/remote/service/shipment_service.dart';
import 'repository_guard.dart';

class ShipmentRepositoryImpl
    with RepositoryGuard
    implements ShipmentRepository {
  const ShipmentRepositoryImpl(this._service);

  final ShipmentService _service;

  @override
  Future<DataState<List<Shipment>>> getShipments() =>
      guard(() => _service.getShipments());

  @override
  Future<DataState<Shipment>> getShipment(int shipmentId) =>
      guard(() => _service.getShipment(shipmentId));

  @override
  Future<DataState<int>> createShipment({
    required int subOrderId,
    required String shippingMethod,
    required List<ShipmentLine> items,
    String? fleetTypeCode,
    int? zoneId,
    int? shippingCost,
    Map<String, dynamic>? surcharge,
    bool? isScheduled,
    String? scheduledDate,
    int? batchId,
  }) =>
      guard(() => _service.createShipment(
            subOrderId: subOrderId,
            shippingMethod: shippingMethod,
            items: items,
            fleetTypeCode: fleetTypeCode,
            zoneId: zoneId,
            shippingCost: shippingCost,
            surcharge: surcharge,
            isScheduled: isScheduled,
            scheduledDate: scheduledDate,
            batchId: batchId,
          ));

  @override
  Future<DataState<bool>> process(int shipmentId) => guard(() async {
        await _service.process(shipmentId);
        return true;
      });

  @override
  Future<DataState<bool>> ship(int shipmentId) => guard(() async {
        await _service.ship(shipmentId);
        return true;
      });

  @override
  Future<DataState<bool>> recordPod(
    int shipmentId, {
    required String photoUrl,
    required String receiverName,
    String? signatureUrl,
  }) =>
      guard(() async {
        await _service.recordPod(
          shipmentId,
          photoUrl: photoUrl,
          receiverName: receiverName,
          signatureUrl: signatureUrl,
        );
        return true;
      });

  @override
  Future<DataState<int>> failDelivery(int shipmentId) =>
      guard(() => _service.failDelivery(shipmentId));

  @override
  Future<DataState<bool>> returnToSeller(int shipmentId) => guard(() async {
        await _service.returnToSeller(shipmentId);
        return true;
      });
}
