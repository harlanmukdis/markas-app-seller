import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/finance/finance.dart';
import '../../../../../core/domain/model/seller/bank_account.dart';
import '../../../../../core/domain/repositories/finance_repository.dart';
import '../../../../../core/domain/repositories/seller_repository.dart';
import '../../../../../di/injector.dart';

part 'finance_state.dart';

/// The store can only watch its money here — releasing funds is admin/cron
/// only. Withdrawals are requests, subject to Admin Finance approval.
class FinanceCubit extends Cubit<FinanceState> {
  FinanceCubit() : super(const FinanceLoadInProgress());

  static FinanceCubit get(BuildContext context) => BlocProvider.of(context);

  final FinanceRepository _financeRepository = injector<FinanceRepository>();
  final SellerRepository _sellerRepository = injector<SellerRepository>();

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) emit(const FinanceLoadInProgress());

    final results = await Future.wait(<Future<Object>>[
      _financeRepository.getBalance(),
      _financeRepository.getLedger(),
      _sellerRepository.getBankAccounts(),
      _financeRepository.getConfigParameters(group: ConfigGroup.pencairan),
    ]);

    if (isClosed) return;

    final balanceResult = results[0] as DataState<SellerBalance>;
    if (balanceResult is DataFailed<SellerBalance>) {
      emit(FinanceLoadFailure(balanceResult.failure));
      return;
    }
    if (balanceResult is! DataSuccess<SellerBalance>) {
      emit(
        const FinanceLoadFailure(
          DataError(
            code: DataErrorCode.unexpected,
            message: 'Server tidak mengembalikan saldo.',
          ),
        ),
      );
      return;
    }

    emit(
      FinanceLoadSuccess(
        balance: balanceResult.value,
        ledger: _listOf(results[1] as DataState<List<LedgerEntry>>),
        bankAccounts: _listOf(results[2] as DataState<List<BankAccount>>),
        minimumWithdrawal: _minimumWithdrawal(
          _listOf(results[3] as DataState<List<ConfigParameter>>),
        ),
      ),
    );
  }

  Future<DataError?> withdraw({
    required int amount,
    required int bankAccountId,
  }) async {
    final current = state;
    if (current is FinanceLoadSuccess) emit(current.copyWith(isBusy: true));

    final result = await _financeRepository.withdraw(
      amount: amount,
      bankAccountId: bankAccountId,
    );

    if (isClosed) return null;

    if (result is DataFailed<WithdrawalRequest>) {
      if (current is FinanceLoadSuccess) emit(current.copyWith(isBusy: false));
      return result.failure;
    }

    await load(showSpinner: false);
    return null;
  }

  static List<T> _listOf<T>(DataState<List<T>> state) =>
      state is DataSuccess<List<T>> ? state.value : const <Never>[];

  /// Looks for the withdrawal-minimum parameter under a few plausible keys —
  /// the exact key is not pinned down in the API doc, and a wrong guess should
  /// mean "no minimum shown", never a crash.
  static int? _minimumWithdrawal(List<ConfigParameter> parameters) {
    for (final parameter in parameters) {
      final key = parameter.paramKey.toLowerCase();
      if (key.contains('min') && key.contains('withdraw')) {
        return parameter.asInteger;
      }
      if (key.contains('minimum') && key.contains('penarikan')) {
        return parameter.asInteger;
      }
    }
    return null;
  }
}
