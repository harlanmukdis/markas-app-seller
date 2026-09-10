import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/catalog/category.dart';
import '../../../../../core/domain/model/catalog/offer.dart';
import '../../../../../core/domain/model/catalog/sku_master.dart';
import '../../../../../core/domain/model/catalog/sku_request.dart';
import '../../../../../core/domain/repositories/catalog_repository.dart';
import '../../../../../core/domain/repositories/offer_repository.dart';
import '../../../../../di/injector.dart';

part 'offer_form_state.dart';

/// Drives the "new product" screen: pick a category, attach a master SKU or
/// describe a freeform product, then create the offer and its first tiers.
class OfferFormCubit extends Cubit<OfferFormState> {
  OfferFormCubit() : super(const OfferFormLoadInProgress());

  static OfferFormCubit get(BuildContext context) => BlocProvider.of(context);

  final CatalogRepository _catalogRepository = injector<CatalogRepository>();
  final OfferRepository _offerRepository = injector<OfferRepository>();

  Future<void> load() async {
    emit(const OfferFormLoadInProgress());

    final result = await _catalogRepository.getCategories(forceRefresh: false);
    if (isClosed) return;

    switch (result) {
      case DataSuccess<List<Category>>(:final value):
        emit(OfferFormReady(categories: value));
      case DataEmpty<List<Category>>():
        emit(const OfferFormReady(categories: <Category>[]));
      case DataFailed<List<Category>>(:final failure):
        emit(OfferFormLoadFailure(failure));
      case DataLoading<List<Category>>():
        break;
    }
  }

  void selectCategory(Category? category) {
    final current = state;
    if (current is! OfferFormReady || category == null) return;
    if (current.category?.id == category.id) return;

    // The SKU belongs to the old category, so it cannot survive the change.
    emit(
      OfferFormReady(
        categories: current.categories,
        category: category,
        isSubmitting: current.isSubmitting,
      ),
    );
  }

  Future<void> searchSku(String query) async {
    final current = state;
    if (current is! OfferFormReady) return;

    final category = current.category;
    final trimmed = query.trim();
    // The endpoint needs one of `q` or `category_id`; with a category chosen
    // an empty box means "everything in this category", which is a useful
    // default for a small catalogue.
    if (category == null && trimmed.isEmpty) return;

    emit(current.copyWith(isSearchingSku: true));

    final result = await _catalogRepository.searchSkuMaster(
      query: trimmed.isEmpty ? null : trimmed,
      categoryId: category?.id,
    );
    if (isClosed) return;

    final latest = state;
    if (latest is! OfferFormReady) return;

    emit(
      latest.copyWith(
        isSearchingSku: false,
        hasSearched: true,
        skuResults: switch (result) {
          DataSuccess<List<SkuMaster>>(:final value) => value,
          _ => const <SkuMaster>[],
        },
      ),
    );
  }

  void selectSku(SkuMaster? sku) {
    final current = state;
    if (current is! OfferFormReady) return;
    emit(current.copyWith(sku: sku, clearSku: sku == null));
  }

  /// Asks the catalogue team for a master SKU that does not exist yet.
  ///
  /// Answers [SkuRequestSimilarFound] with **nothing created** when the server
  /// spots lookalikes — the caller must show them and let the store either use
  /// one or resubmit with [force].
  Future<DataState<SkuRequestResult>> requestSku({
    required String name,
    String? brand,
    double? weightKg,
    bool force = false,
  }) async {
    final current = state;
    final categoryId = current is OfferFormReady ? current.category?.id : null;
    if (categoryId == null) {
      return const DataFailed<SkuRequestResult>(
        DataError(
          code: DataErrorCode.validationError,
          message: 'Pilih kategori dulu.',
        ),
      );
    }

    return _catalogRepository.createSkuRequest(
      categoryId: categoryId,
      proposedName: name,
      proposedBrand: brand,
      proposedWeightKg: weightKg,
      force: force,
    );
  }

