part of 'bank_account_cubit.dart';

sealed class BankAccountState {
  const BankAccountState();
}

final class BankAccountLoadInProgress extends BankAccountState {
  const BankAccountLoadInProgress();
}

final class BankAccountLoadSuccess extends BankAccountState {
  const BankAccountLoadSuccess({
    required this.accounts,
    this.isBusy = false,
  });

  final List<BankAccount> accounts;
  final bool isBusy;

  bool get hasVerifiedAccount =>
      accounts.any((account) => account.isVerified);

  BankAccountLoadSuccess copyWith({
    List<BankAccount>? accounts,
    bool? isBusy,
  }) =>
      BankAccountLoadSuccess(
        accounts: accounts ?? this.accounts,
        isBusy: isBusy ?? this.isBusy,
      );
}

final class BankAccountLoadFailure extends BankAccountState {
  const BankAccountLoadFailure(this.error);

  final DataError error;
}
