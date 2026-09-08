import '../../../utils/json_parse.dart';

/// The physical unit — and the unit money is released against.
///
/// A store that ships in stages gets paid in stages; a dispute freezes one
/// shipment, not the store (API doc 4). One sub-order may be split into
/// several of these.
class Shipment {
  const Shipment({
    required this.id,
    this.shipmentNo,
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
    this.failureReasonCode,
    this.packagingDepositAmount = 0,
    this.packagingReturnedConfirmedAt,
    this.storageFeeAccrued = 0,
    this.returnedAt,
    this.createdAt,
    this.items = const <ShipmentItem>[],
  });

  final int id;
  final String? shipmentNo;
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

  /// One of [FailureReason.all], recorded on a failed delivery (FLD-03).
  final String? failureReasonCode;

  /// Deposit held from the buyer for pallets or packaging (FLD-07). The store
  /// releases it once the packaging comes back — this is the buyer's money,
  /// so it should not be quietly forgotten.
  final int packagingDepositAmount;

  final DateTime? packagingReturnedConfirmedAt;

  /// Daily storage charged while goods sit in the warehouse after a failed
  /// delivery (FLD-04).
  final int storageFeeAccrued;

  final DateTime? returnedAt;

  final DateTime? createdAt;
  final List<ShipmentItem> items;

  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
        id: asInt(json['id']),
        shipmentNo: asStringOrNull(json['shipment_no']),
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
        failureReasonCode: asStringOrNull(json['failure_reason_code']),
        packagingDepositAmount: asInt(json['packaging_deposit_amount']),
        packagingReturnedConfirmedAt:
            asDateTime(json['packaging_returned_confirmed_at']),
        storageFeeAccrued: asInt(json['storage_fee_accrued']),
        returnedAt: asDateTime(json['returned_at']),
        createdAt: asCreatedDate(json),
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

  /// Goods are back in the warehouse and can be put on sale again (FLD-04).
  /// The server also enforces a waiting period and answers
  /// `409 RESTOCK_WINDOW_NOT_REACHED` with how many days remain.
  bool get canRestock => status == ShipmentStatus.balikKeToko;

  bool get hasPackagingDeposit => packagingDepositAmount > 0;

  bool get packagingDepositReleased => packagingReturnedConfirmedAt != null;

  /// The store still owes the buyer this money back.
  bool get canReleasePackagingDeposit =>
      hasPackagingDeposit && !packagingDepositReleased;
}

/// Closed list of reasons a delivery failed (FLD-03). Free text is rejected
/// with 422 — and [kendalaAksesLingkungan] in particular feeds the platform's
/// operational analysis, which is why it is a code and not a note.
abstract class FailureReason {
  /// Blocked on arrival: unofficial levies, local labour disputes, residents
  /// preventing unloading.
  static const String kendalaAksesLingkungan = 'KENDALA_AKSES_LINGKUNGAN';

  static const String alamatTidakDitemukan = 'ALAMAT_TIDAK_DITEMUKAN';
  static const String buyerTidakAda = 'BUYER_TIDAK_ADA';
  static const String barangRusakDiPerjalanan = 'BARANG_RUSAK_DI_PERJALANAN';
  static const String lainnya = 'LAINNYA';

  static const List<String> all = <String>[
    kendalaAksesLingkungan,
    alamatTidakDitemukan,
    buyerTidakAda,
    barangRusakDiPerjalanan,
    lainnya,
  ];

  static String label(String? code) => switch (code) {
        kendalaAksesLingkungan => 'Kendala akses lingkungan',
        alamatTidakDitemukan => 'Alamat tidak ditemukan',
        buyerTidakAda => 'Pembeli tidak ada di lokasi',
        barangRusakDiPerjalanan => 'Barang rusak di perjalanan',
        lainnya => 'Lainnya',
        _ => code ?? '-',
      };

  static String? hint(String? code) => switch (code) {
        kendalaAksesLingkungan =>
          'Termasuk pungli, kuli liar, atau dihalangi warga. Dilaporkan ke '
              'platform untuk ditindaklanjuti.',
        _ => null,
      };
}

/// One line of a POD declaring how much actually arrived (FLD-01).
///
/// For bulk materials — sand, split, stone — a shortfall inside the tolerance
/// (default 5%, from `FLD.bulk_tolerance_pct`) is refunded proportionally and
/// automatically. That protects the store: normal shrinkage becomes a recorded
/// adjustment instead of a "short delivery" dispute.
class PodItem {
  const PodItem({required this.shipmentItemId, required this.actualQtyReceived});

  final int shipmentItemId;
  final double actualQtyReceived;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'shipment_item_id': shipmentItemId,
        'actual_qty_received': actualQtyReceived,
      };
}

/// `POST /shipments/{id}/pod` result.
class PodResult {
  const PodResult({this.bulkToleranceRefund});

  /// Non-null when a bulk shortfall inside tolerance was refunded to the buyer
  /// automatically. Worth showing — the payout will be lower than the order.
  final int? bulkToleranceRefund;

  factory PodResult.fromJson(Map<String, dynamic> json) => PodResult(
        bulkToleranceRefund: asIntOrNull(json['bulk_tolerance_refund']),
      );

  bool get hadToleranceRefund => (bulkToleranceRefund ?? 0) > 0;
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
