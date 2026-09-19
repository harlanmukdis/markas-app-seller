import '../../../utils/format_helper.dart';
import '../../../utils/json_parse.dart';

/// One row of `GET /stores/{id}/vouchers`.
///
/// The seller surface here is **create and list, nothing else**: there is no
/// `PATCH` and no `DELETE` on this path (both answer `405 Unknown method`), so
/// a voucher cannot be edited, paused or withdrawn once it exists. The only way
/// to stop one is to let it run out of quota or out of window.
class StoreVoucher {
  const StoreVoucher({
    required this.id,
    required this.code,
    required this.name,
    this.storeId,
    this.discountType = VoucherDiscountType.fixed,
    this.discountValue = 0,
    this.maxDiscount,
    this.minSpend = 0,
    this.quota = 0,
    this.usedCount = 0,
    this.maxUsePerUser = 1,
    this.validFrom,
    this.validUntil,
    this.status = VoucherStatus.active,
  });

  final int id;

  /// Assigned by the server as `VC-XXXXXXXX` unless the seller supplied one.
  /// The column is `UNIQUE` across the **whole platform**, and a collision is
  /// an unhandled `500`, not a 409 — which is why letting the server pick is
  /// the safer default.
  final String code;

  final String name;

  /// Null on a platform-wide voucher. A store's own list never contains those.
  final int? storeId;

  final String discountType;

  /// A **percentage** when [discountType] is `percentage`, otherwise rupiah.
  /// The server bounds neither: `discount_value: 500` on a percentage voucher
  /// is accepted with a 201.
  final int discountValue;

  /// Only meaningful for a percentage voucher — the cap on what it takes off.
  final int? maxDiscount;

  final int minSpend;
  final int quota;
  final int usedCount;
  final int maxUsePerUser;

  final DateTime? validFrom;
  final DateTime? validUntil;

  /// The column exists with `active` / `inactive` / `expired`, but **no code
  /// anywhere writes it** — there is no endpoint and no worker. It is `active`
  /// from creation forever, so it says nothing about whether the voucher can
  /// actually be used. [phase] is the figure to trust.
  final String status;

  factory StoreVoucher.fromJson(Map<String, dynamic> json) => StoreVoucher(
        id: asInt(json['id']),
        code: asString(json['code']),
        name: asString(json['name']),
        storeId: asIntOrNull(json['store_id']),
        // Read with no fallback on purpose. The server coerces an
        // unrecognised type to `''` and stores it, and substituting a real
        // type here would relabel a voucher that discounts nothing as a
        // working one — the empty string has to survive so the UI can say so.
        discountType: asString(json['discount_type']),
        discountValue: asInt(json['discount_value']),
        maxDiscount: asIntOrNull(json['max_discount']),
        minSpend: asInt(json['min_spend']),
        quota: asInt(json['quota']),
        usedCount: asInt(json['used_count']),
        maxUsePerUser: asInt(json['max_use_per_user'], fallback: 1),
        validFrom: asDateTime(json['valid_from']),
        validUntil: asDateTime(json['valid_until']),
        status: asString(json['status'], fallback: VoucherStatus.active),
      );

  int get remainingQuota {
    final left = quota - usedCount;
    return left < 0 ? 0 : left;
  }

  bool get isExhausted => quota > 0 && usedCount >= quota;

  /// Whether a buyer can redeem this right now.
  ///
  /// Derived from the window and the quota rather than from [status], because
  /// those are the three things `Promotion_model::validate_for_user` actually
  /// checks — and [status] is never updated by anything.
  ///
  /// Timestamps arrive as server wall-clock with no zone, so they are compared
  /// against local `now`. In this deployment both are Asia/Jakarta.
  VoucherPhase phaseAt(DateTime now) {
    if (status != VoucherStatus.active) return VoucherPhase.inactive;
    if (validUntil != null && now.isAfter(validUntil!)) {
      return VoucherPhase.expired;
    }
    if (validFrom != null && now.isBefore(validFrom!)) {
      return VoucherPhase.scheduled;
    }
    if (isExhausted) return VoucherPhase.exhausted;
    return VoucherPhase.running;
  }

  VoucherPhase get phase => phaseAt(DateTime.now());

  /// `10%` / `Rp 15.000` / `Gratis ongkir`, as the seller wrote it.
  String get discountSummary => switch (discountType) {
        VoucherDiscountType.percentage => '$discountValue%',
        VoucherDiscountType.freeShipping => 'Gratis ongkir',
        _ => formatRupiah(discountValue),
      };
}

/// Where a voucher is in its life, worked out from the data rather than read
/// off `status`.
enum VoucherPhase { running, scheduled, expired, exhausted, inactive }

extension VoucherPhaseLabel on VoucherPhase {
  String get label => switch (this) {
        VoucherPhase.running => 'Berjalan',
        VoucherPhase.scheduled => 'Terjadwal',
        VoucherPhase.expired => 'Berakhir',
        VoucherPhase.exhausted => 'Kuota habis',
        VoucherPhase.inactive => 'Nonaktif',
      };
}

/// The `vouchers.discount_type` enum.
///
/// MySQL is not in strict mode here, so an unrecognised value is **not**
/// rejected: it is coerced to an empty string and stored, leaving a voucher
/// that can never discount anything. The closed list has to be enforced in the
/// form.
abstract class VoucherDiscountType {
  static const String percentage = 'percentage';
  static const String fixed = 'fixed';
  static const String freeShipping = 'free_shipping';

  /// Paid out through the reward engine as coins rather than taken off the
  /// bill, so the buyer still pays full price at checkout.
  static const String cashback = 'cashback';

  static const List<String> all = <String>[
    percentage,
    fixed,
    freeShipping,
    cashback,
  ];

  static String label(String? type) => switch (type) {
        percentage => 'Diskon persen',
        fixed => 'Potongan tetap',
        freeShipping => 'Gratis ongkir',
        cashback => 'Cashback (koin)',
        _ => type == null || type.isEmpty ? 'Tidak dikenali' : type,
      };
}

abstract class VoucherStatus {
  static const String active = 'active';
  static const String inactive = 'inactive';
  static const String expired = 'expired';
}
