import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/auth/auth_session.dart';
import '../../../../../core/domain/model/enums.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../di/injector.dart';

part 'seller_auth_state.dart';

/// Login and registration.
///
/// The action methods return the failure rather than emitting an error state:
/// the view needs to react once (a snackbar, and navigation on success), not
/// rebuild into an error screen that would throw away what was typed.
class SellerAuthCubit extends Cubit<SellerAuthState> {
  SellerAuthCubit() : super(const SellerAuthIdle());

  static SellerAuthCubit get(BuildContext context) => BlocProvider.of(context);

  final AuthRepository _authRepository = injector<AuthRepository>();

  bool get isBusy => state is SellerAuthInProgress;

  Future<DataError?> login({
    required String phone,
    required String password,
  }) async {
    emit(const SellerAuthInProgress());
    final result = await _authRepository.login(phone: phone, password: password);
    return _settle(result);
  }

  Future<DataError?> register({
    required String phone,
    required String password,
    required String fullName,
    required String tokoName,
    String sellerType = SellerType.toko,
    String? email,
  }) async {
    emit(const SellerAuthInProgress());
    final result = await _authRepository.register(
      phone: phone,
      password: password,
      fullName: fullName,
      tokoName: tokoName,
      sellerType: sellerType,
      email: email,
    );
    return _settle(result);
  }

  DataError? _settle(DataState<AuthSession> result) {
    if (isClosed) return null;

    switch (result) {
      case DataSuccess<AuthSession>(:final value):
        emit(SellerAuthSuccess(value));
        return null;
      case DataFailed<AuthSession>(:final failure):
        emit(const SellerAuthIdle());
        return failure;
      case DataLoading<AuthSession>():
      case DataEmpty<AuthSession>():
        emit(const SellerAuthIdle());
        return const DataError(
          code: DataErrorCode.unexpected,
          message: 'Server tidak mengembalikan sesi.',
        );
    }
  }
}
