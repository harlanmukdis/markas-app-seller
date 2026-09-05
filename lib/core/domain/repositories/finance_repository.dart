import '../../data_state.dart';
import '../model/finance/finance.dart';

abstract class FinanceRepository {
  Future<DataState<SellerBalance>> getBalance();

  Future<DataState<List<LedgerEntry>>> getLedger({int limit, int offset});

  /// Submitted for Admin Finance approval, never immediately paid.
  Future<DataState<WithdrawalRequest>> withdraw({
    required int amount,
    required int bankAccountId,
  });

  Future<DataState<List<Map<String, dynamic>>>> getInvoices({
    int? orderId,
    int? shipmentId,
  });

  Future<DataState<List<Map<String, dynamic>>>> getTaxInvoices({
    required int shipmentId,
  });

  Future<DataState<List<ConfigParameter>>> getConfigParameters({String? group});
}
