import '../../../utils/json_parse.dart';

/// A dispute involving this store.
///
/// The decision is executed against the store's **balance ledger**, not by
/// editing the order (DSP-06) — so the order total on screen will not change
/// after a dispute; the balance will.
class Dispute {
  const Dispute({
    required this.id,
    this.shipmentId,
    this.returnId,
    this.status,
    this.category,
    this.decision,
    this.decisionReason,
    this.deadlineBukti,
    this.createdAt,
    this.evidence = const <DisputeEvidence>[],
    this.history = const <DisputeHistoryEntry>[],
  });

  final int id;
  final int? shipmentId;
  final int? returnId;
  final String? status;
  final String? category;

  /// CS decisions are final within the platform and always come with a written
  /// reason, which is shown to the store verbatim.
  final String? decision;
  final String? decisionReason;

  /// 2×24h. After that CS decides on whatever evidence exists.
  final DateTime? deadlineBukti;

  final DateTime? createdAt;
  final List<DisputeEvidence> evidence;
  final List<DisputeHistoryEntry> history;

  factory Dispute.fromJson(Map<String, dynamic> json) => Dispute(
        id: asInt(json['id']),
        shipmentId: asIntOrNull(json['shipment_id']),
        returnId: asIntOrNull(json['return_id']),
        status: asStringOrNull(json['status']),
        category: asStringOrNull(json['category']),
        decision: asStringOrNull(json['decision']),
        decisionReason: asStringOrNull(json['decision_reason']),
        deadlineBukti: asDateTime(json['deadline_bukti']),
        createdAt: asDateTime(json['created_at']),
        evidence: asModelList(
          json['evidence'] ?? json['evidences'],
          DisputeEvidence.fromJson,
        ),
        history: asModelList(
          json['history'] ?? json['status_history'],
          DisputeHistoryEntry.fromJson,
        ),
      );

  bool get isDecided => decision != null;
}

/// Evidence can only be **added**, never deleted — including by an admin
/// (DSP-02). Never render a delete control.
class DisputeEvidence {
  const DisputeEvidence({
    required this.id,
    this.evidenceType,
    this.fileUrl,
    this.textContent,
    this.submittedByType,
    this.createdAt,
  });

  final int id;
  final String? evidenceType;
  final String? fileUrl;
  final String? textContent;
  final String? submittedByType;
  final DateTime? createdAt;

  factory DisputeEvidence.fromJson(Map<String, dynamic> json) =>
      DisputeEvidence(
        id: asInt(json['id']),
        evidenceType: asStringOrNull(json['evidence_type']),
        fileUrl: asStringOrNull(json['file_url']),
        textContent: asStringOrNull(json['text_content']),
        submittedByType: asStringOrNull(json['submitted_by_type']),
        createdAt: asDateTime(json['created_at']),
      );
}

class DisputeHistoryEntry {
  const DisputeHistoryEntry({this.status, this.note, this.createdAt});

  final String? status;
  final String? note;
  final DateTime? createdAt;

  factory DisputeHistoryEntry.fromJson(Map<String, dynamic> json) =>
      DisputeHistoryEntry(
        status: asStringOrNull(json['status'] ?? json['to_status']),
        note: asStringOrNull(json['note']),
        createdAt: asDateTime(json['created_at']),
      );
}

abstract class EvidenceType {
  static const String fotoBongkar = 'FOTO_BONGKAR';

  /// The store's main protection. For fragile categories the store's packing
  /// photo is required (DSP-03) — and without it, "it arrived broken" almost
  /// always goes the buyer's way. Best captured during `ship`, not remembered
  /// once a dispute already exists.
  static const String fotoKemasanToko = 'FOTO_KEMASAN_TOKO';

  static const String pod = 'POD';
  static const String chatHistory = 'CHAT_HISTORY';
  static const String statusHistory = 'STATUS_HISTORY';
  static const String lainnya = 'LAINNYA';

  static const List<String> all = <String>[
    fotoKemasanToko,
    fotoBongkar,
    pod,
    chatHistory,
    statusHistory,
    lainnya,
  ];

  static String label(String? type) => switch (type) {
        fotoBongkar => 'Foto bongkar',
        fotoKemasanToko => 'Foto pengemasan toko',
        pod => 'Bukti terima (POD)',
        chatHistory => 'Riwayat chat',
        statusHistory => 'Riwayat status',
        lainnya => 'Lainnya',
        _ => type ?? '-',
      };
}

abstract class DisputeDecision {
  static const String refundPenuh = 'REFUND_PENUH';
  static const String refundSebagian = 'REFUND_SEBAGIAN';
  static const String tolak = 'TOLAK';
  static const String penggantian = 'PENGGANTIAN';

  static String label(String? decision) => switch (decision) {
        refundPenuh => 'Refund penuh',
        refundSebagian => 'Refund sebagian',
        tolak => 'Ditolak',
        penggantian => 'Penggantian',
        _ => decision ?? '-',
      };
}
