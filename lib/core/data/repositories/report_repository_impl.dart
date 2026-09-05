import '../../data_state.dart';
import '../../domain/model/report/reports.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/remote/service/report_service.dart';
import 'repository_guard.dart';

class ReportRepositoryImpl with RepositoryGuard implements ReportRepository {
  const ReportRepositoryImpl(this._service);

  final ReportService _service;

  @override
  Future<DataState<SellerPerformance>> getSellerPerformance() =>
      guard(() => _service.getSellerPerformance());

  @override
  Future<DataState<List<SalesReportRow>>> getSales({
    String? from,
    String? to,
    int? categoryId,
  }) =>
      guard(() => _service.getSales(
            from: from,
            to: to,
            categoryId: categoryId,
          ));

  @override
  Future<DataState<List<StockReportRow>>> getStock({int? warehouseId}) =>
      guard(() => _service.getStock(warehouseId: warehouseId));

  @override
  Future<DataState<FinanceSummary>> getFinanceSummary({
    String? from,
    String? to,
  }) =>
      guard(() => _service.getFinanceSummary(from: from, to: to));

  @override
  Future<DataState<List<Pph22ReportRow>>> getPph22({
    String? from,
    String? to,
  }) =>
      guard(() => _service.getPph22(from: from, to: to));
}
