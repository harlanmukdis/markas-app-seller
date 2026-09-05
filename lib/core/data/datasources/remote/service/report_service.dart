import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/finance/finance.dart';
import '../../../../utils/json_parse.dart';
import '../../../../domain/model/report/reports.dart';
import 'base_service.dart';

/// Every endpoint here is scoped to this store automatically with a `SEL`
/// token — a `seller_id` parameter is ignored and overwritten (API doc 5.15).
class ReportService extends BaseService {
  const ReportService(super.dio);

  Future<SellerPerformance> getSellerPerformance() async {
    final envelope = await getRequest(ApiEndpoints.reportSellerPerformance);
    return SellerPerformance.fromJson(envelope.map);
  }

  /// [from] and [to] are `YYYY-MM-DD`; the default window is the last 30 days.
  Future<List<SalesReportRow>> getSales({
    String? from,
    String? to,
    int? categoryId,
  }) async {
    final envelope = await getRequest(
      ApiEndpoints.reportSales,
      query: <String, dynamic>{
        'from': from,
        'to': to,
        'category_id': categoryId,
      },
    );
    return envelope
        .listAt('sales')
        .map(SalesReportRow.fromJson)
        .toList(growable: false);
  }

  Future<List<StockReportRow>> getStock({int? warehouseId}) async {
    final envelope = await getRequest(
      ApiEndpoints.reportStock,
      query: <String, dynamic>{'warehouse_id': warehouseId},
    );
    return envelope
        .listAt('stock')
        .map(StockReportRow.fromJson)
        .toList(growable: false);
  }

  /// Returns `{ ledger: [], payouts: [] }`.
  Future<FinanceSummary> getFinanceSummary({String? from, String? to}) async {
    final envelope = await getRequest(
      ApiEndpoints.reportFinanceSummary,
      query: <String, dynamic>{'from': from, 'to': to},
    );
    final body = envelope.map;
    return FinanceSummary(
      ledger: asModelList(body['ledger'], LedgerEntry.fromJson),
      payouts: asModelList(body['payouts'], Payout.fromJson),
    );
  }

  Future<List<Pph22ReportRow>> getPph22({String? from, String? to}) async {
    final envelope = await getRequest(
      ApiEndpoints.reportPph22,
      query: <String, dynamic>{'from': from, 'to': to},
    );
    return envelope
        .listAt('pph22')
        .map(Pph22ReportRow.fromJson)
        .toList(growable: false);
  }
}

class FinanceSummary {
  const FinanceSummary({required this.ledger, required this.payouts});

  final List<LedgerEntry> ledger;
  final List<Payout> payouts;
}
