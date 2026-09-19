import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/promotion/store_voucher.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/promotion_repository.dart';
import '../../../../../di/injector.dart';

part 'voucher_state.dart';

/// The active store's vouchers.
///
/// Creation is one-way: there is no endpoint to edit, pause or delete a
/// voucher, so everything that can be checked is checked here before the call
/// rather than being left to a server that would answer a raw 500.
class VoucherCubit extends Cubit<VoucherState> {
  VoucherCubit() : super(const VoucherInProgress());

  static VoucherCubit get(BuildContext context) => BlocProvider.of(context);

  final PromotionRepository _promotions = injector<PromotionRepository>();
  final AuthRepository _auth = injector<AuthRepository>();

  Future<void> load() async {
    if (isClosed) return;

    final storeId = _auth.activeStoreId;
    if (storeId == null) {
      emit(const VoucherNoStore());
      return;
    }

    emit(const VoucherInProgress());

    final result = await _promotions.getStoreVouchers(storeId);
    if (isClosed) return;

    switch (result) {
      case DataSuccess<List<StoreVoucher>>(:final value):
        emit(VoucherLoaded(value));
      case DataEmpty<List<StoreVoucher>>():
        emit(const VoucherLoaded(<StoreVoucher>[]));
      case DataFailed<List<StoreVoucher>>(:final failure):
        emit(VoucherFailure(failure));
      default:
        emit(const VoucherFailure(
          DataError(
            code: DataErrorCode.unexpected,
            message: 'Voucher toko tidak bisa dibaca.',
          ),
        ));
    }
  }

  /// Files a new voucher and reloads the list.
  ///
  /// Refuses locally for the things the backend would answer with an HTML 500
  /// instead of a validation error: a missing required field, a percentage over
  /// 100, and a code the store has already used. The last one is only a partial
  /// guard — `vouchers.code` is unique across the whole platform, so another
  /// store's code can still collide and there is no way to see theirs.
  Future<DataError?> create({
    required String name,
    required String discountType,
    required int discountValue,
    required int quota,
    required DateTime validFrom,
    required DateTime validUntil,
    String? code,
    int? maxDiscount,
    int minSpend = 0,
    int maxUsePerUser = 1,
  }) async {
    final storeId = _auth.activeStoreId;
    final current = state;
    if (storeId == null || current is! VoucherLoaded) return null;

    final refusal = _refuse(
      current.vouchers,
      discountType: discountType,
      discountValue: discountValue,
      validFrom: validFrom,
      validUntil: validUntil,
      code: code,
    );
    if (refusal != null) return refusal;

    emit(current.copyWith(isBusy: true));
    final result = await _promotions.createVoucher(
      storeId,
      name: name,
      discountType: discountType,
      discountValue: discountValue,
      quota: quota,
      validFrom: validFrom,
      validUntil: validUntil,
      code: code,
      maxDiscount: maxDiscount,
      minSpend: minSpend,
      maxUsePerUser: maxUsePerUser,
    );
    if (isClosed) return null;

    switch (result) {
      case DataSuccess<List<StoreVoucher>>(:final value):
        emit(VoucherLoaded(value));
        return null;
      case DataFailed<List<StoreVoucher>>(:final failure):
        emit(current.copyWith(isBusy: false));
        return failure;
      default:
        await load();
        return null;
    }
  }

  DataError? _refuse(
    List<StoreVoucher> existing, {
    required String discountType,
    required int discountValue,
    required DateTime validFrom,
    required DateTime validUntil,
    String? code,
  }) {
    if (!VoucherDiscountType.all.contains(discountType)) {
      return const DataError(
        code: 'VOUCHER_TYPE_INVALID',
        message: 'Jenis diskon tidak dikenali.',
      );
    }
    if (discountValue <= 0) {
      return const DataError(
        code: 'VOUCHER_VALUE_INVALID',
        message: 'Nilai diskon harus lebih dari 0.',
      );
    }
    if (discountType == VoucherDiscountType.percentage && discountValue > 100) {
      return const DataError(
        code: 'VOUCHER_VALUE_INVALID',
        message: 'Diskon persen maksimal 100%.',
      );
    }
    if (!validUntil.isAfter(validFrom)) {
      return const DataError(
        code: 'VOUCHER_PERIOD_INVALID',
        message: 'Tanggal berakhir harus setelah tanggal mulai.',
      );
    }
    final wanted = code?.trim().toUpperCase() ?? '';
    if (wanted.isNotEmpty &&
        existing.any((voucher) => voucher.code.toUpperCase() == wanted)) {
      return DataError(
        code: 'VOUCHER_CODE_TAKEN',
        message: 'Kode $wanted sudah dipakai voucher toko ini.',
      );
    }
    return null;
  }
}
