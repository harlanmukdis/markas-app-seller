import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/wallet/store_wallet.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/wallet_repository.dart';
import '../../../../../di/injector.dart';

part 'wallet_state.dart';

/// The active store's earnings.
class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(const WalletInProgress());

  static WalletCubit get(BuildContext context) => BlocProvider.of(context);

  final WalletRepository _wallet = injector<WalletRepository>();
  final AuthRepository _auth = injector<AuthRepository>();

  Future<void> load() async {
    if (isClosed) return;

    final storeId = _auth.activeStoreId;
    if (storeId == null) {
      emit(const WalletNoStore());
      return;
    }

    emit(const WalletInProgress());

    final result = await _wallet.getStoreWallet(storeId);
    if (isClosed) return;

    switch (result) {
      case DataSuccess<StoreWallet>(:final value):
        emit(WalletLoaded(value));
      case DataFailed<StoreWallet>(:final failure):
        emit(WalletFailure(failure));
      default:
        emit(const WalletFailure(
          DataError(
            code: DataErrorCode.unexpected,
            message: 'Dompet toko tidak bisa dibaca.',
          ),
        ));
    }
  }

  /// Files a withdrawal. Refuses locally first for the two things the server
  /// checks — the minimum and the balance — so the seller is told before a
  /// round trip rather than by a generic `WITHDRAWAL_REJECTED`.
  Future<DataError?> withdraw({
    required int amount,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
  }) async {
    final storeId = _auth.activeStoreId;
    final current = state;
    if (storeId == null || current is! WalletLoaded) return null;

    final refusal = _refuse(current.wallet, amount);
    if (refusal != null) return refusal;

    emit(current.copyWith(isBusy: true));
    final result = await _wallet.requestWithdrawal(
      storeId,
      amount: amount,
      bankName: bankName,
      bankAccountNumber: bankAccountNumber,
      bankAccountName: bankAccountName,
    );
    if (isClosed) return null;

    switch (result) {
      case DataSuccess<StoreWallet>(:final value):
        emit(WalletLoaded(value));
        return null;
      case DataFailed<StoreWallet>(:final failure):
        emit(current.copyWith(isBusy: false));
        return failure;
      default:
        await load();
        return null;
    }
  }

  DataError? _refuse(StoreWallet wallet, int amount) {
    if (wallet.isFrozen) {
      return const DataError(
        code: 'WALLET_FROZEN',
        message: 'Dompet toko sedang dibekukan, jadi penarikan tidak bisa '
            'diajukan. Hubungi admin marketplace.',
      );
    }
    if (amount < StoreWallet.minimumWithdrawal) {
      return const DataError(
        code: 'WITHDRAWAL_BELOW_MINIMUM',
        message: 'Minimum penarikan Rp50.000.',
      );
    }
    if (amount > wallet.balance) {
      return DataError(
        code: 'WITHDRAWAL_REJECTED',
        message: 'Saldo tidak mencukupi.',
        details: <String, dynamic>{'saldo': wallet.balance},
      );
    }
    return null;
  }
}
