import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data/datasources/remote/service/merchandising_service.dart'
    show BundleItemDraft;
import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/catalog/product.dart';
import '../../../../../core/domain/model/merchandising/product_bundle.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/catalog_repository.dart';
import '../../../../../core/domain/repositories/merchandising_repository.dart';
import '../../../../../di/injector.dart';

part 'bundle_state.dart';

/// The store's product bundles.
///
/// Items are settled at creation — nothing here edits them, because no
/// endpoint does. What can change afterwards is the name, the price and
/// whether the bundle is on sale.
class BundleCubit extends Cubit<BundleState> {
  BundleCubit() : super(const BundleInProgress());

  static BundleCubit get(BuildContext context) => BlocProvider.of(context);

  final MerchandisingRepository _merchandising =
      injector<MerchandisingRepository>();
  final CatalogRepository _catalog = injector<CatalogRepository>();
  final AuthRepository _auth = injector<AuthRepository>();

  /// The catalogue, for the item picker. Cached because the picker reopens
  /// per bundle and the list is walked page by page.
  List<Product>? _pickerProducts;

  Future<void> load() async {
    if (isClosed) return;

    final storeId = _auth.activeStoreId;
    if (storeId == null) {
      emit(const BundleNoStore());
      return;
    }

    emit(const BundleInProgress());

    final result = await _merchandising.getStoreBundles(storeId);
    if (isClosed) return;

    switch (result) {
      case DataSuccess<List<ProductBundle>>(:final value):
        emit(BundleLoaded(value));
      case DataEmpty<List<ProductBundle>>():
        emit(const BundleLoaded(<ProductBundle>[]));
      case DataFailed<List<ProductBundle>>(:final failure):
        emit(BundleFailure(failure));
      default:
        emit(const BundleFailure(
          DataError(
            code: DataErrorCode.unexpected,
            message: 'Bundel toko tidak bisa dibaca.',
          ),
        ));
    }
  }

  Future<List<Product>> pickerProducts() async {
    final cached = _pickerProducts;
    if (cached != null) return cached;

    final storeId = _auth.activeStoreId;
    if (storeId == null) return const <Product>[];

    final result = await _catalog.getStoreProducts(storeId);
    final products = switch (result) {
      DataSuccess<List<Product>>(:final value) => value,
      _ => const <Product>[],
    };
    _pickerProducts = products;
    return products;
  }

  Future<DataError?> create({
    required String name,
    required int bundlePrice,
    required List<BundleItemDraft> items,
    String status = BundleStatus.active,
  }) async {
    final storeId = _auth.activeStoreId;
    final current = state;
    if (storeId == null || current is! BundleLoaded) return null;

    // Mirrors what the server checks, so the seller hears it without a round
    // trip. The server's own messages are good here, unusually — these only
    // get in first.
    if (name.trim().isEmpty) {
      return const DataError(
        code: 'BUNDLE_NAME_REQUIRED',
        message: 'Nama bundel wajib diisi.',
      );
    }
    if (items.isEmpty) {
      return const DataError(
        code: 'BUNDLE_ITEMS_REQUIRED',
        message: 'Bundel harus berisi minimal satu produk.',
      );
    }
    if (bundlePrice <= 0) {
      return const DataError(
        code: 'BUNDLE_PRICE_INVALID',
        message: 'Harga bundel harus lebih dari 0.',
      );
    }

    emit(current.copyWith(isBusy: true));
    final result = await _merchandising.createBundle(
      storeId,
      name: name,
      bundlePrice: bundlePrice,
      items: items,
      status: status,
    );
    if (isClosed) return null;
    return _apply(result, current);
  }

  Future<DataError?> update(
    int bundleId, {
    String? name,
    int? bundlePrice,
    String? status,
  }) async {
    final storeId = _auth.activeStoreId;
    final current = state;
    if (storeId == null || current is! BundleLoaded) return null;

    emit(current.copyWith(isBusy: true));
    final result = await _merchandising.updateBundle(
      storeId,
      bundleId,
      name: name,
      bundlePrice: bundlePrice,
      status: status,
    );
    if (isClosed) return null;
    return _apply(result, current);
  }

  /// Switching a bundle off is the closest thing to deleting it — and it also
  /// makes the bundle's own contents unreadable, since the detail endpoint
  /// serves active bundles only.
  Future<DataError?> setActive(int bundleId, bool isActive) => update(
        bundleId,
        status: isActive ? BundleStatus.active : BundleStatus.inactive,
      );

  DataError? _apply(
    DataState<List<ProductBundle>> result,
    BundleLoaded previous,
  ) {
    switch (result) {
      case DataSuccess<List<ProductBundle>>(:final value):
        emit(BundleLoaded(value));
        return null;
      case DataEmpty<List<ProductBundle>>():
        emit(const BundleLoaded(<ProductBundle>[]));
        return null;
      case DataFailed<List<ProductBundle>>(:final failure):
        emit(previous.copyWith(isBusy: false));
        return failure;
      default:
        emit(previous.copyWith(isBusy: false));
        return null;
    }
  }
}
