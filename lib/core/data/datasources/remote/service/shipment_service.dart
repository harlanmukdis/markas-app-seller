import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/shipment/shipment.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

class ShipmentService extends BaseService {
  const ShipmentService(super.dio);

  /// Already scoped to this store with a `SEL` token; 50 most recent.
  Future<List<Shipment>> getShipments() async {
    final envelope = await getRequest(ApiEndpoints.shipments);
    return envelope
        .listAt('shipments')
        .map(Shipment.fromJson)
        .toList(growable: false);
  }

  Future<Shipment> getShipment(int shipmentId) async {
    final envelope = await getRequest(ApiEndpoints.shipment(shipmentId));
    return Shipment.fromJson(envelope.map);
  }

  /// The sub-order must already be BERJALAN or this fails with
  /// `409 INVALID_STATE`. [items] may cover only part of the sub-order —
  /// partial shipments are supported, and each one pays out separately.
  ///
  /// Hazardous goods are **blocked** from KURIR_3PL, not warned about
  /// (`422 HANDLING_CLASS_BLOCKED`, SHP-13).
  Future<int> createShipment({
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
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.shipments,
      body: <String, dynamic>{
        'sub_order_id': subOrderId,
        'shipping_method': shippingMethod,
        'items': items.map((line) => line.toJson()).toList(),
        'fleet_type_code': fleetTypeCode,
        'zone_id': zoneId,
        'shipping_cost': shippingCost,
        'surcharge_json': surcharge,
        'is_scheduled': isScheduled,
        'scheduled_date': scheduledDate,
        'batch_id': batchId,
      },
    );
    return asInt(envelope.map['id']);
  }

  Future<void> process(int shipmentId) async {
    await postRequest(ApiEndpoints.shipmentProcess(shipmentId));
  }

  /// DIPROSES -> DIKIRIM. This is the moment stock is actually deducted and
  /// the delivery note (`surat_jalan_no`) is issued.
  Future<void> ship(int shipmentId) async {
    await postRequest(ApiEndpoints.shipmentShip(shipmentId));
  }

  /// Without POD a delivery may not be called complete (SHP-08), so the photo
  /// and receiver name are required here rather than optional.
  Future<void> recordPod(
    int shipmentId, {
    required String photoUrl,
    required String receiverName,
    String? signatureUrl,
  }) async {
    await postRequest(
      ApiEndpoints.shipmentPod(shipmentId),
      body: <String, dynamic>{
        'photo_url': photoUrl,
        'receiver_name': receiverName,
        'signature_url': signatureUrl,
      },
    );
  }

  /// On the third attempt the shipment becomes GAGAL_KIRIM.
  Future<int> failDelivery(int shipmentId) async {
    final envelope =
        await postRequest(ApiEndpoints.shipmentFailDelivery(shipmentId));
    return asInt(envelope.map['delivery_attempt_count']);
  }

  Future<void> returnToSeller(int shipmentId) async {
    await postRequest(ApiEndpoints.shipmentReturnToSeller(shipmentId));
  }
}
