import '../../data_state.dart';
import '../model/shipment/shipment.dart';

abstract class ShipmentRepository {
  Future<DataState<List<Shipment>>> getShipments();

  Future<DataState<Shipment>> getShipment(int shipmentId);

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
  });

  Future<DataState<bool>> process(int shipmentId);

  Future<DataState<bool>> ship(int shipmentId);

  Future<DataState<bool>> recordPod(
    int shipmentId, {
    required String photoUrl,
    required String receiverName,
    String? signatureUrl,
  });

  Future<DataState<int>> failDelivery(int shipmentId);

  Future<DataState<bool>> returnToSeller(int shipmentId);
}
