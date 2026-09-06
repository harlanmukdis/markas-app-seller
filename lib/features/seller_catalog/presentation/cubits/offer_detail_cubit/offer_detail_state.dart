part of 'offer_detail_cubit.dart';

sealed class OfferDetailState {
  const OfferDetailState();
}

final class OfferDetailLoadInProgress extends OfferDetailState {
  const OfferDetailLoadInProgress();
}

final class OfferDetailLoadSuccess extends OfferDetailState {
  const OfferDetailLoadSuccess({
    required this.offer,
    this.sku,
    this.gates,
    this.available,
    this.warehouses = const <Warehouse>[],
    this.ledger = const <InventoryLedgerEntry>[],
    this.isBusy = false,
  });

  final Offer offer;

  /// Null for a freeform offer, which has no master SKU behind it.
  final SkuMaster? sku;

  /// The authoritative listing gates. The client can guess at two of them but
  /// only the server knows about `seller_verified` and `has_shipping_rate`.
  final OfferGates? gates;

  final double? available;
  final List<Warehouse> warehouses;
  final List<InventoryLedgerEntry> ledger;
  final bool isBusy;

  String get displayName {
    if (offer.isFreeform) return offer.freeformName ?? 'Produk tanpa nama';
    return sku?.name ?? 'SKU ${offer.skuId ?? '-'}';
  }

  /// Weight and dimensions are locked for a master SKU (PRD-08) and owned by
  /// the store for a freeform one.
  bool get dimensionsAreEditable => offer.isFreeform;

  double? get weightKg =>
      offer.isFreeform ? offer.freeformWeightKg : sku?.weightKg;

  List<String> get blockers => gates?.blockers ?? const <String>[];

  bool get canActivate => (gates?.allPassed ?? false) && !offer.isActive;

  OfferDetailLoadSuccess copyWith({
    Offer? offer,
    SkuMaster? sku,
    OfferGates? gates,
    double? available,
    List<Warehouse>? warehouses,
    List<InventoryLedgerEntry>? ledger,
    bool? isBusy,
  }) =>
      OfferDetailLoadSuccess(
        offer: offer ?? this.offer,
        sku: sku ?? this.sku,
        gates: gates ?? this.gates,
        available: available ?? this.available,
        warehouses: warehouses ?? this.warehouses,
        ledger: ledger ?? this.ledger,
        isBusy: isBusy ?? this.isBusy,
      );
}

final class OfferDetailLoadFailure extends OfferDetailState {
  const OfferDetailLoadFailure(this.error);

  final DataError error;
}
