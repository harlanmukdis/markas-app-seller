import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/store/store.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/store_repository.dart';
import '../../../../../di/injector.dart';

part 'store_state.dart';

/// The stores this account owns, and which one the app is acting as.
class StoreCubit extends Cubit<StoreState> {
  StoreCubit() : super(const StoreLoadInProgress());

  static StoreCubit get(BuildContext context) => BlocProvider.of(context);

  final StoreRepository _storeRepository = injector<StoreRepository>();
  final AuthRepository _authRepository = injector<AuthRepository>();

  Future<void> load() async {
    emit(const StoreLoadInProgress());

    final result = await _storeRepository.getMyStores();
    if (isClosed) return;

    switch (result) {
      case DataSuccess<List<Store>>(:final value):
        emit(
          StoreLoadSuccess(
            stores: value,
            activeStoreId: _authRepository.activeStoreId,
          ),
        );
      case DataEmpty<List<Store>>():
        emit(const StoreLoadSuccess(stores: <Store>[]));
      case DataFailed<List<Store>>(:final failure):
        emit(StoreLoadFailure(failure));
      case DataLoading<List<Store>>():
        break;
    }
  }

  Future<void> select(int storeId) async {
    await _authRepository.setActiveStore(storeId);
    if (isClosed) return;
    final current = state;
    if (current is StoreLoadSuccess) {
      emit(current.copyWith(activeStoreId: storeId));
    }
  }

  /// Creates the store and immediately makes it the active one — a store the
  /// account just opened is the one it means to work in.
  Future<(DataError?, int?)> create({
    required String name,
    String? description,
    String type = StoreType.physical,
  }) async {
    emit(const StoreLoadInProgress());

    final result = await _storeRepository.createStore(
      name: name,
      description: description,
      type: type,
    );
    if (isClosed) return (null, null);

    if (result is DataFailed<int>) {
      await load();
      return (result.failure, null);
    }
    if (result is! DataSuccess<int>) {
      await load();
      return (
        const DataError(
          code: DataErrorCode.unexpected,
          message: 'Server tidak mengembalikan toko yang dibuat.',
        ),
        null,
      );
    }

    await _authRepository.setActiveStore(result.value);
    await load();
    return (null, result.value);
  }
}
