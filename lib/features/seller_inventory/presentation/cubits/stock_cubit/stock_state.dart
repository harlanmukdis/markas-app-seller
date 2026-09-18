part of 'stock_cubit.dart';

sealed class StockState {
  const StockState();
}

final class StockInProgress extends StockState {
  const StockInProgress();
}

final class StockFailure extends StockState {
  const StockFailure(this.error);

  final DataError error;
}

final class StockLoaded extends StockState {
  const StockLoaded({
    required this.stocks,
    required this.movements,
    this.isBusy = false,
  });

  final List<WarehouseStock> stocks;

  /// Newest first, one page. The endpoint reports no total, so the list simply
  /// ends where the page does.
  final List<StockMovement> movements;

  final bool isBusy;

  bool get isEmpty => stocks.isEmpty;

  /// Rows worth acting on: at or under a reorder point the seller actually set.
  List<WarehouseStock> get lowStock =>
      stocks.where((stock) => stock.isLow).toList(growable: false);

  int get totalOnHand =>
      stocks.fold(0, (sum, stock) => sum + stock.quantityOnHand);

  /// Held by checkout sessions. Worth surfacing, because it is the reason a
  /// stock-out can be refused for an amount that looks available.
  int get totalReserved =>
      stocks.fold(0, (sum, stock) => sum + stock.quantityReserved);

  StockLoaded copyWith({
    List<WarehouseStock>? stocks,
    List<StockMovement>? movements,
    bool? isBusy,
  }) =>
      StockLoaded(
        stocks: stocks ?? this.stocks,
        movements: movements ?? this.movements,
        isBusy: isBusy ?? this.isBusy,
      );
}
