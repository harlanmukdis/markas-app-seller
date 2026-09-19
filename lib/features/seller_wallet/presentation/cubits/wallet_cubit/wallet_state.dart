part of 'wallet_cubit.dart';

sealed class WalletState {
  const WalletState();
}

final class WalletInProgress extends WalletState {
  const WalletInProgress();
}

final class WalletNoStore extends WalletState {
  const WalletNoStore();
}

final class WalletFailure extends WalletState {
  const WalletFailure(this.error);

  final DataError error;
}

final class WalletLoaded extends WalletState {
  const WalletLoaded(this.wallet, {this.isBusy = false});

  final StoreWallet wallet;
  final bool isBusy;

  /// Nothing has ever moved through this wallet. Distinct from a zero balance
  /// after withdrawing everything, and the two deserve different words.
  bool get isUntouched => wallet.transactions.isEmpty && wallet.balance == 0;

  WalletLoaded copyWith({StoreWallet? wallet, bool? isBusy}) =>
      WalletLoaded(wallet ?? this.wallet, isBusy: isBusy ?? this.isBusy);
}
