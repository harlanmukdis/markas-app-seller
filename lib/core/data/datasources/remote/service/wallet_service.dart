import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/wallet/store_wallet.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

/// The store's earnings and withdrawals.
class WalletService extends BaseService {
  const WalletService(super.dio);

  /// Balance plus the last 50 ledger rows. The wallet row is created on first
  /// read, so this never 404s for a store that exists.
  Future<StoreWallet> getStoreWallet(int storeId) async {
    final envelope = await getRequest(
      ApiEndpoints.storeWallet(storeId),
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return StoreWallet.fromJson(envelope.map);
  }

  /// Files a withdrawal request and returns its id.
  ///
  /// **The balance is debited immediately**, at request time — not when an
  /// admin approves it. So the money leaves the wallet the moment this
  /// succeeds, and a rejected request would have to be credited back by hand.
  ///
  /// The server checks only the minimum and the balance, and both failures come
  /// back as the same `WITHDRAWAL_REJECTED` with different messages. It does
  /// **not** validate the bank fields: with a sufficient balance, a missing
  /// `bank_name` reaches a `NOT NULL` column and answers 500. Validate them
  /// here instead — which is why all three are required arguments.
  ///
  /// Sent as JSON. (`/orders/{id}/ship` and `/cancel` need form encoding; this
  /// one reads its body the ordinary way.)
  Future<int> requestWithdrawal(
    int storeId, {
    required int amount,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.storeWalletWithdraw(storeId),
      body: <String, dynamic>{
        'amount': amount,
        'bank_name': bankName,
        'bank_account_number': bankAccountNumber,
        'bank_account_name': bankAccountName,
      },
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return asInt(envelope.map['id']);
  }
}
