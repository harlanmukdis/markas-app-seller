import '../../../utils/json_parse.dart';

/// The physical unit — and the unit money is released against.
///
/// A store that ships in stages gets paid in stages; a dispute freezes one
/// shipment, not the store (API doc 4). One sub-order may be split into
/// several of these.
class Shipment {
  const Shipment({
    required this.id,
    this.subOrderId,
    this.status,
    this.shippingMethod,
    this.fleetTypeCode,
    this.zoneId,
    this.shippingCost = 0,
    this.suratJalanNo,
    this.isScheduled = false,
    this.scheduledDate,
    this.batchId,
    this.deliveryAttemptCount = 0,
    this.handlingClassSnapshot,
    this.holdDays,
    this.holdReleaseAt,
    this.completedAt,
    this.podPhotoUrl,
    this.podReceiverName,
    this.createdAt,
    this.items = const <ShipmentItem>[],
  });

  final int id;
  final int? subOrderId;
  final String? status;
  final String? shippingMethod;
  final String? fleetTypeCode;
  final int? zoneId;
  final int shippingCost;

  /// Issued when the shipment is marked shipped — that is also the moment
  /// stock is actually deducted.
  final String? suratJalanNo;

  final bool isScheduled;
  final DateTime? scheduledDate;
  final int? batchId;

  /// On the third failure the shipment becomes GAGAL_KIRIM.
  final int deliveryAttemptCount;

  /// Taken from the item with the heaviest handling
  /// (NORMAL < OVERSIZE < PECAH_BELAH < BERBAHAYA). This is what decides
  /// whether the payout hold is T+3 or T+7.
  final String? handlingClassSnapshot;

  final int? holdDays;
  final DateTime? holdReleaseAt;
  final DateTime? completedAt;
  final String? podPhotoUrl;
  final String? podReceiverName;
  final DateTime? createdAt;
  final List<ShipmentItem> items;

  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
        id: asInt(json['id']),
        subOrderId: asIntOrNull(json['sub_order_id']),
        status: asStringOrNull(json['status']),
        shippingMethod: asStringOrNull(json['shipping_method']),
        fleetTypeCode: asStringOrNull(json['fleet_type_code']),
        zoneId: asIntOrNull(json['zone_id']),
        shippingCost: asInt(json['shipping_cost']),
        suratJalanNo: asStringOrNull(json['surat_jalan_no']),
        isScheduled: asBool(json['is_scheduled']),
        scheduledDate: asDateTime(json['scheduled_date']),
        batchId: asIntOrNull(json['batch_id']),
        deliveryAttemptCount: asInt(json['delivery_attempt_count']),
        handlingClassSnapshot:
            asStringOrNull(json['handling_class_snapshot']),
        holdDays: asIntOrNull(json['hold_days']),
        holdReleaseAt: asDateTime(json['hold_release_at']),
        completedAt: asDateTime(json['completed_at']),
        podPhotoUrl: asStringOrNull(json['pod_photo_url']),
        podReceiverName: asStringOrNull(json['pod_receiver_name']),
        createdAt: asDateTime(json['created_at']),
        items: asModelList(
          json['shipment_items'] ?? json['items'],
          ShipmentItem.fromJson,
        ),
      );

  bool get canProcess => status == ShipmentStatus.siap;

  bool get canShip => status == ShipmentStatus.diproses;

  /// POD is mandatory before a delivery can be called complete (SHP-08).
  bool get canRecordPod => status == ShipmentStatus.dikirim;

  bool get canFailDelivery => status == ShipmentStatus.dikirim;

  bool get canReturnToSeller => status == ShipmentStatus.gagalKirim;

  bool get isFrozen => status == ShipmentStatus.dibekukan;
}

class ShipmentItem {
  const ShipmentItem({
    required this.id,
    this.shipmentId,
    this.subOrderItemId,
    this.qty = 0,
    this.itemNameSnapshot,
  });

  final int id;
  final int? shipmentId;
  final int? subOrderItemId;
  final double qty;
  final String? itemNameSnapshot;

  factory ShipmentItem.fromJson(Map<String, dynamic> json) => ShipmentItem(
        id: asInt(json['id']),
        shipmentId: asIntOrNull(json['shipment_id']),
        subOrderItemId: asIntOrNull(json['sub_order_item_id']),
        qty: asDouble(json['qty']),
        itemNameSnapshot: asStringOrNull(json['item_name_snapshot']),
      );
}

abstract class ShipmentStatus {
  static const String dijadwalkan = 'DIJADWALKAN';
  static const String menungguBayarBatch = 'MENUNGGU_BAYAR_BATCH';
  static const String siap = 'SIAP';
  static const String ditunda = 'DITUNDA';
  static const String diproses = 'DIPROSES';
  static const String dikirim = 'DIKIRIM';
  static const String sampai = 'SAMPAI';
  static const String gagalKirim = 'GAGAL_KIRIM';
  static const String balikKeToko = 'BALIK_KE_TOKO';
  static const String selesai = 'SELESAI';
  static const String returDiajukan = 'RETUR_DIAJUKAN';
  static const String masaTahan = 'MASA_TAHAN';
  static const String dibekukan = 'DIBEKUKAN';
  static const String cair = 'CAIR';
  static const String dibatalkan = 'DIBATALKAN';

  static String label(String? status) => switch (status) {
        dijadwalkan => 'Dijadwalkan',
        menungguBayarBatch => 'Menunggu bayar batch',
        siap => 'Siap',
        ditunda => 'Ditunda',
        diproses => 'Diproses',
        dikirim => 'Dikirim',
        sampai => 'Sampai',
        gagalKirim => 'Gagal kirim',
        balikKeToko => 'Balik ke toko',
        selesai => 'Selesai',
        returDiajukan => 'Retur diajukan',
        masaTahan => 'Masa tahan',
        dibekukan => 'Dibekukan',
        cair => 'Cair',
        dibatalkan => 'Dibatalkan',
        _ => status ?? '-',
      };
}

abstract class ShippingMethod {
  static const String armadaToko = 'ARMADA_TOKO';
  static const String kurir3pl = 'KURIR_3PL';

  static const List<String> all = <String>[armadaToko, kurir3pl];

  static String label(String? method) => switch (method) {
        armadaToko => 'Armada toko',
        kurir3pl => 'Kurir 3PL',
        _ => method ?? '-',
      };
}

abstract class HandlingClass {
  static const String normal = 'NORMAL';
  static const String oversize = 'OVERSIZE';
  static const String pecahBelah = 'PECAH_BELAH';

  /// Blocked outright from KURIR_3PL — not warned about, blocked (SHP-13).
  static const String berbahaya = 'BERBAHAYA';

  static const List<String> all = <String>[
    normal,
    oversize,
    pecahBelah,
    berbahaya,
  ];

  static String label(String? handlingClass) => switch (handlingClass) {
        normal => 'Normal',
        oversize => 'Oversize',
        pecahBelah => 'Pecah belah',
        berbahaya => 'Berbahaya',
        _ => handlingClass ?? '-',
      };

  /// Longer payout hold for fragile goods (T+7 rather than T+3).
  static bool hasLongerHold(String? handlingClass) =>
      handlingClass == pecahBelah;
}

/// One line of a shipment: which sub-order item, and how much of it.
///
/// Lives in the domain layer because repository interfaces take it — the
/// service that sends it depends on this, not the other way round.
class ShipmentLine {
  const ShipmentLine({required this.subOrderItemId, required this.qty});

  final int subOrderItemId;
  final double qty;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'sub_order_item_id': subOrderItemId,
        'qty': qty,
      };
}
