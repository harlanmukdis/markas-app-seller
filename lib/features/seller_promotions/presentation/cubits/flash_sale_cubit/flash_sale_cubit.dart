import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/promotion/flash_sale.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/promotion_repository.dart';
import '../../../../../di/injector.dart';

part 'flash_sale_state.dart';

/// The active store's flash sales.
///
/// Like vouchers, creation is one-way — nothing here can edit or cancel a sale
/// afterwards.
class FlashSaleCubit extends Cubit<FlashSaleState> {
  FlashSaleCubit() : super(const FlashSaleInProgress());

  static FlashSaleCubit get(BuildContext context) => BlocProvider.of(context);

  final PromotionRepository _promotions = injector<PromotionRepository>();
  final AuthRepository _auth = injector<AuthRepository>();

  Future<void> load() async {
    if (isClosed) return;

    final storeId = _auth.activeStoreId;
    if (storeId == null) {
      emit(const FlashSaleNoStore());
      return;
    }

    emit(const FlashSaleInProgress());

    final result = await _promotions.getStoreFlashSales(storeId);
    if (isClosed) return;

    switch (result) {
      case DataSuccess<List<FlashSale>>(:final value):
        emit(FlashSaleLoaded(value));
      case DataEmpty<List<FlashSale>>():
        emit(const FlashSaleLoaded(<FlashSale>[]));
      case DataFailed<List<FlashSale>>(:final failure):
        emit(FlashSaleFailure(failure));
      default:
        emit(const FlashSaleFailure(
          DataError(
            code: DataErrorCode.unexpected,
            message: 'Flash sale toko tidak bisa dibaca.',
          ),
        ));
    }
  }

  /// Creates a sale and reloads the list.
  ///
  /// Refuses a backwards or zero-length window, which the server would accept
  /// with a `201` and store as a sale that can never run.
  Future<DataError?> create({
    required String name,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    final storeId = _auth.activeStoreId;
    final current = state;
    if (storeId == null || current is! FlashSaleLoaded) return null;

    if (name.trim().isEmpty) {
      return const DataError(
        code: 'FLASH_SALE_NAME_REQUIRED',
        message: 'Nama flash sale wajib diisi.',
      );
    }
    if (!endAt.isAfter(startAt)) {
      return const DataError(
        code: 'FLASH_SALE_PERIOD_INVALID',
        message: 'Waktu berakhir harus setelah waktu mulai.',
      );
    }

    emit(current.copyWith(isBusy: true));
    final result = await _promotions.createFlashSale(
      storeId,
      name: name,
      startAt: startAt,
      endAt: endAt,
    );
    if (isClosed) return null;

    switch (result) {
      case DataSuccess<List<FlashSale>>(:final value):
        emit(FlashSaleLoaded(value));
        return null;
      case DataFailed<List<FlashSale>>(:final failure):
        emit(current.copyWith(isBusy: false));
        return failure;
      default:
        await load();
        return null;
    }
  }
}
