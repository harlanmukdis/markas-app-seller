import '../../data/datasources/remote/service/report_service.dart'
    show FinanceSummary;
import '../../data_state.dart';
import '../model/report/reports.dart';

abstract class ReportRepository {
  Future<DataState<SellerPerformance>> getSellerPerformance();

  Future<DataState<List<SalesReportRow>>> getSales({
    String? from,
    String? to,
    int? categoryId,
  });

  Future<DataState<List<StockReportRow>>> getStock({int? warehouseId});

  Future<DataState<FinanceSummary>> getFinanceSummary({
    String? from,
    String? to,
  });

  Future<DataState<List<Pph22ReportRow>>> getPph22({String? from, String? to});
}
