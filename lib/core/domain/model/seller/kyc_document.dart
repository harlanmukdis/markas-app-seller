import '../../../utils/json_parse.dart';

/// A KYC document row.
///
/// Note there is no documented endpoint that lists these back — API doc 5.2
/// says the outcome shows up in `GET /sellers/{id}` and "di status tiap
/// dokumen", but never names a route for it. This model exists for the upload
/// response and for whenever that listing endpoint appears.
class KycDocument {
  const KycDocument({
    required this.id,
    required this.docType,
    this.fileUrl,
    this.status,
    this.rejectReason,
    this.createdAt,
  });

  final int id;
  final String docType;
  final String? fileUrl;
  final String? status;

  /// Shown per document, not rolled up — a store needs to know exactly which
  /// document to redo (API doc 5.2).
  final String? rejectReason;

  final DateTime? createdAt;

  factory KycDocument.fromJson(Map<String, dynamic> json) => KycDocument(
        id: asInt(json['id']),
        docType: asString(json['doc_type']),
        fileUrl: asStringOrNull(json['file_url']),
        status: asStringOrNull(json['status']),
        rejectReason: asStringOrNull(json['reject_reason']),
        createdAt: asDateTime(json['created_at']),
      );
}

/// `POST /sellers/{id}/kyc_upload` -> 201.
class KycUploadResult {
  const KycUploadResult({required this.kycDocumentId, required this.status});

  final int kycDocumentId;
  final String status;

  factory KycUploadResult.fromJson(Map<String, dynamic> json) =>
      KycUploadResult(
        kycDocumentId: asInt(json['kyc_document_id']),
        status: asString(json['status'], fallback: 'PENDING'),
      );
}
