import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/catalog/category.dart';
import '../../../../domain/model/catalog/sku_master.dart';
import '../../../../domain/model/catalog/sku_request.dart';
import 'base_service.dart';

/// Categories, master SKUs, and SKU requests.
class CatalogService extends BaseService {
  CatalogService(super.dio);

  /// Categories are platform reference data and do not change during a
  /// session, so they are held in memory after the first read.
  List<Category>? _categoriesCache;

  /// Master SKU lookups keyed by id, to avoid re-fetching the same SKU while
  /// rendering a list of offers that all point at it.
  final Map<int, SkuMaster> _skuCache = <int, SkuMaster>{};

  Future<List<Category>> getCategories({bool forceRefresh = false}) async {
    final cached = _categoriesCache;
    if (cached != null && !forceRefresh) return cached;

    final envelope = await getRequest(ApiEndpoints.categories);
    final categories = envelope
        .listAt('categories')
        .map(Category.fromJson)
        .toList(growable: false);
    _categoriesCache = categories;
    return categories;
  }

  /// One of [query] or [categoryId] is required by the backend.
  Future<List<SkuMaster>> searchSkuMaster({
    String? query,
    int? categoryId,
  }) async {
    final envelope = await getRequest(
      ApiEndpoints.skuMaster,
      query: <String, dynamic>{'q': query, 'category_id': categoryId},
    );
    return envelope
        .listAt('sku_master')
        .map(SkuMaster.fromJson)
        .toList(growable: false);
  }

  Future<SkuMaster> getSkuMaster(int skuId, {bool forceRefresh = false}) async {
    final cached = _skuCache[skuId];
    if (cached != null && !forceRefresh) return cached;

    final envelope = await getRequest(ApiEndpoints.skuMasterDetail(skuId));
    final sku = SkuMaster.fromJson(envelope.map);
    _skuCache[skuId] = sku;
    return sku;
  }

  /// Resolves several SKUs at once, in bounded batches rather than firing an
  /// unbounded number of concurrent requests.
  Future<Map<int, SkuMaster>> getSkuMasterBatch(Iterable<int> skuIds) async {
    final missing = skuIds.toSet().where((id) => !_skuCache.containsKey(id));

    const batchSize = 5;
    final pending = missing.toList();
    for (var i = 0; i < pending.length; i += batchSize) {
      final slice = pending.skip(i).take(batchSize);
      await Future.wait(slice.map((id) async {
        try {
          await getSkuMaster(id);
        } catch (_) {
          // One missing SKU should not fail the whole screen.
        }
      }));
    }

    return Map<int, SkuMaster>.fromEntries(
      skuIds.where(_skuCache.containsKey).map(
            (id) => MapEntry<int, SkuMaster>(id, _skuCache[id]!),
          ),
    );
  }

  Future<List<SkuRequest>> getSkuRequests({String? status}) async {
    final envelope = await getRequest(
      ApiEndpoints.skuRequests,
      query: <String, dynamic>{'status': status},
    );
    return envelope
        .listAt('sku_requests')
        .map(SkuRequest.fromJson)
        .toList(growable: false);
  }

  /// Two outcomes behind one HTTP 200 (CAT-04):
  /// [SkuRequestSimilarFound] means **nothing was created** and the store must
  /// either pick one of the returned SKUs or resubmit with `force: true`.
  Future<SkuRequestResult> createSkuRequest({
    required int categoryId,
    required String proposedName,
    String? proposedBrand,
    double? proposedWeightKg,
    Map<String, dynamic>? proposedDimensions,
    bool force = false,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.skuRequests,
      body: <String, dynamic>{
        'category_id': categoryId,
        'proposed_name': proposedName,
        'proposed_brand': proposedBrand,
        'proposed_weight_kg': proposedWeightKg,
        'proposed_dimensions_json': proposedDimensions,
        'force': force,
      },
    );
    return SkuRequestResult.fromJson(envelope.map);
  }

  Future<void> withdrawSkuRequest(int id) async {
    await postRequest(ApiEndpoints.skuRequestWithdraw(id));
  }

  Future<void> resubmitSkuRequest(int id) async {
    await postRequest(ApiEndpoints.skuRequestResubmit(id));
  }
}
