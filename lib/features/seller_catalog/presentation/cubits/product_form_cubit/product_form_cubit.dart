import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/catalog/category.dart';
import '../../../../../core/domain/model/catalog/product.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/catalog_repository.dart';
import '../../../../../di/injector.dart';

part 'product_form_state.dart';

/// Creating one product, or editing one that exists.
///
/// [productId] null means create. Either way the categories have to be loaded
/// first — a product cannot be created without one, and the ids move between
/// database seeds, so they are read rather than remembered.
class ProductFormCubit extends Cubit<ProductFormState> {
  ProductFormCubit({this.productId}) : super(const ProductFormInProgress());

  static ProductFormCubit get(BuildContext context) => BlocProvider.of(context);

  /// Null when creating.
  final int? productId;

  final CatalogRepository _catalog = injector<CatalogRepository>();
  final AuthRepository _auth = injector<AuthRepository>();

  bool get isEditing => productId != null;

  Future<void> load() async {
    emit(const ProductFormInProgress());

    final categoriesResult = await _catalog.getCategories();
    if (isClosed) return;

    final List<Category> categories;
    switch (categoriesResult) {
      case DataSuccess<List<Category>>(:final value):
        categories = value;
      case DataEmpty<List<Category>>():
        // A catalogue cannot be built without categories, and the seed has
        // shipped empty before — say so rather than showing a blank dropdown.
        emit(const ProductFormFailure(
          DataError(
            code: DataErrorCode.unexpected,
            message: 'Server belum punya kategori, jadi produk belum bisa '
                'dibuat. Minta admin menambahkan kategori dulu.',
          ),
        ));
        return;
      case DataFailed<List<Category>>(:final failure):
        emit(ProductFormFailure(failure));
        return;
      case DataLoading<List<Category>>():
        return;
    }

    final id = productId;
    if (id == null) {
      emit(ProductFormReady(categories: categories));
      return;
    }

    final productResult = await _catalog.getProduct(id);
    if (isClosed) return;

    switch (productResult) {
      case DataSuccess<Product>(:final value):
        emit(ProductFormReady(categories: categories, product: value));
      case DataFailed<Product>(:final failure):
        emit(ProductFormFailure(failure));
      default:
        emit(const ProductFormFailure(
          DataError(
            code: DataErrorCode.unexpected,
            message: 'Produk tidak ditemukan.',
          ),
        ));
    }
  }

  /// Creates or updates, and returns the product id on success.
  ///
  /// Errors come back rather than becoming a state, so the form keeps what was
  /// typed — the project's rule for every action method.
  Future<(DataError?, int?)> save({
    required String name,
    required int categoryId,
    required int basePrice,
    required String productType,
    String? description,
    int? weightGrams,
    int? compareAtPrice,
  }) async {
    final current = state;
    if (current is! ProductFormReady) return (null, null);
    emit(current.copyWith(isSaving: true));

    final id = productId;
    if (id == null) {
      final storeId = _auth.activeStoreId;
      if (storeId == null) {
        emit(current.copyWith(isSaving: false));
        return (
          const DataError(
            code: DataErrorCode.unexpected,
            message: 'Belum ada toko yang dipilih.',
          ),
          null,
        );
      }

      final result = await _catalog.createProduct(
        storeId,
        name: name,
        categoryId: categoryId,
        basePrice: basePrice,
        productType: productType,
        description: description,
        weightGrams: weightGrams,
      );
      if (isClosed) return (null, null);

      switch (result) {
        case DataSuccess<int>(:final value):
          emit(current.copyWith(isSaving: false));
          return (null, value);
        case DataFailed<int>(:final failure):
          emit(current.copyWith(isSaving: false));
          return (failure, null);
        default:
          emit(current.copyWith(isSaving: false));
          return (_noResultError, null);
      }
    }

    // `category_id` and `product_type` are absent on purpose: the backend's
    // PATCH whitelists neither, so both are settled at creation and the form
    // shows them read-only when editing.
    final result = await _catalog.updateProduct(
      id,
      name: name,
      description: description,
      basePrice: basePrice,
      compareAtPrice: compareAtPrice,
      weightGrams: weightGrams,
    );
    if (isClosed) return (null, null);

    switch (result) {
      case DataSuccess<Product>(:final value):
        emit(current.copyWith(product: value, isSaving: false));
        return (null, value.id);
      case DataFailed<Product>(:final failure):
        emit(current.copyWith(isSaving: false));
        return (failure, null);
      default:
        emit(current.copyWith(isSaving: false));
        return (_noResultError, null);
    }
  }

  Future<DataError?> setStatus(String status) async {
    final id = productId;
    final current = state;
    if (id == null || current is! ProductFormReady) return null;
    emit(current.copyWith(isSaving: true));

    final result = await _catalog.updateProduct(id, status: status);
    if (isClosed) return null;

    switch (result) {
      case DataSuccess<Product>(:final value):
        emit(current.copyWith(product: value, isSaving: false));
        return null;
      case DataFailed<Product>(:final failure):
        emit(current.copyWith(isSaving: false));
        return failure;
      default:
        emit(current.copyWith(isSaving: false));
        return _noResultError;
    }
  }

  Future<DataError?> addVariant({
    required String sku,
    required int price,
    Map<String, dynamic> options = const <String, dynamic>{},
    int? weightGrams,
  }) async {
    final id = productId;
    final current = state;
    if (id == null || current is! ProductFormReady) return null;
    emit(current.copyWith(isSaving: true));

    final result = await _catalog.createVariant(
      id,
      sku: sku,
      price: price,
      options: options,
      weightGrams: weightGrams,
    );
    if (isClosed) return null;

    switch (result) {
      case DataSuccess<Product>(:final value):
        emit(current.copyWith(product: value, isSaving: false));
        return null;
      case DataFailed<Product>(:final failure):
        emit(current.copyWith(isSaving: false));
        return failure;
      default:
        emit(current.copyWith(isSaving: false));
        return _noResultError;
    }
  }

  static const DataError _noResultError = DataError(
    code: DataErrorCode.unexpected,
    message: 'Server tidak mengembalikan hasil yang diharapkan.',
  );
}
