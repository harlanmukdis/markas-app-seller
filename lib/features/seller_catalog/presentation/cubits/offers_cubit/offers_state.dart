part of 'offers_cubit.dart';

sealed class OffersState {
  const OffersState();
}

final class OffersLoadInProgress extends OffersState {
  const OffersLoadInProgress();
}

final class OffersLoadSuccess extends OffersState {
  const OffersLoadSuccess({
    required this.offers,
    this.skus = const <int, SkuMaster>{},
    this.stock = const <int, double>{},
    this.prices = const <int, int>{},
    this.pricesLoaded = false,
    this.busyOfferId,
  });

  final List<Offer> offers;

  /// Master SKUs keyed by id, so a MASTER-path offer can show a real product
  /// name instead of "SKU 3".
  final Map<int, SkuMaster> skus;

  /// Available quantity per offer id.
  final Map<int, double> stock;

  /// Cheapest RETAIL price per offer id, from the v2.4 bulk endpoint. The
  /// list response still has no `price_tiers`, so without this the grid has
  /// no price to show.
  final Map<int, int> prices;

  /// Until the bulk price call lands, a missing price is unknown rather than
  /// absent, and must not be reported as "no price set".
  final bool pricesLoaded;

  final int? busyOfferId;

  String nameFor(Offer offer) {
    if (offer.isFreeform) return offer.freeformName ?? 'Produk tanpa nama';
    final skuId = offer.skuId;
    if (skuId == null) return 'Produk tanpa SKU';
    return skus[skuId]?.name ?? 'SKU $skuId';
  }

  int get activeCount => offers.where((offer) => offer.isActive).length;

  OffersLoadSuccess copyWith({
    List<Offer>? offers,
    Map<int, SkuMaster>? skus,
    Map<int, double>? stock,
    Map<int, int>? prices,
    bool? pricesLoaded,
    int? busyOfferId,
    bool clearBusy = false,
  }) =>
      OffersLoadSuccess(
        offers: offers ?? this.offers,
        skus: skus ?? this.skus,
        stock: stock ?? this.stock,
        prices: prices ?? this.prices,
        pricesLoaded: pricesLoaded ?? this.pricesLoaded,
        busyOfferId: clearBusy ? null : (busyOfferId ?? this.busyOfferId),
      );
}

final class OffersLoadFailure extends OffersState {
  const OffersLoadFailure(this.error);

  final DataError error;
}
