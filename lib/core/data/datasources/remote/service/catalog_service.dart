import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/catalog/category.dart';
import '../../../../domain/model/catalog/product.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

/// Categories, products and variants.
///
/// Two rules shape almost everything here. **No write returns what it wrote** —
/// a `POST` answers `{id}` and a `PATCH` answers nothing — so every mutation
/// that a screen needs the result of ends with a read. And **the seller's list
/// is not the public one**: `GET /products` hides drafts, so a store's own
/// catalogue has to come from `GET /stores/{id}/products`.
class CatalogService extends BaseService {
  const CatalogService(super.dio);

  /// The category tree, parents carrying `children`.
  Future<List<Category>> getCategories() async {
    final envelope = await getRequest(ApiEndpoints.categories);
    return envelope.list.map(Category.fromJson).toList(growable: false);
  }

  /// One page of the store's own catalogue, drafts included.
  ///
  /// The response is a bare array with **no `meta`**, which makes this endpoint
  /// easy to misread: it looks unpaged, but it is capped at 20 rows like every
  /// other list. A single call therefore returns a truncated catalogue with
  /// nothing to say so. Use [getAllStoreProducts] unless you are deliberately
  /// paging by hand.
  Future<List<Product>> getStoreProducts(int storeId, {int page = 1}) async {
    final envelope = await getRequest(
      ApiEndpoints.storeProducts(storeId),
      query: <String, dynamic>{'page': page},
    );
    return envelope.list.map(Product.fromJson).toList(growable: false);
  }

  /// The whole catalogue, walked page by page.
  ///
  /// With no total to page against, a short page is the only end-of-list
  /// signal. [maxPages] is a stop so a server that ignored `page` — and so
  /// answered a full page forever — could not spin here indefinitely.
  Future<List<Product>> getAllStoreProducts(
    int storeId, {
    int maxPages = 25,
  }) async {
    const int pageSize = 20;
    final products = <Product>[];

    for (var page = 1; page <= maxPages; page++) {
      final batch = await getStoreProducts(storeId, page: page);
      products.addAll(batch);
      if (batch.length < pageSize) break;
    }

    return List<Product>.unmodifiable(products);
  }

  /// The full row: variants, images, stock, compare-at price, and a
  /// `flash_sale` block while one is running.
  Future<Product> getProduct(int productId) async {
    final envelope = await getRequest(ApiEndpoints.product(productId));
    return Product.fromJson(envelope.map);
  }

  /// Answers `{ "id": N }`. The product is created `draft`, and the server also
  /// generates a default variant for it — see [ProductVariant].
  Future<int> createProduct(
    int storeId, {
    required String name,
    required int categoryId,
    required int basePrice,
    String productType = ProductType.physical,
    String? description,
    int? weightGrams,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.storeProducts(storeId),
      body: <String, dynamic>{
        'name': name,
        'category_id': categoryId,
        'product_type': productType,
        'description': description,
        'base_price': basePrice,
        'weight_grams': weightGrams,
      },
    );
    return asInt(envelope.map['id']);
  }

  /// Patches and re-reads, because the patch itself answers `data: null`.
  ///
  /// Only the fields passed are sent — the caller can flip `status` alone
  /// without restating the whole product. The server's whitelist is `name`,
  /// `description`, `base_price`, `compare_at_price`, `weight_grams`,
  /// `status`: **`category_id` and `product_type` are not updatable**, so both
  /// are settled at creation.
  ///
  /// Publishing can be refused with `CERTIFICATION_REQUIRED` — some categories
  /// need a verified certificate before a product in them may go active.
  Future<Product> updateProduct(
    int productId, {
    String? name,
    String? description,
    int? basePrice,
    int? compareAtPrice,
    int? weightGrams,
    String? status,
  }) async {
    await patchRequest(
      ApiEndpoints.product(productId),
      body: <String, dynamic>{
        'name': name,
        'description': description,
        'base_price': basePrice,
        'compare_at_price': compareAtPrice,
        'weight_grams': weightGrams,
        'status': status,
      },
    );
    return getProduct(productId);
  }

  /// Adds a variant and returns the product as it stands afterwards, so the
  /// caller sees the new row alongside the generated default.
  ///
  /// `variant_options` is sent as a real object; the server stores it as a JSON
  /// string and hands it back that way.
  Future<Product> createVariant(
    int productId, {
    required String sku,
    required int price,
    Map<String, dynamic> options = const <String, dynamic>{},
    int? weightGrams,
    String? imageUrl,
  }) async {
    await postRequest(
      ApiEndpoints.productVariants(productId),
      body: <String, dynamic>{
        'sku': sku,
        'price': price,
        'weight_grams': weightGrams,
        'image_url': imageUrl,
        if (options.isNotEmpty) 'variant_options': options,
      },
    );
    return getProduct(productId);
  }

  Future<Product> updateVariant(
    int productId,
    int variantId, {
    String? sku,
    int? price,
    int? weightGrams,
    String? imageUrl,
    bool? isActive,
    Map<String, dynamic>? options,
  }) async {
    await patchRequest(
      ApiEndpoints.productVariant(productId, variantId),
      body: <String, dynamic>{
        'sku': sku,
        'price': price,
        'weight_grams': weightGrams,
        'image_url': imageUrl,
        'is_active': isActive == null ? null : (isActive ? 1 : 0),
        'variant_options': options,
      },
    );
    return getProduct(productId);
  }
}
