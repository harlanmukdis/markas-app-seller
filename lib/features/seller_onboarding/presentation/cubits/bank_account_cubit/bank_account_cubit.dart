import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/seller/bank_account.dart';
import '../../../../../core/domain/repositories/seller_repository.dart';
import '../../../../../di/injector.dart';

part 'bank_account_state.dart';

class BankAccountCubit extends Cubit<BankAccountState> {
  BankAccountCubit() : super(const BankAccountLoadInProgress());

  static BankAccountCubit get(BuildContext context) => BlocProvider.of(context);

  final SellerRepository _sellerRepository = injector<SellerRepository>();

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) emit(const BankAccountLoadInProgress());

    final result = await _sellerRepository.getBankAccounts();
    if (isClosed) return;

    switch (result) {
      case DataSuccess<List<BankAccount>>(:final value):
        emit(BankAccountLoadSuccess(accounts: value));
      // An empty list is a normal first-run outcome, not a failure.
      case DataEmpty<List<BankAccount>>():
        emit(const BankAccountLoadSuccess(accounts: <BankAccount>[]));
      case DataFailed<List<BankAccount>>(:final failure):
        emit(BankAccountLoadFailure(failure));
      case DataLoading<List<BankAccount>>():
        break;
    }
  }

  /// Adds a payout account. It lands as `PENDING`; Admin Finance verifies it,
  /// and only then does gate 2 open.
  Future<DataError?> add({
    required String bankName,
    required String accountNo,
    required String accountHolder,
  }) async {
    final current = state;
    if (current is BankAccountLoadSuccess) emit(current.copyWith(isBusy: true));

    final result = await _sellerRepository.addBankAccount(
      bankName: bankName,
      accountNo: accountNo,
      accountHolder: accountHolder,
    );

    if (isClosed) return null;

    switch (result) {
      case DataSuccess<BankAccount>():
        await load(showSpinner: false);
        return null;
      case DataFailed<BankAccount>(:final failure):
        if (current is BankAccountLoadSuccess) {
          emit(current.copyWith(isBusy: false));
        }
        return failure;
      case DataLoading<BankAccount>():
      case DataEmpty<BankAccount>():
        if (current is BankAccountLoadSuccess) {
          emit(current.copyWith(isBusy: false));
        }
        return const DataError(
          code: DataErrorCode.unexpected,
          message: 'Server tidak mengembalikan data rekening.',
        );
    }
  }
}
