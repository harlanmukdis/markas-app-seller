part of 'store_cubit.dart';

sealed class StoreState {
  const StoreState();
}

final class StoreLoadInProgress extends StoreState {
  const StoreLoadInProgress();
}

final class StoreLoadFailure extends StoreState {
  const StoreLoadFailure(this.error);

  final DataError error;
}

final class StoreLoadSuccess extends StoreState {
  const StoreLoadSuccess({required this.stores, this.activeStoreId});

  final List<Store> stores;
  final int? activeStoreId;

  Store? get activeStore {
    final id = activeStoreId;
    if (id == null) return null;
    for (final store in stores) {
      if (store.id == id) return store;
    }
    return null;
  }

  bool get hasStore => stores.isNotEmpty;

  StoreLoadSuccess copyWith({List<Store>? stores, int? activeStoreId}) =>
      StoreLoadSuccess(
        stores: stores ?? this.stores,
        activeStoreId: activeStoreId ?? this.activeStoreId,
      );
}
