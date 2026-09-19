import '../../../utils/json_parse.dart';

/// A running flash sale, as `GET /products/{id}` reports it.
///
/// It appears at **two levels, with two different conventions** — a trap worth
/// knowing before reading either:
///
/// * On the product, `flash_sale` is an **optional key**: absent entirely when
///   no sale is running, never `null`. It is an aggregate across variants.
/// * On each variant, `variants[i].flash_sale` is **always present** and is
///   `null` when that variant is not discounted.
///
/// For a product with several variants the per-variant value is the honest one:
/// the aggregate would show a discounted price against variants that are not
/// actually discounted. Added by the backend in v1.1.0 for exactly that reason.
class FlashSaleInfo {
  const FlashSaleInfo({
    required this.flashPrice,
    this.soldCount = 0,
    this.stockQuota = 0,
    this.endsAt,
  });

  final int flashPrice;
  final int soldCount;
  final int stockQuota;
  final DateTime? endsAt;

  factory FlashSaleInfo.fromJson(Map<String, dynamic> json) => FlashSaleInfo(
        flashPrice: asInt(json['flash_price']),
        soldCount: asInt(json['sold_count']),
        stockQuota: asInt(json['stock_quota']),
        endsAt: asDateTime(json['ends_at']),
      );

  /// Null-safe read for both conventions: a missing key and an explicit null
  /// mean the same thing — no sale.
  static FlashSaleInfo? maybeFrom(dynamic value) {
    final map = asMapOrNull(value);
    if (map == null || map.isEmpty) return null;
    return FlashSaleInfo.fromJson(map);
  }

  int get remainingQuota =>
      stockQuota - soldCount < 0 ? 0 : stockQuota - soldCount;
}
