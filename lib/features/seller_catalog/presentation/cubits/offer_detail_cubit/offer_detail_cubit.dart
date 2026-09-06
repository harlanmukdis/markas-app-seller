import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/catalog/offer.dart';
import '../../../../../core/domain/model/catalog/sku_master.dart';
import '../../../../../core/domain/model/inventory/inventory.dart';
import '../../../../../core/domain/model/seller/warehouse.dart';
import '../../../../../core/domain/repositories/catalog_repository.dart';
import '../../../../../core/domain/repositories/inventory_repository.dart';
import '../../../../../core/domain/repositories/offer_repository.dart';
import '../../../../../core/domain/repositories/seller_repository.dart';
import '../../../../../di/injector.dart';

part 'offer_detail_state.dart';

class OfferDetailCubit extends Cubit<OfferDetailState> {
  OfferDetailCubit(this.offerId) : super(const OfferDetailLoadInProgress());

  static OfferDetailCubit get(BuildContext context) => BlocProvider.of(context);

  final int offerId;

  final OfferRepository _offerRepository = injector<OfferRepository>();
  final CatalogRepository _catalogRepository = injector<CatalogRepository>();
  final InventoryRepository _inventoryRepository =
      injector<InventoryRepository>();
  final SellerRepository _sellerRepository = injector<SellerRepository>();

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) emit(const OfferDetailLoadInProgress());

    final offerResult = await _offerRepository.getOffer(offerId);
    if (isClosed) return;

    if (offerResult is DataFailed<Offer>) {
      emit(OfferDetailLoadFailure(offerResult.failure));
      return;
    }
    if (offerResult is! DataSuccess<Offer>) {
      emit(
        const OfferDetailLoadFailure(
          DataError(
            code: DataErrorCode.notFound,
            message: 'Produk tidak ditemukan.',
          ),
        ),
      );
      return;
    }

    final offer = offerResult.value;
    emit(OfferDetailLoadSuccess(offer: offer));

    // Everything else enriches a screen that is already readable, so it lands
    // after the first paint.
    final results = await Future.wait(<Future<Object?>>[
      _offerRepository.getGates(offerId),
      _inventoryRepository.getAvailable(offerId),
      _sellerRepository.getWarehouses(),
      _inventoryRepository.getLedger(offerId),
      if (!offer.isFreeform && offer.skuId != null)
        _catalogRepository.getSkuMaster(offer.skuId!)
      else
        Future<Object?>.value(),
    ]);

    if (isClosed) return;
    final current = state;
    if (current is! OfferDetailLoadSuccess) return;

    emit(
      current.copyWith(
        gates: _valueOrNull<OfferGates>(results[0]),
        available: _valueOrNull<StockAvailability>(results[1])?.available,
        warehouses:
            _valueOrNull<List<Warehouse>>(results[2]) ?? const <Warehouse>[],
        ledger: _valueOrNull<List<InventoryLedgerEntry>>(results[3]) ??
            const <InventoryLedgerEntry>[],
        sku: _valueOrNull<SkuMaster>(results[4]),
      ),
    );
  }

  Future<DataError?> activate() =>
      _act(() => _offerRepository.activate(offerId));

  Future<DataError?> deactivate() =>
      _act(() => _offerRepository.deactivate(offerId));

  Future<DataError?> stockIn({
    required int warehouseId,
    required double qty,
    String? note,
  }) =>
      _act(() => _inventoryRepository.stockIn(
            offerId: offerId,
            warehouseId: warehouseId,
            qty: qty,
            note: note,
          ));

  /// [reason] is mandatory server-side (INV-06) — an unexplained shrinkage is
  /// exactly what the ledger exists to prevent.
  Future<DataError?> adjust({
    required int warehouseId,
    required double qtyDelta,
    required String reason,
  }) =>
      _act(() => _inventoryRepository.adjust(
            offerId: offerId,
            warehouseId: warehouseId,
            qtyDelta: qtyDelta,
            reason: reason,
          ));

  /// Replaces the entire tier list — the endpoint deletes what is there first,
  /// so callers must pass every tier they want to keep.
  Future<DataError?> replacePriceTiers(List<PriceTier> tiers) =>
      _act(() => _offerRepository.replacePriceTiers(offerId, tiers));

  Future<DataError?> _act(Future<DataState<Object>> Function() action) async {
    final current = state;
    if (current is OfferDetailLoadSuccess) emit(current.copyWith(isBusy: true));

    final result = await action();
    if (isClosed) return null;

    if (result is DataFailed<Object>) {
      if (current is OfferDetailLoadSuccess) {
        emit(current.copyWith(isBusy: false));
      }
      return result.failure;
    }

    await load(showSpinner: false);
    return null;
  }

  static T? _valueOrNull<T>(Object? result) =>
      result is DataSuccess<T> ? result.value : null;
}
