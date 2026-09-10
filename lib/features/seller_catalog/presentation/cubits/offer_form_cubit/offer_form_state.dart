part of 'offer_form_cubit.dart';

sealed class OfferFormState {
  const OfferFormState();
}

final class OfferFormLoadInProgress extends OfferFormState {
  const OfferFormLoadInProgress();
}

final class OfferFormLoadFailure extends OfferFormState {
  const OfferFormLoadFailure(this.error);

  final DataError error;
}

final class OfferFormReady extends OfferFormState {
  const OfferFormReady({
    required this.categories,
    this.category,
    this.skuResults = const <SkuMaster>[],
    this.sku,
    this.isSearchingSku = false,
    this.hasSearched = false,
    this.isSubmitting = false,
  });

  final List<Category> categories;
  final Category? category;

  /// Results of the last master-SKU search, scoped to [category].
  final List<SkuMaster> skuResults;
  final SkuMaster? sku;

  final bool isSearchingSku;
  final bool hasSearched;
  final bool isSubmitting;

  /// `BEBAS` categories let the store describe the product itself; `MASTER`
  /// ones require attaching to a platform SKU.
  ///
  /// The server enforces neither — it happily created a freeform offer in a
  /// MASTER category and a master offer in a BEBAS one during testing — and
  /// there is no endpoint to delete an offer afterwards. So this is the only
  /// thing standing between a store and a permanently wrong listing.
  bool get isFreeform => category?.allowsFreeform ?? false;

  bool get needsSku => category?.requiresMasterSku ?? false;

  OfferFormReady copyWith({
    List<Category>? categories,
    Category? category,
    List<SkuMaster>? skuResults,
    SkuMaster? sku,
    bool? isSearchingSku,
    bool? hasSearched,
    bool? isSubmitting,
    bool clearSku = false,
  }) =>
      OfferFormReady(
        categories: categories ?? this.categories,
        category: category ?? this.category,
        skuResults: skuResults ?? this.skuResults,
        sku: clearSku ? null : (sku ?? this.sku),
        isSearchingSku: isSearchingSku ?? this.isSearchingSku,
        hasSearched: hasSearched ?? this.hasSearched,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}
