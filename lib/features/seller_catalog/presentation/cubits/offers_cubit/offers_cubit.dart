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
      _loadDetails(offers),
      _loadStock(offers),
    ]);
  }

  /// `GET /offers` omits `price_tiers` — only the detail endpoint returns
  /// them. Without this the grid would report "no price set" for every offer,
  /// including fully priced ones.
  ///
  /// There is no bulk endpoint for tiers, so this is one read per offer. With
  /// a 50-product catalogue that is 50 requests, which is why results are
  /// emitted per batch: prices fill in as they arrive instead of the whole
  /// grid staying blank until the last one lands. Worth asking the backend to
  /// include tiers in the list response.
  Future<void> _loadDetails(List<Offer> offers) async {
    final detailed = <int, Offer>{};

    const batchSize = 8;
    for (var i = 0; i < offers.length; i += batchSize) {
      final slice = offers.skip(i).take(batchSize);
      await Future.wait(slice.map((offer) async {
        final result = await _offerRepository.getOffer(offer.id);
        if (result is DataSuccess<Offer>) detailed[offer.id] = result.value;
      }));
      if (isClosed) return;

      final current = state;
      if (current is! OffersLoadSuccess) return;
      emit(
        current.copyWith(
          offers: current.offers
              .map((offer) => detailed[offer.id] ?? offer)
              .toList(growable: false),
          // Only true once every offer has been read, so a card that has not
          // arrived yet shows "Harga …" rather than "Harga belum diatur".
          tiersLoaded: i + batchSize >= offers.length,
        ),
      );
    }
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
