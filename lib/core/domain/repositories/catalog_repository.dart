import '../../data_state.dart';
import '../model/catalog/category.dart';
import '../model/catalog/product.dart';

/// Categories, products and variants, as the seller app needs them.
abstract class CatalogRepository {
  /// The category tree. Ids move between seeds, so this is read rather than
  /// cached across sessions.
  Future<DataState<List<Category>>> getCategories();

  /// The store's own catalogue, drafts included — every page of it. The
  /// endpoint sends no `meta` but still caps each response at 20 rows, so a
  /// single request silently truncates.
  Future<DataState<List<Product>>> getStoreProducts(int storeId);

  Future<DataState<Product>> getProduct(int productId);

  /// Returns the new product's id. It is created `draft`.
  Future<DataState<int>> createProduct(
    int storeId, {
    required String name,
    required int categoryId,
    required int basePrice,
    String productType,
    String? description,
    int? weightGrams,
  });

  /// Each of these returns the product as the server holds it afterwards — the
  /// writes themselves answer with nothing.
  Future<DataState<Product>> updateProduct(
    int productId, {
    String? name,
    String? description,
    int? basePrice,
    int? compareAtPrice,
    int? weightGrams,
    String? status,
  });

  Future<DataState<Product>> createVariant(
    int productId, {
    required String sku,
    required int price,
    Map<String, dynamic> options,
    int? weightGrams,
    String? imageUrl,
  });

  Future<DataState<Product>> updateVariant(
    int productId,
    int variantId, {
    String? sku,
    int? price,
    int? weightGrams,
    String? imageUrl,
    bool? isActive,
    Map<String, dynamic>? options,
  });
}
