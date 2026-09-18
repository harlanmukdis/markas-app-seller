part of 'product_list_cubit.dart';

sealed class ProductListState {
  const ProductListState();
}

final class ProductListInProgress extends ProductListState {
  const ProductListInProgress();
}

/// No store is selected, so there is no catalogue to show. Distinct from an
/// empty catalogue: the answer is "pick a store", not "add a product".
final class ProductListNoStore extends ProductListState {
  const ProductListNoStore();
}

final class ProductListFailure extends ProductListState {
  const ProductListFailure(this.error);

  final DataError error;
}

final class ProductListSuccess extends ProductListState {
  const ProductListSuccess({
    required this.products,
    this.filter = ProductStatusFilter.all,
  });

  final List<Product> products;
  final ProductStatusFilter filter;

  List<Product> get visible => switch (filter) {
        ProductStatusFilter.all => products,
        ProductStatusFilter.draft => _withStatus(ProductStatus.draft),
        ProductStatusFilter.active => _withStatus(ProductStatus.active),
        ProductStatusFilter.inactive => _withStatus(ProductStatus.inactive),
      };

  int get draftCount =>
      products.where((product) => product.isDraft).length;

  bool get isEmpty => products.isEmpty;

  List<Product> _withStatus(String status) => products
      .where((product) => product.status == status)
      .toList(growable: false);

  ProductListSuccess copyWith({
    List<Product>? products,
    ProductStatusFilter? filter,
  }) =>
      ProductListSuccess(
        products: products ?? this.products,
        filter: filter ?? this.filter,
      );
}

/// Applied client-side — `GET /stores/{id}/products` takes no status filter.
enum ProductStatusFilter {
  all('Semua'),
  draft('Draf'),
  active('Aktif'),
  inactive('Nonaktif');

  const ProductStatusFilter(this.label);

  final String label;
}
