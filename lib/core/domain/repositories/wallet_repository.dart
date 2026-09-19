import '../../data_state.dart';
import '../model/wallet/store_wallet.dart';

/// The store's earnings and withdrawals.
abstract class WalletRepository {
  Future<DataState<StoreWallet>> getStoreWallet(int storeId);

  /// Files a withdrawal and returns the wallet as it stands afterwards — the
  /// balance is debited at request time, so the screen must not keep showing
  /// the old figure.
  Future<DataState<StoreWallet>> requestWithdrawal(
    int storeId, {
    required int amount,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
  });
}
