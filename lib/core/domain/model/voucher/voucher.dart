import '../../../utils/json_parse.dart';

/// A store voucher.
///
/// `funded_by` is forced to SELLER for a `SEL` token — a store cannot create a
/// platform-funded voucher. The cost comes straight out of the payout as
/// `voucher_seller_burden`, so the impact should be obvious while creating it.
class Voucher {
  const Voucher({
    required this.id,
    required this.code,
    this.discountType,
    this.discountValue = 0,
    this.maxDiscountAmount,
    this.minSpend,
    this.quotaTotal = 0,
    this.quotaUsed = 0,
    this.quotaPerUser = 1,
    this.validFrom,
    this.validTo,
    this.status,
    this.fundedBy,
  });

  final int id;
  final String code;
  final String? discountType;
  final double discountValue;

  /// Important for PERCENT vouchers — without it the burden is unbounded.
  final int? maxDiscountAmount;

  final int? minSpend;
  final int quotaTotal;
  final int quotaUsed;
  final int quotaPerUser;
  final DateTime? validFrom;
  final DateTime? validTo;
  final String? status;
  final String? fundedBy;

  factory Voucher.fromJson(Map<String, dynamic> json) => Voucher(
        id: asInt(json['id']),
        code: asString(json['code']),
        discountType: asStringOrNull(json['discount_type']),
        discountValue: asDouble(json['discount_value']),
        maxDiscountAmount: asIntOrNull(json['max_discount_amount']),
        minSpend: asIntOrNull(json['min_spend']),
        quotaTotal: asInt(json['quota_total']),
        quotaUsed: asInt(json['quota_used']),
        quotaPerUser: asInt(json['quota_per_user'], fallback: 1),
        validFrom: asDateTime(json['valid_from']),
        validTo: asDateTime(json['valid_to']),
        status: asStringOrNull(json['status']),
        fundedBy: asStringOrNull(json['funded_by']),
      );

  bool get isPercent => discountType == VoucherDiscountType.percent;

  int get quotaRemaining => (quotaTotal - quotaUsed).clamp(0, quotaTotal);

  /// Worst-case cost to the store if the whole quota is used.
  int worstCaseBurden() {
    if (isPercent) {
      final cap = maxDiscountAmount;
      if (cap == null) return -1; // unbounded
      return cap * quotaTotal;
    }
    return discountValue.round() * quotaTotal;
  }
}

abstract class VoucherDiscountType {
  static const String nominal = 'NOMINAL';
  static const String percent = 'PERCENT';

  static const List<String> all = <String>[nominal, percent];

  static String label(String? type) => switch (type) {
        nominal => 'Nominal (Rp)',
        percent => 'Persen (%)',
        _ => type ?? '-',
      };
}
