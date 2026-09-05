import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/catalog/offer.dart';
import '../../../../../core/domain/model/catalog/sku_master.dart';
import '../../../../../core/domain/model/inventory/inventory.dart';
import '../../../../../core/domain/repositories/catalog_repository.dart';
import '../../../../../core/domain/repositories/inventory_repository.dart';
import '../../../../../core/domain/repositories/offer_repository.dart';
import '../../../../../di/injector.dart';

part 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  OffersCubit() : super(const OffersLoadInProgress());

  static OffersCubit get(BuildContext context) => BlocProvider.of(context);

  final OfferRepository _offerRepository = injector<OfferRepository>();
  final CatalogRepository _catalogRepository = injector<CatalogRepository>();
  final InventoryRepository _inventoryRepository =
      injector<InventoryRepository>();

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) emit(const OffersLoadInProgress());

    final result = await _offerRepository.getOffers();
    if (isClosed) return;

    if (result is DataFailed<List<Offer>>) {
      emit(OffersLoadFailure(result.failure));
      return;
    }

    final offers = switch (result) {
      DataSuccess<List<Offer>>(:final value) => value,
      _ => const <Offer>[],
    };

    emit(OffersLoadSuccess(offers: offers));
    if (offers.isEmpty) return;

    // Names, tiers and stock are enrichment: the list is already usable
    // without them, so they load after the first paint rather than delaying it.
    await Future.wait(<Future<void>>[
      _loadSkuNames(offers),
      _loadDetails(offers),
      _loadStock(offers),
    ]);
  }

  /// `GET /offers` omits `price_tiers` — only the detail endpoint returns them.
  /// Without this the list would report "no price set" and "no RETAIL tier" for
  /// every offer, including fully priced ones.
  Future<void> _loadDetails(List<Offer> offers) async {
    final detailed = <int, Offer>{};

    const batchSize = 5;
    for (var i = 0; i < offers.length; i += batchSize) {
      final slice = offers.skip(i).take(batchSize);
      await Future.wait(slice.map((offer) async {
        final result = await _offerRepository.getOffer(offer.id);
        if (result is DataSuccess<Offer>) detailed[offer.id] = result.value;
      }));
      if (isClosed) return;
    }

    final current = state;
    if (current is! OffersLoadSuccess) return;
    emit(
      current.copyWith(
        offers: current.offers
            .map((offer) => detailed[offer.id] ?? offer)
            .toList(growable: false),
        tiersLoaded: true,
      ),
    );
  }

  Future<void> _loadSkuNames(List<Offer> offers) async {
    final skuIds = offers
        .where((offer) => !offer.isFreeform && offer.skuId != null)
        .map((offer) => offer.skuId!)
        .toSet();
    if (skuIds.isEmpty) return;

    final result = await _catalogRepository.getSkuMasterBatch(skuIds);
    if (isClosed) return;

    final current = state;
    if (current is! OffersLoadSuccess) return;
    if (result is DataSuccess<Map<int, SkuMaster>>) {
      emit(current.copyWith(skus: result.value));
    }
  }

  Future<void> _loadStock(List<Offer> offers) async {
    final stock = <int, double>{};

    // Chunked rather than one request per offer fired all at once.
    const batchSize = 5;
    for (var i = 0; i < offers.length; i += batchSize) {
      final slice = offers.skip(i).take(batchSize);
      await Future.wait(slice.map((offer) async {
        final result = await _inventoryRepository.getAvailable(offer.id);
        if (result is DataSuccess<StockAvailability>) {
          stock[offer.id] = result.value.available;
        }
      }));
      if (isClosed) return;
    }

    final current = state;
    if (current is! OffersLoadSuccess) return;
    emit(current.copyWith(stock: stock));
  }

  /// Fails with `422 GATES_NOT_PASSED` when a listing gate is unmet; the
  /// failing gates arrive in `error.details` and are shown verbatim.
  Future<DataError?> activate(int offerId) =>
      _act(offerId, () => _offerRepository.activate(offerId));

  Future<DataError?> deactivate(int offerId) =>
      _act(offerId, () => _offerRepository.deactivate(offerId));

  Future<DataError?> _act(
    int offerId,
    Future<DataState<Object>> Function() action,
  ) async {
    final current = state;
    if (current is OffersLoadSuccess) {
      emit(current.copyWith(busyOfferId: offerId));
    }

    final result = await action();
    if (isClosed) return null;

    if (result is DataFailed<Object>) {
      if (current is OffersLoadSuccess) emit(current.copyWith(clearBusy: true));
      return result.failure;
    }

    await load(showSpinner: false);
    return null;
  }
}
