import '../../data_state.dart';
import '../../domain/model/catalog/category.dart';
import '../../domain/model/catalog/sku_master.dart';
import '../../domain/model/catalog/sku_request.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/remote/service/catalog_service.dart';
import 'repository_guard.dart';

class CatalogRepositoryImpl with RepositoryGuard implements CatalogRepository {
  const CatalogRepositoryImpl(this._service);

  final CatalogService _service;

  @override
  Future<DataState<List<Category>>> getCategories({
    bool forceRefresh = false,
  }) =>
      guard(() => _service.getCategories(forceRefresh: forceRefresh));

  @override
  Future<DataState<List<SkuMaster>>> searchSkuMaster({
    String? query,
    int? categoryId,
  }) =>
      guard(() => _service.searchSkuMaster(
            query: query,
            categoryId: categoryId,
          ));

  @override
  Future<DataState<SkuMaster>> getSkuMaster(int skuId) =>
      guard(() => _service.getSkuMaster(skuId));

  @override
  Future<DataState<Map<int, SkuMaster>>> getSkuMasterBatch(
    Iterable<int> skuIds,
  ) =>
      guard(() => _service.getSkuMasterBatch(skuIds));

  @override
  Future<DataState<List<SkuRequest>>> getSkuRequests({String? status}) =>
      guard(() => _service.getSkuRequests(status: status));

  @override
  Future<DataState<SkuRequestResult>> createSkuRequest({
    required int categoryId,
    required String proposedName,
    String? proposedBrand,
    double? proposedWeightKg,
    Map<String, dynamic>? proposedDimensions,
    bool force = false,
  }) =>
      guard(() => _service.createSkuRequest(
            categoryId: categoryId,
            proposedName: proposedName,
            proposedBrand: proposedBrand,
            proposedWeightKg: proposedWeightKg,
            proposedDimensions: proposedDimensions,
            force: force,
          ));

  @override
  Future<DataState<bool>> withdrawSkuRequest(int id) => guard(() async {
        await _service.withdrawSkuRequest(id);
        return true;
      });

  @override
  Future<DataState<bool>> resubmitSkuRequest(int id) => guard(() async {
        await _service.resubmitSkuRequest(id);
        return true;
      });
}
