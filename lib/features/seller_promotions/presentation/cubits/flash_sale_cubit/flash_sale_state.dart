part of 'flash_sale_cubit.dart';

sealed class FlashSaleState {
  const FlashSaleState();
}

final class FlashSaleInProgress extends FlashSaleState {
  const FlashSaleInProgress();
}

final class FlashSaleNoStore extends FlashSaleState {
  const FlashSaleNoStore();
}

final class FlashSaleFailure extends FlashSaleState {
  const FlashSaleFailure(this.error);

  final DataError error;
}

final class FlashSaleLoaded extends FlashSaleState {
  const FlashSaleLoaded(this.sales, {this.isBusy = false});

  final List<FlashSale> sales;
  final bool isBusy;

  /// Sales whose window is open but whose status was never advanced, so buyers
  /// see nothing. Surfaced as a banner because there is no endpoint that can
  /// repair one from the app.
  List<FlashSale> stalled(DateTime now) => sales
      .where((sale) => sale.phaseAt(now) == FlashSalePhase.stalled)
      .toList(growable: false);

  FlashSaleLoaded copyWith({List<FlashSale>? sales, bool? isBusy}) =>
      FlashSaleLoaded(sales ?? this.sales, isBusy: isBusy ?? this.isBusy);
}
