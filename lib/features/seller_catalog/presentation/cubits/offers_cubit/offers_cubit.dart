import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/catalog/offer.dart';
import '../../../../../core/domain/model/catalog/sku_master.dart';
import '../../../../../core/domain/model/report/reports.dart';
import '../../../../../core/domain/repositories/catalog_repository.dart';
import '../../../../../core/domain/repositories/report_repository.dart';
import '../../../../../core/domain/repositories/offer_repository.dart';
import '../../../../../di/injector.dart';

part 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  OffersCubit() : super(const OffersLoadInProgress());

  static OffersCubit get(BuildContext context) => BlocProvider.of(context);

  final OfferRepository _offerRepository = injector<OfferRepository>();
  final CatalogRepository _catalogRepository = injector<CatalogRepository>();
  final ReportRepository _reportRepository = injector<ReportRepository>();

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
      _loadPrices(offers),
      _loadStock(offers),
    ]);
  }

  /// Resolves the real product name behind each MASTER-path offer, in one
  /// call (v2.4) rather than one per SKU.
  Future<void> _loadSkuNames(List<Offer> offers) async {
    final skuIds = offers
        .where((offer) => !offer.isFreeform && offer.skuId != null)
        .map((offer) => offer.skuId!)
        .toSet();
    if (skuIds.isEmpty) return;

    final result = await _catalogRepository.getSkuMasterBulk(skuIds);
    if (isClosed) return;

    final current = state;
    if (current is! OffersLoadSuccess) return;
    if (result is DataSuccess<Map<int, SkuMaster>>) {
      emit(current.copyWith(skus: result.value));
    }
  }

  /// Cheapest RETAIL price for every offer, in **one** call (v2.4).
  ///
  /// `GET /offers` still omits `price_tiers`, but `GET /offers/prices?ids=`
  /// now answers the only question the grid actually has. That replaces one
  /// detail read per offer — 50 round trips on a 50-product catalogue — and
  /// uses the same price definition as the buyer's price filter, so the number
  /// a store sees is the number buyers filter on.
  Future<void> _loadPrices(List<Offer> offers) async {
    final result = await _offerRepository.getBulkPrices(
      offers.map((offer) => offer.id),
    );
    if (isClosed) return;

    final current = state;
    if (current is! OffersLoadSuccess) return;
    if (result is! DataSuccess<Map<int, int>>) return;

    emit(current.copyWith(prices: result.value, pricesLoaded: true));
  }

  /// One report call for the whole catalogue rather than one availability
  /// request per offer — with 50 products that was 50 round trips for a number
  /// shown on every card.
  ///
  /// An offer can hold stock in several warehouses, so rows are summed per
  /// offer.
  Future<void> _loadStock(List<Offer> offers) async {
    final result = await _reportRepository.getStock();
    if (isClosed) return;

    final current = state;
    if (current is! OffersLoadSuccess) return;

    if (result is! DataSuccess<List<StockReportRow>>) {
      // Leave stock unknown rather than showing every product as zero.
      return;
    }

    final stock = <int, double>{};
    for (final row in result.value) {
      final offerId = row.offerId;
      if (offerId == null) continue;
      stock[offerId] = (stock[offerId] ?? 0) + row.available;
    }

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
