import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/catalog/product.dart';
import '../../../../../core/domain/model/merchandising/store_showcase.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/catalog_repository.dart';
import '../../../../../core/domain/repositories/merchandising_repository.dart';
import '../../../../../di/injector.dart';

part 'showcase_detail_state.dart';

/// One showcase and the products on it.
///
/// There is no `GET /showcases/{id}`, so the showcase's own row comes from the
/// store's list, the same way a flash sale's does.
class ShowcaseDetailCubit extends Cubit<ShowcaseDetailState> {
  ShowcaseDetailCubit(this.showcaseId)
      : super(const ShowcaseDetailInProgress());

  static ShowcaseDetailCubit get(BuildContext context) =>
      BlocProvider.of(context);

  final int showcaseId;

  final MerchandisingRepository _merchandising =
      injector<MerchandisingRepository>();
  final CatalogRepository _catalog = injector<CatalogRepository>();
  final AuthRepository _auth = injector<AuthRepository>();

  List<Product>? _pickerProducts;

  Future<void> load() async {
    if (isClosed) return;

    final storeId = _auth.activeStoreId;
    if (storeId == null) {
      emit(const ShowcaseDetailNoStore());
      return;
    }

    emit(const ShowcaseDetailInProgress());

    final list = await _merchandising.getStoreShowcases(storeId);
    if (isClosed) return;

    if (list is DataFailed<List<StoreShowcase>>) {
      emit(ShowcaseDetailFailure(list.failure));
      return;
    }

    final showcase = switch (list) {
      DataSuccess<List<StoreShowcase>>(:final value) =>
        value.where((one) => one.id == showcaseId).firstOrNull,
      _ => null,
    };

    if (showcase == null) {
      emit(const ShowcaseDetailFailure(
        DataError(
          code: 'SHOWCASE_NOT_FOUND',
          message: 'Etalase ini tidak ada di toko yang sedang aktif.',
        ),
      ));
      return;
    }

    final products = await _merchandising.getShowcaseProducts(showcaseId);
    if (isClosed) return;

    switch (products) {
      case DataSuccess<List<ShowcaseProduct>>(:final value):
        emit(ShowcaseDetailLoaded(showcase: showcase, products: value));
      case DataEmpty<List<ShowcaseProduct>>():
        emit(ShowcaseDetailLoaded(
          showcase: showcase,
          products: const <ShowcaseProduct>[],
        ));
      case DataFailed<List<ShowcaseProduct>>(:final failure):
        emit(ShowcaseDetailFailure(failure));
      default:
        emit(ShowcaseDetailLoaded(
          showcase: showcase,
          products: const <ShowcaseProduct>[],
        ));
    }
  }

  /// The store's catalogue for the picker, drafts included — the server
  /// accepts a draft into a showcase, it simply never lists it afterwards, so
  /// the picker marks them rather than hiding them.
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

  Future<DataError?> addProduct(int productId) async {
    final current = state;
    if (current is! ShowcaseDetailLoaded) return null;

    // The server refuses a duplicate with a 422; catching it here keeps the
    // picker honest about what is already on the shelf.
    if (current.products.any((product) => product.id == productId)) {
      return const DataError(
        code: 'SHOWCASE_PRODUCT_DUPLICATE',
        message: 'Produk ini sudah ada di etalase tersebut.',
      );
    }

    emit(current.copyWith(isBusy: true));
    final result = await _merchandising.addShowcaseProduct(
      showcaseId,
      productId: productId,
    );
    if (isClosed) return null;
    return _apply(result, current);
  }

  Future<DataError?> removeProduct(int productId) async {
    final current = state;
    if (current is! ShowcaseDetailLoaded) return null;

    emit(current.copyWith(isBusy: true));
    final result =
        await _merchandising.removeShowcaseProduct(showcaseId, productId);
    if (isClosed) return null;
    return _apply(result, current);
  }

  DataError? _apply(
    DataState<List<ShowcaseProduct>> result,
    ShowcaseDetailLoaded previous,
  ) {
    switch (result) {
      case DataSuccess<List<ShowcaseProduct>>(:final value):
        emit(previous.copyWith(products: value, isBusy: false));
        return null;
      case DataEmpty<List<ShowcaseProduct>>():
        emit(previous.copyWith(
          products: const <ShowcaseProduct>[],
          isBusy: false,
        ));
        return null;
      case DataFailed<List<ShowcaseProduct>>(:final failure):
        emit(previous.copyWith(isBusy: false));
        return failure;
      default:
        emit(previous.copyWith(isBusy: false));
        return null;
    }
  }
}
