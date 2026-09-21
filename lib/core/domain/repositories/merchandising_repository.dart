import '../../data/datasources/remote/service/merchandising_service.dart'
    show BundleItemDraft;
import '../../data_state.dart';
import '../model/merchandising/product_bundle.dart';
import '../model/merchandising/store_showcase.dart';

/// Bundles and showcases — the two ways a seller groups products.
abstract class MerchandisingRepository {
  /// List rows carry no items; use [getBundle] for contents.
  Future<DataState<List<ProductBundle>>> getStoreBundles(int storeId);

  /// Fails with `BUNDLE_NOT_FOUND` for an inactive bundle, even the caller's
  /// own — the endpoint is active-only.
  Future<DataState<ProductBundle>> getBundle(int bundleId);

  Future<DataState<List<ProductBundle>>> createBundle(
    int storeId, {
    required String name,
    required int bundlePrice,
    required List<BundleItemDraft> items,
    String status,
  });

  Future<DataState<List<ProductBundle>>> updateBundle(
    int storeId,
    int bundleId, {
    String? name,
    int? bundlePrice,
    String? status,
  });

  Future<DataState<List<StoreShowcase>>> getStoreShowcases(int storeId);

  Future<DataState<List<StoreShowcase>>> createShowcase(
    int storeId, {
    required String name,
    int sortOrder,
  });

  Future<DataState<List<StoreShowcase>>> updateShowcase(
    int storeId,
    int showcaseId, {
    String? name,
    int? sortOrder,
  });

  Future<DataState<List<StoreShowcase>>> deleteShowcase(
    int storeId,
    int showcaseId,
  );

  /// Active products only — a draft in the showcase will not appear.
  Future<DataState<List<ShowcaseProduct>>> getShowcaseProducts(
    int showcaseId, {
    int page,
  });

  Future<DataState<List<ShowcaseProduct>>> addShowcaseProduct(
    int showcaseId, {
    required int productId,
  });

  Future<DataState<List<ShowcaseProduct>>> removeShowcaseProduct(
    int showcaseId,
    int productId,
  );
}
