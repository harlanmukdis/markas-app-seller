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
    this.tiersLoaded = false,
    this.busyOfferId,
  });

  final List<Offer> offers;

  /// Master SKUs keyed by id, so a MASTER-path offer can show a real product
  /// name instead of "SKU 3".
  final Map<int, SkuMaster> skus;

  /// Available quantity per offer id.
  final Map<int, double> stock;

  /// True once each offer has been re-read from the detail endpoint, which is
  /// the only place `price_tiers` comes from. Until then price and gate
  /// information is unknown rather than absent, and must not be reported as
  /// "no price set".
  final bool tiersLoaded;

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
    bool? tiersLoaded,
    int? busyOfferId,
    bool clearBusy = false,
  }) =>
      OffersLoadSuccess(
        offers: offers ?? this.offers,
        skus: skus ?? this.skus,
        stock: stock ?? this.stock,
        tiersLoaded: tiersLoaded ?? this.tiersLoaded,
        busyOfferId: clearBusy ? null : (busyOfferId ?? this.busyOfferId),
      );
}

final class OffersLoadFailure extends OffersState {
  const OffersLoadFailure(this.error);

  final DataError error;
}
