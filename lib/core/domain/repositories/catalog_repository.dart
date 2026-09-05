import '../../data_state.dart';
import '../model/catalog/category.dart';
import '../model/catalog/sku_master.dart';
import '../model/catalog/sku_request.dart';

abstract class CatalogRepository {
  Future<DataState<List<Category>>> getCategories({bool forceRefresh});

  Future<DataState<List<SkuMaster>>> searchSkuMaster({
    String? query,
    int? categoryId,
  });

  Future<DataState<SkuMaster>> getSkuMaster(int skuId);

  Future<DataState<Map<int, SkuMaster>>> getSkuMasterBatch(
    Iterable<int> skuIds,
  );

  Future<DataState<List<SkuRequest>>> getSkuRequests({String? status});

  /// Succeeds with either [SkuRequestCreated] or [SkuRequestSimilarFound] —
  /// the latter means nothing was saved.
  Future<DataState<SkuRequestResult>> createSkuRequest({
    required int categoryId,
    required String proposedName,
    String? proposedBrand,
    double? proposedWeightKg,
    Map<String, dynamic>? proposedDimensions,
    bool force,
  });

  Future<DataState<bool>> withdrawSkuRequest(int id);

  Future<DataState<bool>> resubmitSkuRequest(int id);
}
