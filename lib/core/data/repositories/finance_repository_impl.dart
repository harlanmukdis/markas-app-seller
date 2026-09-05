import '../../data_state.dart';
import '../../domain/model/finance/finance.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/remote/service/finance_service.dart';
import 'repository_guard.dart';

class FinanceRepositoryImpl with RepositoryGuard implements FinanceRepository {
  const FinanceRepositoryImpl(this._service);

  final FinanceService _service;

  @override
  Future<DataState<SellerBalance>> getBalance() =>
      guard(() => _service.getBalance());

  @override
  Future<DataState<List<LedgerEntry>>> getLedger({
    int limit = 50,
    int offset = 0,
  }) =>
      guard(() => _service.getLedger(limit: limit, offset: offset));

  @override
  Future<DataState<WithdrawalRequest>> withdraw({
    required int amount,
    required int bankAccountId,
  }) =>
      guard(() => _service.withdraw(
            amount: amount,
            bankAccountId: bankAccountId,
          ));

  @override
  Future<DataState<List<Map<String, dynamic>>>> getInvoices({
    int? orderId,
    int? shipmentId,
  }) =>
      guard(() => _service.getInvoices(
            orderId: orderId,
            shipmentId: shipmentId,
          ));

  @override
  Future<DataState<List<Map<String, dynamic>>>> getTaxInvoices({
    required int shipmentId,
  }) =>
      guard(() => _service.getTaxInvoices(shipmentId: shipmentId));

  @override
  Future<DataState<List<ConfigParameter>>> getConfigParameters({
    String? group,
  }) =>
      guard(() => _service.getConfigParameters(group: group));
}
