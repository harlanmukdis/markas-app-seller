part of 'finance_cubit.dart';

sealed class FinanceState {
  const FinanceState();
}

final class FinanceLoadInProgress extends FinanceState {
  const FinanceLoadInProgress();
}

final class FinanceLoadSuccess extends FinanceState {
  const FinanceLoadSuccess({
    required this.balance,
    this.ledger = const <LedgerEntry>[],
    this.bankAccounts = const <BankAccount>[],
    this.minimumWithdrawal,
    this.isBusy = false,
  });

  final SellerBalance balance;
  final List<LedgerEntry> ledger;
  final List<BankAccount> bankAccounts;

  /// Read from `/config/parameters` rather than hardcoded, so the app shows
  /// the threshold that is actually in force.
  final int? minimumWithdrawal;

  final bool isBusy;

  /// Only a VERIFIED account can receive a withdrawal (409 otherwise).
  List<BankAccount> get verifiedAccounts =>
      bankAccounts.where((account) => account.isVerified).toList();

  bool get canWithdraw => balance.available > 0 && verifiedAccounts.isNotEmpty;

  FinanceLoadSuccess copyWith({
    SellerBalance? balance,
    List<LedgerEntry>? ledger,
    List<BankAccount>? bankAccounts,
    int? minimumWithdrawal,
    bool? isBusy,
  }) =>
      FinanceLoadSuccess(
        balance: balance ?? this.balance,
        ledger: ledger ?? this.ledger,
        bankAccounts: bankAccounts ?? this.bankAccounts,
        minimumWithdrawal: minimumWithdrawal ?? this.minimumWithdrawal,
        isBusy: isBusy ?? this.isBusy,
      );
}

final class FinanceLoadFailure extends FinanceState {
  const FinanceLoadFailure(this.error);

  final DataError error;
}
