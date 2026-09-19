import '../../../utils/json_parse.dart';

/// One row of `GET /flash-sales/{id}/products`.
///
/// The endpoint is **public** — no token needed — because buyers read it to
/// render the sale. It joins enough to draw a card on its own (`sku`,
/// `product_name`, `original_price`, `product_id`, `image_url` were all added
/// in v1.1.0), so listing a sale's contents costs one call rather than an N+1.
///
/// There is no `DELETE`: a variant added to a sale stays in it.
class FlashSaleProduct {
  const FlashSaleProduct({
    required this.id,
    required this.flashSaleId,
    required this.productVariantId,
    this.flashPrice = 0,
    this.stockQuota = 0,
    this.soldCount = 0,
    this.maxQtyPerUser = 1,
    this.sku = '',
    this.originalPrice = 0,
    this.productId,
    this.productName = '',
    this.imageUrl,
  });

  final int id;
  final int flashSaleId;
  final int productVariantId;

  final int flashPrice;

  /// How many units the sale may move, **separate from warehouse stock**.
  /// Nothing reconciles the two, so a quota larger than what is on hand is
  /// accepted and oversells.
  final int stockQuota;

  final int soldCount;
  final int maxQtyPerUser;

  final String sku;

  /// The variant's ordinary price, joined from `product_variants.price`.
  final int originalPrice;

  final int? productId;
  final String productName;
  final String? imageUrl;

  factory FlashSaleProduct.fromJson(Map<String, dynamic> json) =>
      FlashSaleProduct(
        id: asInt(json['id']),
        flashSaleId: asInt(json['flash_sale_id']),
        productVariantId: asInt(json['product_variant_id']),
        flashPrice: asInt(json['flash_price']),
        stockQuota: asInt(json['stock_quota']),
        soldCount: asInt(json['sold_count']),
        maxQtyPerUser: asInt(json['max_qty_per_user'], fallback: 1),
        sku: asString(json['sku']),
        originalPrice: asInt(json['original_price']),
        productId: asIntOrNull(json['product_id']),
        productName: asString(json['product_name']),
        imageUrl: asStringOrNull(json['image_url']),
      );

  int get remainingQuota {
    final left = stockQuota - soldCount;
    return left < 0 ? 0 : left;
  }

  bool get isSoldOut => stockQuota > 0 && soldCount >= stockQuota;

  /// Rounded down, so the badge never overstates the discount.
  ///
  /// Zero when the flash price is not actually lower — the server accepts a
  /// `flash_price` above the variant's own price without complaint.
  int get discountPercent {
    if (originalPrice <= 0 || flashPrice >= originalPrice) return 0;
    return ((originalPrice - flashPrice) * 100 ~/ originalPrice);
  }

  bool get isDiscounted => flashPrice < originalPrice;
}
