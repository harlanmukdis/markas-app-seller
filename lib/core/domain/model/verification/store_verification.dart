import '../../../data/datasources/remote/service/media_service.dart';
import '../../../utils/json_parse.dart';

/// `GET /stores/{id}/verification` — the store's latest verification request,
/// with its documents and its status history.
///
/// This is the gate on selling: approving a request is what flips the store from
/// `inactive` to `active` (`Verification_model::approve` updates both rows in
/// one transaction). Approval is an admin action, so the seller app's job ends
/// at submitting and then showing where the request stands.
///
/// The endpoint answers `data: null` for a store that has never submitted —
/// an empty state, not an error.
class StoreVerification {
  const StoreVerification({
    required this.id,
    required this.storeId,
    required this.type,
    this.idCardNumber,
    this.taxNumber,
    this.businessDocUrl,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankName,
    this.status = VerificationStatus.draft,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
    this.documents = const <VerificationDocument>[],
    this.history = const <VerificationEvent>[],
  });

  final int id;
  final int storeId;
  final String type;
  final String? idCardNumber;
  final String? taxNumber;
  final String? businessDocUrl;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? bankName;
  final String status;

  /// Set only when [status] is `rejected`, and the only statement of what to fix.
  final String? rejectionReason;

  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final List<VerificationDocument> documents;
  final List<VerificationEvent> history;

  factory StoreVerification.fromJson(Map<String, dynamic> json) =>
      StoreVerification(
        id: asInt(json['id']),
        storeId: asInt(json['store_id']),
        type: asString(json['type'], fallback: VerificationType.individual),
        idCardNumber: asStringOrNull(json['id_card_number']),
        taxNumber: asStringOrNull(json['tax_number']),
        businessDocUrl: asStringOrNull(json['business_doc_url']),
        bankAccountName: asStringOrNull(json['bank_account_name']),
        bankAccountNumber: asStringOrNull(json['bank_account_number']),
        bankName: asStringOrNull(json['bank_name']),
        status: asString(json['status'], fallback: VerificationStatus.draft),
        rejectionReason: asStringOrNull(json['rejection_reason']),
        submittedAt: asDateTime(json['submitted_at']),
        reviewedAt: asDateTime(json['reviewed_at']),
        documents:
            asModelList(json['documents'], VerificationDocument.fromJson),
        history: asModelList(json['history'], VerificationEvent.fromJson),
      );

  bool get isApproved => status == VerificationStatus.approved;
  bool get isRejected => status == VerificationStatus.rejected;

  /// While a request is with the reviewer there is nothing for the seller to do
  /// but wait — and resubmitting in that state is actively harmful, because a
  /// new request starts with no documents.
  bool get isPending =>
      status == VerificationStatus.submitted ||
      status == VerificationStatus.inReview;

  /// The document kinds still missing for [type]. Business requests need the
  /// company papers on top of the personal ones.
  List<String> get missingDocuments {
    final present = documents.map((doc) => doc.docType).toSet();
    return DocumentType.requiredFor(type)
        .where((docType) => !present.contains(docType))
        .toList(growable: false);
  }
}

class VerificationDocument {
  const VerificationDocument({
    required this.id,
    required this.docType,
    required this.fileUrl,
    this.uploadedAt,
  });

  final int id;
  final String docType;

  /// Already normalised: the server builds this from its own configured host,
  /// which serves nothing in this environment.
  final String fileUrl;

  final DateTime? uploadedAt;

  factory VerificationDocument.fromJson(Map<String, dynamic> json) =>
      VerificationDocument(
        id: asInt(json['id']),
        docType: asString(json['doc_type']),
        fileUrl: normaliseUploadUrl(asString(json['file_url'])),
        uploadedAt: asDateTime(json['uploaded_at']),
      );
}

/// One row of `store_verification_logs`. `fromStatus` is null for the first
/// transition, which is the submit itself.
class VerificationEvent {
  const VerificationEvent({
    required this.id,
    required this.toStatus,
    this.fromStatus,
    this.notes,
    this.createdAt,
  });

  final int id;
  final String toStatus;
  final String? fromStatus;
  final String? notes;
  final DateTime? createdAt;

  factory VerificationEvent.fromJson(Map<String, dynamic> json) =>
      VerificationEvent(
        id: asInt(json['id']),
        toStatus: asString(json['to_status']),
        fromStatus: asStringOrNull(json['from_status']),
        notes: asStringOrNull(json['notes']),
        createdAt: asCreatedDate(json),
      );
}

abstract class VerificationStatus {
  static const String draft = 'draft';
  static const String submitted = 'submitted';
  static const String inReview = 'in_review';
  static const String approved = 'approved';
  static const String rejected = 'rejected';

  static String label(String? status) => switch (status) {
        draft => 'Draf',
        submitted => 'Menunggu ditinjau',
        inReview => 'Sedang ditinjau',
        approved => 'Disetujui',
        rejected => 'Ditolak',
        _ => status ?? '-',
      };
}

abstract class VerificationType {
  static const String individual = 'individual';
  static const String business = 'business';

  static const List<String> all = <String>[individual, business];

  static String label(String? type) => switch (type) {
        individual => 'Perorangan',
        business => 'Badan usaha',
        _ => type ?? '-',
      };
}

/// The server does **not** validate `doc_type` — it is a plain `VARCHAR(50)`
/// and a typo is accepted with a 201 — so the closed list lives here. The
/// values are the ones the schema documents as intended.
abstract class DocumentType {
  static const String ktp = 'ktp';
  static const String npwp = 'npwp';
  static const String siup = 'siup';
  static const String nib = 'nib';
  static const String selfie = 'selfie';

  static const List<String> all = <String>[ktp, npwp, siup, nib, selfie];

  static List<String> requiredFor(String verificationType) =>
      verificationType == VerificationType.business
          ? const <String>[ktp, npwp, siup, nib, selfie]
          : const <String>[ktp, selfie];

  static String label(String? docType) => switch (docType) {
        ktp => 'KTP',
        npwp => 'NPWP',
        siup => 'SIUP',
        nib => 'NIB',
        selfie => 'Swafoto dengan KTP',
        _ => docType ?? '-',
      };
}
