import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data/local/session_store.dart';
import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/seller/kyc_document.dart';
import '../../../../../core/domain/repositories/seller_repository.dart';
import '../../../../../di/injector.dart';

part 'kyc_state.dart';

class KycCubit extends Cubit<KycState> {
  KycCubit() : super(const KycState()) {
    emit(KycState(submittedDocTypes: _sessionStore.submittedKycDocTypes));
  }

  static KycCubit get(BuildContext context) => BlocProvider.of(context);

  final SellerRepository _sellerRepository = injector<SellerRepository>();
  final SessionStore _sessionStore = injector<SessionStore>();

  /// Records one document. The file itself must already live somewhere
  /// reachable — this API stores a URL and never receives bytes (API doc 8).
  ///
  /// The first document moves the store from `DRAFT` to `PENDING_KYC`.
  Future<DataError?> upload({
    required String docType,
    required String fileUrl,
  }) async {
    emit(state.copyWith(isBusy: true));

    final result = await _sellerRepository.uploadKyc(
      docType: docType,
      fileUrl: fileUrl,
    );

    if (isClosed) return null;

    switch (result) {
      case DataSuccess<KycUploadResult>():
        emit(
          KycState(
            submittedDocTypes: _sessionStore.submittedKycDocTypes,
            isBusy: false,
          ),
        );
        return null;
      case DataFailed<KycUploadResult>(:final failure):
        emit(state.copyWith(isBusy: false));
        return failure;
      case DataLoading<KycUploadResult>():
      case DataEmpty<KycUploadResult>():
        emit(state.copyWith(isBusy: false));
        return const DataError(
          code: DataErrorCode.unexpected,
          message: 'Server tidak mengembalikan hasil unggahan.',
        );
    }
  }
}
