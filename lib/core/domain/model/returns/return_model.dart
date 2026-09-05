import '../../../utils/json_parse.dart';

/// A buyer's return request against one shipment.
///
/// The two deadlines on this object are worth real money: silence for 2×24h on
/// [respond] means the return is **accepted** (RET-04), and silence for 2×24h
/// on [inspect] means the goods are **deemed as described** and the refund
/// goes through (RET-15/TO-15).
class ReturnModel {
  const ReturnModel({
    required this.id,
    this.returnNo,
    this.shipmentId,
    this.buyerId,
    this.status,
    this.reason,
    this.qtyReturned = 0,
    this.sellerResponseDeadline,
    this.sellerRespondedAt,
    this.sellerResponseNote,
    this.sellerInspectDeadline,
    this.returnCourierType,
    this.pickupScheduledAt,
    this.pickupDeadline,
    this.buyerShipBackDeadline,
    this.refundId,
    this.createdAt,
    this.evidencePhotos = const <String>[],
  });

  final int id;
  final String? returnNo;
  final int? shipmentId;
  final int? buyerId;
  final String? status;
  final String? reason;
  final double qtyReturned;

  /// 2×24h from delivery. **Silence means acceptance** (RET-04) — past this
  /// the endpoint answers `409 ALREADY_AUTO_APPROVED`.
  final DateTime? sellerResponseDeadline;

  final DateTime? sellerRespondedAt;
  final String? sellerResponseNote;

  /// 2×24h once the goods are back. Silence means "as described" and the
  /// refund proceeds (RET-15).
  final DateTime? sellerInspectDeadline;

  /// How the goods come back. `JEMPUT_TOKO` means the store collects them
  /// itself — and missing [pickupDeadline] hands the goods to the buyer
  /// along with the refund (RET-12).
  final String? returnCourierType;

  final DateTime? pickupScheduledAt;
  final DateTime? pickupDeadline;
  final DateTime? buyerShipBackDeadline;
  final int? refundId;
  final DateTime? createdAt;

  /// The buyer's unboxing photos. Sent as a JSON **string** holding plain URL
  /// strings, not objects — unlike an offer's `photos_json`.
  final List<String> evidencePhotos;

  factory ReturnModel.fromJson(Map<String, dynamic> json) => ReturnModel(
        id: asInt(json['id']),
        returnNo: asStringOrNull(json['return_no']),
        shipmentId: asIntOrNull(json['shipment_id']),
        buyerId: asIntOrNull(json['buyer_id']),
        status: asStringOrNull(json['status']),
        reason: asStringOrNull(json['reason']),
        qtyReturned: asDouble(json['qty_returned']),
        sellerResponseDeadline: asDateTime(json['seller_response_deadline']),
        sellerRespondedAt: asDateTime(json['seller_responded_at']),
        sellerResponseNote: asStringOrNull(json['seller_response_note']),
        sellerInspectDeadline: asDateTime(json['seller_inspect_deadline']),
        returnCourierType: asStringOrNull(json['return_courier_type']),
        pickupScheduledAt: asDateTime(json['pickup_scheduled_at']),
        pickupDeadline: asDateTime(json['pickup_deadline']),
        buyerShipBackDeadline: asDateTime(json['buyer_ship_back_deadline']),
        refundId: asIntOrNull(json['refund_id']),
        createdAt: asDateTime(json['created_at']),
        evidencePhotos: _photoUrls(json['evidence_photos_json']),
      );

  /// Accepts both shapes seen on this backend: a bare list of URL strings and
  /// a list of `{url: …}` objects.
  static List<String> _photoUrls(dynamic value) {
    final decoded = asDecodedJson(value);
    if (decoded is! List) return const <String>[];
    return decoded
        .map((entry) => entry is Map ? asString(entry['url']) : entry.toString())
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
  }

  bool get awaitingResponse => status == ReturnStatus.diajukan;

  bool get awaitingInspection => status == ReturnStatus.diterimaToko;

