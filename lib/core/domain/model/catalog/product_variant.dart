import '../../../utils/json_parse.dart';

/// One sellable row of a product.
///
/// **Every product has at least one.** The server generates a default variant
/// when the product is created — `SKU-<productId>-<hash>`, no options, price
/// copied from `base_price` — so a product with no real options still sells and
/// stocks through a variant. Adding one from the app makes a *second* row, and
/// the generated one stays unless it is edited instead.
class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.sku,
    this.productId,
    this.options = const <String, dynamic>{},
    this.price = 0,
    this.weightGrams,
    this.imageUrl,
    this.isActive = true,
    this.stock,
    this.warehouseCity,
    this.warehouseProvince,
  });

  final int id;
  final String sku;
  final int? productId;

  /// `variant_options` arrives as a **JSON string**, not an object, both nested
  /// in the product detail and joined onto warehouse stock rows.
  final Map<String, dynamic> options;

  final int price;
  final int? weightGrams;
  final String? imageUrl;
  final bool isActive;

  /// Present on `GET /products/{id}` only, and a real integer there while its
  /// neighbours are numeric strings. Null when the payload did not carry it.
  final int? stock;

  /// Where this variant would ship from: the warehouse holding **the most** of
  /// it, not a sum — cities differ per warehouse, so there is nothing to add
  /// up. Detail payload only, and null when no warehouse has any in stock.
  final String? warehouseCity;
  final String? warehouseProvince;

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: asInt(json['id']),
        sku: asString(json['sku']),
        productId: asIntOrNull(json['product_id']),
        options: asEncodedMap(json['variant_options']),
        price: asInt(json['price']),
        weightGrams: asIntOrNull(json['weight_grams']),
        imageUrl: asStringOrNull(json['image_url']),
        isActive: asBool(json['is_active'], fallback: true),
        stock: asIntOrNull(json['stock']),
        warehouseCity: asStringOrNull(json['warehouse_city']),
        warehouseProvince: asStringOrNull(json['warehouse_province']),
      );

  /// `Banda Aceh, Aceh` — empty when nothing is in stock anywhere.
  String get originLabel => <String?>[warehouseCity, warehouseProvince]
      .where((part) => part != null && part.isNotEmpty)
      .join(', ');

  /// `{color: red, size: L}` -> `red · L`, for a subtitle. Empty for the
  /// generated default variant, which carries no options at all.
  String get optionsLabel =>
      options.values.map((value) => '$value').join(' · ');

  /// True for the row the server generated on create: no options, and a SKU it
  /// named itself.
  bool get isGenerated => options.isEmpty && sku.startsWith('SKU-');
}
