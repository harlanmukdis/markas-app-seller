import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/finance/finance.dart';
import 'base_service.dart';

/// A store can only **watch** its money here. `recognize` and `release` are
/// admin/cron only (API doc 5.9).
class FinanceService extends BaseService {
  const FinanceService(super.dio);

  Future<SellerBalance> getBalance() async {
    final envelope = await getRequest(ApiEndpoints.financeBalance);
    return SellerBalance.fromJson(envelope.map);
  }

  Future<List<LedgerEntry>> getLedger({int limit = 50, int offset = 0}) async {
    final envelope = await getRequest(
      ApiEndpoints.financeLedger,
      query: <String, dynamic>{'limit': limit, 'offset': offset},
    );
    return envelope
        .listAt('ledger')
        .map(LedgerEntry.fromJson)
        .toList(growable: false);
  }

  /// Needs Admin Finance approval, so the result is "submitted", not "paid".
  ///
  /// Fails with 409 when the account is not VERIFIED, 403 when it belongs to
  /// another store, and 422 below the minimum or above the available balance.
  Future<WithdrawalRequest> withdraw({
    required int amount,
    required int bankAccountId,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.financeWithdraw,
      body: <String, dynamic>{
        'amount': amount,
        'bank_account_id': bankAccountId,
      },
    );
    return WithdrawalRequest.fromJson(envelope.map);
  }

  Future<List<Map<String, dynamic>>> getInvoices({
    int? orderId,
    int? shipmentId,
  }) async {
    final envelope = await getRequest(
      ApiEndpoints.financeInvoices,
      query: <String, dynamic>{
        'order_id': orderId,
        'shipment_id': shipmentId,
      },
    );
    return envelope.listAt('invoices');
  }

  /// Only issued for a PKP store when the buyer supplied an NPWP, and issued
  /// per shipment (FIN-13).
  Future<List<Map<String, dynamic>>> getTaxInvoices({
    required int shipmentId,
  }) async {
    final envelope = await getRequest(
      ApiEndpoints.financeTaxInvoices,
      query: <String, dynamic>{'shipment_id': shipmentId},
    );
    return envelope.listAt('tax_invoices');
  }

  /// Live platform parameters, so thresholds like the withdrawal minimum are
  /// not hardcoded in the app.
  Future<List<ConfigParameter>> getConfigParameters({String? group}) async {
    final envelope = await getRequest(
      ApiEndpoints.configParameters,
      query: <String, dynamic>{'group': group},
    );
    return envelope
        .listAt('parameters')
        .map(ConfigParameter.fromJson)
        .toList(growable: false);
  }
}
