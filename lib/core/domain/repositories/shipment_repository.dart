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

  Future<DataState<PodResult>> recordPod(
    int shipmentId, {
    required String photoUrl,
    required String receiverName,
    String? signatureUrl,
    List<PodItem> podItems,
  });

  /// [reasonCode] must be one of [FailureReason.all].
  Future<DataState<int>> failDelivery(
    int shipmentId, {
    required String reasonCode,
  });

  Future<DataState<bool>> returnToSeller(int shipmentId);

  Future<DataState<bool>> restock(int shipmentId);

  Future<DataState<bool>> confirmPackagingReturned(int shipmentId);
}
