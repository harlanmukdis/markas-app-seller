import '../../../utils/json_parse.dart';
import 'activation_gates.dart';

/// `GET /sellers/{id}` — the onboarding dashboard's primary payload.
class SellerModel {
  const SellerModel({
    required this.id,
    required this.name,
    this.ownerUserId,
    this.slug,
    this.legalName,
    this.npwp,
    this.nibSiupNo,
    this.isOfficialStore = false,
    this.sellerType,
    this.pkpStatus,
    this.pkpEffectiveDate,
    this.status,
    this.kycApprovedAt,
    this.bankVerifiedAt,
    this.agreementSignedAt,
    this.trialStartedAt,
    this.trialMaxOrderValue,
    this.trialHoldDaysOverride,
    this.netSettledTxCount = 0,
    this.score = 0,
    this.pph22Exempt = false,
    this.activationGates = const ActivationGates(),
  });

  final int id;
  final String name;
  final int? ownerUserId;
  final String? slug;
  final String? legalName;
  final String? npwp;
  final String? nibSiupNo;
  final bool isOfficialStore;
  final String? sellerType;
  final String? pkpStatus;
  final DateTime? pkpEffectiveDate;
  final String? status;
  final DateTime? kycApprovedAt;
  final DateTime? bankVerifiedAt;
  final DateTime? agreementSignedAt;
  final DateTime? trialStartedAt;

  /// Trial-period ceiling on a single order's value. Null once the store is out
  /// of its trial. Worth showing — it explains rejected large orders.
  final int? trialMaxOrderValue;

  /// Longer payout hold while on trial, in days. Also worth showing: it is the
  /// reason a new store's money sits in `held` longer than the documented T+3.
  final int? trialHoldDaysOverride;

  final int netSettledTxCount;

  /// Starts at 100. Drops 2 for rejecting a sub-order, 3 for a confirmation or
  /// fleet-handover timeout, and feeds search ranking (API doc 6.8).
  final double score;

  final bool pph22Exempt;
  final ActivationGates activationGates;

  factory SellerModel.fromJson(Map<String, dynamic> json) => SellerModel(
        id: asInt(json['id']),
        name: asString(json['name']),
        ownerUserId: asIntOrNull(json['owner_user_id']),
        slug: asStringOrNull(json['slug']),
        legalName: asStringOrNull(json['legal_name']),
        npwp: asStringOrNull(json['npwp']),
        nibSiupNo: asStringOrNull(json['nib_siup_no']),
        isOfficialStore: asBool(json['is_official_store']),
        sellerType: asStringOrNull(json['seller_type']),
        pkpStatus: asStringOrNull(json['pkp_status']),
        pkpEffectiveDate: asDateTime(json['pkp_effective_date']),
        status: asStringOrNull(json['status']),
        kycApprovedAt: asDateTime(json['kyc_approved_at']),
        bankVerifiedAt: asDateTime(json['bank_verified_at']),
        agreementSignedAt: asDateTime(json['agreement_signed_at']),
        trialStartedAt: asDateTime(json['trial_started_at']),
        trialMaxOrderValue: asIntOrNull(json['trial_max_order_value']),
        trialHoldDaysOverride: asIntOrNull(json['trial_hold_days_override']),
        netSettledTxCount: asInt(json['net_settled_tx_count']),
        score: asDouble(json['score']),
        pph22Exempt: asBool(json['pph22_exempt']),
        activationGates: ActivationGates.fromJson(
          asMap(json['activation_gates']),
        ),
      );

  bool get isOnTrial =>
      trialMaxOrderValue != null || trialHoldDaysOverride != null;
}
