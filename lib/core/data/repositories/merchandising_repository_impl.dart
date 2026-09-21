import '../../data_state.dart';
import '../../domain/model/merchandising/product_bundle.dart';
import '../../domain/model/merchandising/store_showcase.dart';
import '../../domain/repositories/merchandising_repository.dart';
import '../datasources/remote/service/merchandising_service.dart';
import 'repository_guard.dart';

class MerchandisingRepositoryImpl
    with RepositoryGuard
    implements MerchandisingRepository {
  const MerchandisingRepositoryImpl(this._service);

  final MerchandisingService _service;

  @override
  Future<DataState<List<ProductBundle>>> getStoreBundles(int storeId) =>
      guard(() => _service.getStoreBundles(storeId));

  @override
  Future<DataState<ProductBundle>> getBundle(int bundleId) =>
      guard(() => _service.getBundle(bundleId));

  @override
  Future<DataState<List<ProductBundle>>> createBundle(
    int storeId, {
    required String name,
    required int bundlePrice,
    required List<BundleItemDraft> items,
    String status = BundleStatus.active,
  }) =>
      guard(() async {
        await _service.createBundle(
          storeId,
          name: name,
          bundlePrice: bundlePrice,
          items: items,
          status: status,
        );
        return _service.getStoreBundles(storeId);
      });

  @override
  Future<DataState<List<ProductBundle>>> updateBundle(
    int storeId,
    int bundleId, {
    String? name,
    int? bundlePrice,
    String? status,
  }) =>
      guard(() async {
        await _service.updateBundle(
          bundleId,
          name: name,
          bundlePrice: bundlePrice,
          status: status,
        );
        return _service.getStoreBundles(storeId);
      });

  @override
  Future<DataState<List<StoreShowcase>>> getStoreShowcases(int storeId) =>
      guard(() => _service.getStoreShowcases(storeId));

  @override
  Future<DataState<List<StoreShowcase>>> createShowcase(
    int storeId, {
    required String name,
    int sortOrder = 0,
  }) =>
      guard(() async {
        await _service.createShowcase(
          storeId,
          name: name,
          sortOrder: sortOrder,
        );
        return _service.getStoreShowcases(storeId);
      });

  @override
  Future<DataState<List<StoreShowcase>>> updateShowcase(
    int storeId,
    int showcaseId, {
    String? name,
    int? sortOrder,
  }) =>
      guard(() async {
        await _service.updateShowcase(
          showcaseId,
          name: name,
          sortOrder: sortOrder,
        );
        return _service.getStoreShowcases(storeId);
      });

  @override
  Future<DataState<List<StoreShowcase>>> deleteShowcase(
    int storeId,
    int showcaseId,
  ) =>
      guard(() async {
        await _service.deleteShowcase(showcaseId);
        return _service.getStoreShowcases(storeId);
      });

  @override
  Future<DataState<List<ShowcaseProduct>>> getShowcaseProducts(
    int showcaseId, {
    int page = 1,
  }) =>
      guard(() => _service.getShowcaseProducts(showcaseId, page: page));

  @override
  Future<DataState<List<ShowcaseProduct>>> addShowcaseProduct(
    int showcaseId, {
    required int productId,
  }) =>
      guard(() async {
        await _service.addShowcaseProduct(showcaseId, productId: productId);
        return _service.getShowcaseProducts(showcaseId);
      });

  @override
  Future<DataState<List<ShowcaseProduct>>> removeShowcaseProduct(
    int showcaseId,
    int productId,
  ) =>
      guard(() async {
        await _service.removeShowcaseProduct(showcaseId, productId);
        return _service.getShowcaseProducts(showcaseId);
      });
}
