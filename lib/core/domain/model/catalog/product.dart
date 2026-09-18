import '../../../utils/json_parse.dart';
import 'product_variant.dart';

/// A catalogue entry.
///
/// Two payloads produce one of these:
///
/// * `GET /stores/{id}/products` — the seller's own list, **drafts included**,
///   a bare array with no `meta`. Rows are the table only: no variants, images,
///   stock or couriers.
/// * `GET /products/{id}` — the full row, with [variants], [images], [stock]
///   and, while one is running, [flashSale].
///
/// A product is created `draft` and only sells once it is patched to `active`,
/// so [status] is the field the catalogue screen is really about.
class Product {
  const Product({
    required this.id,
    required this.name,
    this.storeId,
    this.slug,
    this.productType = ProductType.physical,
    this.description,
    this.basePrice = 0,
    this.compareAtPrice,
    this.weightGrams,
    this.status = ProductStatus.draft,
    this.soldCount = 0,
    this.viewCount = 0,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.stock,
    this.variants = const <ProductVariant>[],
    this.images = const <ProductImage>[],
    this.flashSale,
    this.createdAt,
  });

  final int id;
  final String name;
  final int? storeId;
  final String? slug;
  final String productType;
  final String? description;
  final int basePrice;

  /// The struck-through "was" price. Independent of a flash sale; both can be
  /// set at once.
  final int? compareAtPrice;

  final int? weightGrams;
  final String status;
  final int soldCount;
  final int viewCount;
  final double ratingAvg;
  final int ratingCount;

  /// Total `quantity_available` across every variant and warehouse. Detail
  /// payload only — null means "not in this payload", never "no stock".
  final int? stock;

  final List<ProductVariant> variants;

  /// Readable, but nothing in the app can add to it: the API exposes no write
  /// path for product images. A seller's own image goes on a variant instead.
  final List<ProductImage> images;

  /// Absent — not null — when no sale is running, so presence is the signal.
  final FlashSaleInfo? flashSale;

  final DateTime? createdAt;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: asInt(json['id']),
        name: asString(json['name']),
        storeId: asIntOrNull(json['store_id']),
        slug: asStringOrNull(json['slug']),
        productType:
            asString(json['product_type'], fallback: ProductType.physical),
        description: asStringOrNull(json['description']),
        basePrice: asInt(json['base_price']),
        compareAtPrice: asIntOrNull(json['compare_at_price']),
        weightGrams: asIntOrNull(json['weight_grams']),
        status: asString(json['status'], fallback: ProductStatus.draft),
        soldCount: asInt(json['sold_count']),
        viewCount: asInt(json['view_count']),
        ratingAvg: asDouble(json['rating_avg']),
        ratingCount: asInt(json['rating_count']),
        stock: asIntOrNull(json['stock']),
        variants: asModelList(json['variants'], ProductVariant.fromJson),
        images: asModelList(json['images'], ProductImage.fromJson),
        flashSale: json['flash_sale'] == null
            ? null
            : FlashSaleInfo.fromJson(asMap(json['flash_sale'])),
        createdAt: asCreatedDate(json),
      );

  bool get isActive => status == ProductStatus.active;
  bool get isDraft => status == ProductStatus.draft;

  /// The price a buyer would actually pay right now.
  int get effectivePrice => flashSale?.flashPrice ?? basePrice;

  /// Only the variants the seller made — the generated default is an artefact
  /// of creation rather than a choice, and listing it as a variant alongside
  /// real ones reads as a duplicate.
  List<ProductVariant> get authoredVariants =>
      variants.where((variant) => !variant.isGenerated).toList(growable: false);
}

/// A row of `product_images`. Read-only in practice: no endpoint writes one.
class ProductImage {
  const ProductImage({required this.id, required this.imageUrl, this.sortOrder = 0});

  final int id;
  final String imageUrl;
  final int sortOrder;

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
        id: asInt(json['id']),
        imageUrl: asString(json['image_url']),
        sortOrder: asInt(json['sort_order']),
      );
}

/// The `flash_sale` block product detail adds while a sale is live.
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

  int get remainingQuota =>
      stockQuota - soldCount < 0 ? 0 : stockQuota - soldCount;
}

abstract class ProductStatus {
  static const String draft = 'draft';
  static const String active = 'active';
  static const String inactive = 'inactive';
  static const String archived = 'archived';

  /// `archived` is reachable only by patching status: there is no delete
  /// endpoint, so it is the nearest thing to removing a product.
  static const List<String> all = <String>[draft, active, inactive, archived];

  static String label(String? status) => switch (status) {
        draft => 'Draf',
        active => 'Aktif',
        inactive => 'Nonaktif',
        archived => 'Diarsipkan',
        _ => status ?? '-',
      };
}

abstract class ProductType {
  static const String physical = 'physical';
  static const String digital = 'digital';
  static const String service = 'service';

  static const List<String> all = <String>[physical, digital, service];

  static String label(String? type) => switch (type) {
        physical => 'Barang fisik',
        digital => 'Produk digital',
        service => 'Jasa',
        _ => type ?? '-',
      };
}
