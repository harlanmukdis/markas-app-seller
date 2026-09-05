import '../../../utils/json_parse.dart';
import 'sku_master.dart';

/// A request for the catalogue team to create a master SKU.
class SkuRequest {
  const SkuRequest({
    required this.id,
    required this.proposedName,
    this.categoryId,
    this.proposedBrand,
    this.proposedWeightKg,
    this.status,
    this.rejectReason,
    this.deadline1x24,
    this.deadline3x24,
    this.createdAt,
  });

  final int id;
  final String proposedName;
  final int? categoryId;
  final String? proposedBrand;
  final double? proposedWeightKg;
  final String? status;
  final String? rejectReason;

  /// Target for the catalogue team's answer.
  final DateTime? deadline1x24;

  /// After this, the product goes live automatically as a temporary listing
  /// (CAT-05) — though the cron that does it is not scheduled yet (API doc 8).
  final DateTime? deadline3x24;

  final DateTime? createdAt;

  factory SkuRequest.fromJson(Map<String, dynamic> json) => SkuRequest(
        id: asInt(json['id']),
        proposedName: asString(json['proposed_name']),
        categoryId: asIntOrNull(json['category_id']),
        proposedBrand: asStringOrNull(json['proposed_brand']),
        proposedWeightKg: asDoubleOrNull(json['proposed_weight_kg']),
        status: asStringOrNull(json['status']),
        rejectReason: asStringOrNull(json['reject_reason']),
        deadline1x24: asDateTime(json['deadline_1x24']),
        deadline3x24: asDateTime(json['deadline_3x24']),
        createdAt: asDateTime(json['created_at']),
      );

  bool get canWithdraw => status == SkuRequestStatus.diajukan ||
      status == SkuRequestStatus.duplikatDisarankan;

  bool get canResubmit => status == SkuRequestStatus.duplikatDisarankan;
}

/// The result of `POST /sku-requests`, which has two very different meanings
/// behind the same HTTP 200.
///
/// When the server finds similar SKUs it answers **200** with
/// `similar_found: true` and a list — **nothing was created**. Branching on the
/// status code instead of on this flag is the documented way to get this wrong
/// (CAT-04). Resubmit with `force: true` to override.
sealed class SkuRequestResult {
  const SkuRequestResult();

  factory SkuRequestResult.fromJson(Map<String, dynamic> json) {
    if (asBool(json['similar_found'])) {
      return SkuRequestSimilarFound(
        similar: asModelList(json['similar'], SkuMaster.fromJson),
        hint: asStringOrNull(json['hint']),
      );
    }
    return SkuRequestCreated(id: asInt(json['id']));
  }
}

/// Nothing was saved. Show the candidates and let the store either pick one or
/// resubmit with `force`.
final class SkuRequestSimilarFound extends SkuRequestResult {
  const SkuRequestSimilarFound({required this.similar, this.hint});

  final List<SkuMaster> similar;
  final String? hint;
}

final class SkuRequestCreated extends SkuRequestResult {
  const SkuRequestCreated({required this.id});

  final int id;
}

abstract class SkuRequestStatus {
  static const String diajukan = 'DIAJUKAN';
  static const String duplikatDisarankan = 'DUPLIKAT_DISARANKAN';
  static const String disetujui = 'DISETUJUI';
  static const String ditolak = 'DITOLAK';
  static const String ditarik = 'DITARIK';
  static const String listingSementara = 'LISTING_SEMENTARA';
  static const String digabung = 'DIGABUNG';

  static String label(String? status) => switch (status) {
        diajukan => 'Diajukan',
        duplikatDisarankan => 'Duplikat disarankan',
        disetujui => 'Disetujui',
        ditolak => 'Ditolak',
        ditarik => 'Ditarik',
        listingSementara => 'Listing sementara',
        digabung => 'Digabung',
        _ => status ?? '-',
      };
}
