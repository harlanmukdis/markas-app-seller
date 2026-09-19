part of 'flash_sale_detail_cubit.dart';

sealed class FlashSaleDetailState {
  const FlashSaleDetailState();
}

final class FlashSaleDetailInProgress extends FlashSaleDetailState {
  const FlashSaleDetailInProgress();
}

final class FlashSaleDetailNoStore extends FlashSaleDetailState {
  const FlashSaleDetailNoStore();
}

final class FlashSaleDetailFailure extends FlashSaleDetailState {
  const FlashSaleDetailFailure(this.error);

  final DataError error;
}

final class FlashSaleDetailLoaded extends FlashSaleDetailState {
  const FlashSaleDetailLoaded({
    required this.sale,
    required this.products,
    this.isBusy = false,
  });

  final FlashSale sale;
  final List<FlashSaleProduct> products;
  final bool isBusy;

  /// Variants already in the sale. Adding one twice breaks a `UNIQUE` key and
  /// answers an HTML 500, so the picker hides these rather than letting the
  /// seller find out that way.
  Set<int> get takenVariantIds =>
      products.map((row) => row.productVariantId).toSet();

  FlashSaleDetailLoaded copyWith({
    FlashSale? sale,
    List<FlashSaleProduct>? products,
    bool? isBusy,
  }) =>
      FlashSaleDetailLoaded(
        sale: sale ?? this.sale,
        products: products ?? this.products,
        isBusy: isBusy ?? this.isBusy,
      );
}
