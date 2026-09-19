import '../../data_state.dart';
import '../../domain/model/wallet/store_wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/remote/service/wallet_service.dart';
import 'repository_guard.dart';

class WalletRepositoryImpl with RepositoryGuard implements WalletRepository {
  const WalletRepositoryImpl(this._service);

  final WalletService _service;

  @override
  Future<DataState<StoreWallet>> getStoreWallet(int storeId) =>
      guard(() => _service.getStoreWallet(storeId));

  @override
  Future<DataState<StoreWallet>> requestWithdrawal(
    int storeId, {
    required int amount,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
  }) =>
      guard(() async {
        await _service.requestWithdrawal(
          storeId,
          amount: amount,
          bankName: bankName,
          bankAccountNumber: bankAccountNumber,
          bankAccountName: bankAccountName,
        );
        return _service.getStoreWallet(storeId);
      });
}
