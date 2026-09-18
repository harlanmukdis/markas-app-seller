import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/verification/store_verification.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/verification_repository.dart';
import '../../../../../di/injector.dart';

part 'verification_state.dart';

/// The active store's verification request.
///
/// Approval is what turns a store from `inactive` into one that can sell, and
/// only an admin can grant it. So everything here is about getting a complete
/// request in front of that admin: submit once, attach the documents, then
/// watch.
class VerificationCubit extends Cubit<VerificationState> {
  VerificationCubit() : super(const VerificationInProgress());

  static VerificationCubit get(BuildContext context) =>
      BlocProvider.of(context);

  final VerificationRepository _verification = injector<VerificationRepository>();
  final AuthRepository _auth = injector<AuthRepository>();

  int? get storeId => _auth.activeStoreId;

  Future<void> load() async {
    if (isClosed) return;

    final id = storeId;
    if (id == null) {
      emit(const VerificationNoStore());
      return;
    }

    emit(const VerificationInProgress());

    final result = await _verification.getVerification(id);
    if (isClosed) return;

    switch (result) {
      case DataSuccess<StoreVerification>(:final value):
        emit(VerificationLoaded(value));
      case DataEmpty<StoreVerification>():
        // Never submitted. Not a failure — it is the starting point.
        emit(const VerificationNotSubmitted());
      case DataFailed<StoreVerification>(:final failure):
        emit(VerificationFailure(failure));
      case DataLoading<StoreVerification>():
        break;
    }
  }

  /// Creates the request. Documents can only be attached afterwards, so the
  /// screen moves on to the upload step once this succeeds.
  Future<DataError?> submit({
    required String type,
    String? idCardNumber,
    String? taxNumber,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankName,
  }) async {
    final id = storeId;
    if (id == null) {
      return const DataError(
        code: DataErrorCode.unexpected,
        message: 'Belum ada toko yang dipilih.',
      );
    }

    _setBusy(true);
    final result = await _verification.submit(
      id,
      type: type,
      idCardNumber: idCardNumber,
      taxNumber: taxNumber,
      bankAccountName: bankAccountName,
      bankAccountNumber: bankAccountNumber,
      bankName: bankName,
    );
    if (isClosed) return null;

    if (result is DataFailed<int>) {
      _setBusy(false);
      return result.failure;
    }

    await load();
    return null;
  }

  Future<DataError?> uploadDocument({
    required Uint8List bytes,
    required String fileName,
    required String docType,
  }) async {
    final id = storeId;
    if (id == null) return null;

    _setBusy(true);
    final result = await _verification.uploadDocument(
      id,
      bytes: bytes,
      fileName: fileName,
      docType: docType,
    );
    if (isClosed) return null;

    switch (result) {
      case DataSuccess<StoreVerification>(:final value):
        emit(VerificationLoaded(value));
        return null;
      case DataFailed<StoreVerification>(:final failure):
        _setBusy(false);
        return failure;
      default:
        await load();
        return null;
    }
  }

  void _setBusy(bool isBusy) {
    final current = state;
    if (current is VerificationLoaded) {
      emit(current.copyWith(isBusy: isBusy));
    } else if (current is VerificationNotSubmitted) {
      emit(VerificationNotSubmitted(isBusy: isBusy));
    }
  }
}
