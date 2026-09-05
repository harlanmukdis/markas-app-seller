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
    this.shipmentId,
    this.subOrderId,
    this.buyerId,
    this.status,
    this.reason,
    this.reasonNote,
    this.refundRoute,
    this.returnMethod,
    this.fault,
    this.deadlineTokoJawab,
    this.deadlinePeriksa,
    this.deadlineJemput,
    this.refundAmount,
    this.createdAt,
    this.photos = const <String>[],
  });

  final int id;
  final int? shipmentId;
  final int? subOrderId;
  final int? buyerId;
  final String? status;
  final String? reason;
  final String? reasonNote;

  /// If the store does not choose, the server does: when return shipping costs
  /// more than the goods, it picks REFUND_TANPA_KEMBALI and the buyer keeps
  /// them (RET-07).
  final String? refundRoute;

  /// For DIKIRIM_BALIK the platform picks the carrier (RET-08):
  /// LABEL_PLATFORM for normal goods, JEMPUT_TOKO otherwise — and a store that
  /// misses the 3×24h pickup loses the goods and the refund (RET-12).
  final String? returnMethod;

  final String? fault;
  final DateTime? deadlineTokoJawab;
  final DateTime? deadlinePeriksa;
  final DateTime? deadlineJemput;
  final int? refundAmount;
  final DateTime? createdAt;
  final List<String> photos;

  factory ReturnModel.fromJson(Map<String, dynamic> json) => ReturnModel(
        id: asInt(json['id']),
        shipmentId: asIntOrNull(json['shipment_id']),
        subOrderId: asIntOrNull(json['sub_order_id']),
        buyerId: asIntOrNull(json['buyer_id']),
        status: asStringOrNull(json['status']),
        reason: asStringOrNull(json['reason']),
        reasonNote: asStringOrNull(json['reason_note']),
        refundRoute: asStringOrNull(json['refund_route']),
        returnMethod: asStringOrNull(json['return_method']),
        fault: asStringOrNull(json['fault']),
        deadlineTokoJawab: asDateTime(json['deadline_toko_jawab']),
        deadlinePeriksa: asDateTime(json['deadline_periksa']),
        deadlineJemput: asDateTime(json['deadline_jemput']),
        refundAmount: asIntOrNull(json['refund_amount']),
        createdAt: asDateTime(json['created_at']),
        photos: asDecodedJson(json['photos_json']) is List
            ? (asDecodedJson(json['photos_json']) as List)
                .map((e) => e is Map ? asString(e['url']) : e.toString())
                .where((e) => e.isNotEmpty)
                .toList(growable: false)
            : const <String>[],
      );

  bool get awaitingResponse => status == ReturnStatus.diajukan;

  bool get awaitingInspection => status == ReturnStatus.diterimaToko;

  bool get needsPickup => returnMethod == ReturnMethod.jemputToko;
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