  /// The store has to collect the goods itself.
  bool get needsPickup => returnCourierType == ReturnMethod.jemputToko;

  /// The deadline currently running against the store, if any.
  DateTime? get activeDeadline {
    if (awaitingResponse) return sellerResponseDeadline;
    if (awaitingInspection) return sellerInspectDeadline;
    return null;
  }
}

abstract class ReturnStatus {
  static const String diajukan = 'DIAJUKAN';
  static const String ditolakOtomatis = 'DITOLAK_OTOMATIS';
  static const String disetujui = 'DISETUJUI';
  static const String ditolak = 'DITOLAK';
  static const String refundTanpaKembali = 'REFUND_TANPA_KEMBALI';
  static const String dikirimBalik = 'DIKIRIM_BALIK';
  static const String diterimaToko = 'DITERIMA_TOKO';
  static const String hilang = 'HILANG';
  static const String sengketa = 'SENGKETA';
  static const String selesai = 'SELESAI';
  static const String direfund = 'DIREFUND';

  static String label(String? status) => switch (status) {
        diajukan => 'Diajukan',
        ditolakOtomatis => 'Ditolak otomatis',
        disetujui => 'Disetujui',
        ditolak => 'Ditolak',
        refundTanpaKembali => 'Refund tanpa kembali',
        dikirimBalik => 'Dikirim balik',
        diterimaToko => 'Diterima toko',
        hilang => 'Hilang',
        sengketa => 'Sengketa',
        selesai => 'Selesai',
        direfund => 'Direfund',
        _ => status ?? '-',
      };
}

abstract class ReturnDecision {
  static const String approve = 'APPROVE';
  static const String reject = 'REJECT';

  static const List<String> all = <String>[approve, reject];

  static String label(String? decision) => switch (decision) {
        approve => 'Setujui retur',
        reject => 'Tolak retur',
        _ => decision ?? '-',
      };
}

abstract class RefundRoute {
  static const String dikirimBalik = 'DIKIRIM_BALIK';

  /// Buyer is refunded and keeps the goods — chosen automatically when return
  /// shipping would cost more than the goods themselves.
  static const String refundTanpaKembali = 'REFUND_TANPA_KEMBALI';

  static const List<String> all = <String>[dikirimBalik, refundTanpaKembali];

  static String label(String? route) => switch (route) {
        dikirimBalik => 'Dikirim balik ke toko',
        refundTanpaKembali => 'Refund tanpa barang kembali',
        _ => 'Ditentukan sistem',
      };
}

abstract class ReturnMethod {
  static const String labelPlatform = 'LABEL_PLATFORM';
  static const String jemputToko = 'JEMPUT_TOKO';
}

abstract class InspectResult {
  static const String sesuai = 'SESUAI';

  /// Opens a dispute automatically; the response carries a `dispute_id`.
  static const String bedaKondisi = 'BEDA_KONDISI';

  static const List<String> all = <String>[sesuai, bedaKondisi];

  static String label(String? result) => switch (result) {
        sesuai => 'Sesuai',
        bedaKondisi => 'Beda kondisi (buka sengketa)',
        _ => result ?? '-',
      };
}

abstract class FaultParty {
  static const String seller = 'SELLER';
  static const String buyer = 'BUYER';

  static const List<String> all = <String>[seller, buyer];

  static String label(String? fault) => switch (fault) {
        seller => 'Toko',
        buyer => 'Pembeli',
        _ => 'Tidak ditentukan',
      };
}

/// `POST /returns/{id}/inspect` — carries a dispute id when the result was
/// BEDA_KONDISI.
class InspectOutcome {
  const InspectOutcome({this.disputeId, this.status});

  final int? disputeId;
  final String? status;

  factory InspectOutcome.fromJson(Map<String, dynamic> json) => InspectOutcome(
        disputeId: asIntOrNull(json['dispute_id']),
        status: asStringOrNull(json['status']),
      );

  bool get openedDispute => disputeId != null;
}
