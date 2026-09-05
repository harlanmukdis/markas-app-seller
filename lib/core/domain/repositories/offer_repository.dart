import '../../data_state.dart';
import '../model/catalog/offer.dart';

abstract class OfferRepository {
  Future<DataState<List<Offer>>> getOffers({String? status});

  Future<DataState<Offer>> getOffer(int offerId);

  Future<DataState<int>> createMasterOffer({
    required int categoryId,
    required int skuId,
    double? minOrderQty,
    String? handlingClass,
    List<OfferPhoto> photos,
    String? description,
  });

  Future<DataState<int>> createFreeformOffer({
    required int categoryId,
    required String freeformName,
    required double freeformWeightKg,
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    double? minOrderQty,
    String? handlingClass,
    List<OfferPhoto> photos,
    String? description,
  });

  Future<DataState<Offer>> updateOffer(
    int offerId, {
    double? minOrderQty,
    String? handlingClass,
    List<OfferPhoto>? photos,
    String? description,
    String? freeformName,
  });

  /// Replaces the whole tier list — send every tier, not just the changed one.
  Future<DataState<List<PriceTier>>> replacePriceTiers(
    int offerId,
    List<PriceTier> tiers,
  );

  Future<DataState<OfferGates>> getGates(int offerId);

  Future<DataState<OfferGates>> activate(int offerId);

  Future<DataState<bool>> deactivate(int offerId);
}
