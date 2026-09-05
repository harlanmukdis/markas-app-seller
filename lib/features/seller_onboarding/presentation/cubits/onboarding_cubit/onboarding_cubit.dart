import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/seller/activation_gates.dart';
import '../../../../../core/domain/model/seller/seller_model.dart';
import '../../../../../core/domain/model/seller/warehouse.dart';
import '../../../../../core/domain/repositories/seller_repository.dart';
import '../../../../../di/injector.dart';

part 'onboarding_state.dart';

/// Drives the activation checklist.
///
/// The gate booleans come straight from `activation_gates` on the seller
/// payload. They are never recomputed here from document statuses — the
/// backend's copy is the one that decides whether the store can sell.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingLoadInProgress());

  static OnboardingCubit get(BuildContext context) => BlocProvider.of(context);

  final SellerRepository _sellerRepository = injector<SellerRepository>();

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) emit(const OnboardingLoadInProgress());

    // Both reads are independent, so they go out together rather than in
    // sequence — this screen is the app's landing page after login.
    final results = await Future.wait(<Future<Object>>[
      _sellerRepository.getSeller(),
      _sellerRepository.getWarehouses(),
    ]);

    if (isClosed) return;

    final sellerResult = results[0] as DataState<SellerModel>;
    final warehouseResult = results[1] as DataState<List<Warehouse>>;

    switch (sellerResult) {
      case DataSuccess<SellerModel>(:final value):
        emit(
          OnboardingLoadSuccess(
            seller: value,
            warehouses: switch (warehouseResult) {
              DataSuccess<List<Warehouse>>(:final value) => value,
              _ => const <Warehouse>[],
            },
            warehouseError: switch (warehouseResult) {
              DataFailed<List<Warehouse>>(:final failure) => failure,
              _ => null,
            },
          ),
        );
      case DataFailed<SellerModel>(:final failure):
        emit(OnboardingLoadFailure(failure));
      case DataLoading<SellerModel>():
      case DataEmpty<SellerModel>():
        emit(
          const OnboardingLoadFailure(
            DataError(
              code: DataErrorCode.notFound,
              message: 'Data toko tidak ditemukan untuk akun ini.',
            ),
          ),
        );
    }
  }

  /// Gate 4. Idempotent on the server, so a double tap is harmless.
  Future<DataError?> signAgreement() async {
    final current = state;
    if (current is! OnboardingLoadSuccess) return null;

    emit(current.copyWith(isBusy: true));
    final result = await _sellerRepository.signAgreement();

    if (isClosed) return null;

    switch (result) {
      case DataSuccess<ActivationGates>():
        // Re-read the seller rather than patching the gates locally: signing
        // the last outstanding gate flips `status` to VERIFIED too.
        await load(showSpinner: false);
        return null;
      case DataFailed<ActivationGates>(:final failure):
        emit(current.copyWith(isBusy: false));
        return failure;
      case DataLoading<ActivationGates>():
      case DataEmpty<ActivationGates>():
        emit(current.copyWith(isBusy: false));
        return const DataError(
          code: DataErrorCode.unexpected,
          message: 'Server tidak mengembalikan status gerbang.',
        );
    }
  }
}