  /// Creates the offer and, when tiers are given, sets them in the same step.
  ///
  /// Returns the new offer id. A tier failure does not undo the offer — there
  /// is no delete endpoint — so the caller is told the offer exists and only
  /// the price is missing.
  Future<OfferCreateOutcome> submit({
    required List<OfferPhoto> photos,
    required List<PriceTier> tiers,
    double? minOrderQty,
    String? handlingClass,
    String? description,
    String? freeformName,
    double? freeformWeightKg,
    double? freeformLengthCm,
    double? freeformWidthCm,
    double? freeformHeightCm,
  }) async {
    final current = state;
    if (current is! OfferFormReady) {
      return const OfferCreateOutcome.failed(
        DataError(
          code: DataErrorCode.unexpected,
          message: 'Formulir belum siap.',
        ),
      );
    }

    final category = current.category;
    if (category == null) {
      return const OfferCreateOutcome.failed(
        DataError(
          code: DataErrorCode.validationError,
          message: 'Pilih kategori dulu.',
        ),
      );
    }

    emit(current.copyWith(isSubmitting: true));

    final created = current.isFreeform
        ? await _offerRepository.createFreeformOffer(
            categoryId: category.id,
            freeformName: freeformName!,
            freeformWeightKg: freeformWeightKg!,
            lengthCm: freeformLengthCm,
            widthCm: freeformWidthCm,
            heightCm: freeformHeightCm,
            minOrderQty: minOrderQty,
            handlingClass: handlingClass,
            photos: photos,
            description: description,
          )
        : await _offerRepository.createMasterOffer(
            categoryId: category.id,
            skuId: current.sku!.id,
            minOrderQty: minOrderQty,
            handlingClass: handlingClass,
            photos: photos,
            description: description,
          );

    if (isClosed) return const OfferCreateOutcome.failed(_gone);

    if (created is DataFailed<int>) {
      final latest = state;
      if (latest is OfferFormReady) emit(latest.copyWith(isSubmitting: false));
      return OfferCreateOutcome.failed(created.failure);
    }
    if (created is! DataSuccess<int>) {
      final latest = state;
      if (latest is OfferFormReady) emit(latest.copyWith(isSubmitting: false));
      return const OfferCreateOutcome.failed(_gone);
    }

    final offerId = created.value;
    if (tiers.isEmpty) return OfferCreateOutcome.created(offerId);

    final priced = await _offerRepository.replacePriceTiers(offerId, tiers);
    if (isClosed) return OfferCreateOutcome.created(offerId);

    final latest = state;
    if (latest is OfferFormReady) emit(latest.copyWith(isSubmitting: false));

    if (priced is DataFailed<List<PriceTier>>) {
      return OfferCreateOutcome.createdWithoutPrice(offerId, priced.failure);
    }
    return OfferCreateOutcome.created(offerId);
  }
}

const DataError _gone = DataError(
  code: DataErrorCode.unexpected,
  message: 'Layar ditutup sebelum server menjawab.',
);

/// Creating an offer is two calls and only the first one is irreversible, so
/// "half done" is a real outcome the screen has to report honestly.
sealed class OfferCreateOutcome {
  const OfferCreateOutcome();

  const factory OfferCreateOutcome.created(int offerId) = OfferCreated;

  const factory OfferCreateOutcome.createdWithoutPrice(
    int offerId,
    DataError error,
  ) = OfferCreatedWithoutPrice;

  const factory OfferCreateOutcome.failed(DataError error) = OfferCreateFailed;
}

final class OfferCreated extends OfferCreateOutcome {
  const OfferCreated(this.offerId);

  final int offerId;
}

final class OfferCreatedWithoutPrice extends OfferCreateOutcome {
  const OfferCreatedWithoutPrice(this.offerId, this.error);

  final int offerId;
  final DataError error;
}

final class OfferCreateFailed extends OfferCreateOutcome {
  const OfferCreateFailed(this.error);

  final DataError error;
}
