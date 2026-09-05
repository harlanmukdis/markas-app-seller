import '../../data_state.dart';
import '../../domain/model/catalog/offer.dart';
import '../../domain/repositories/offer_repository.dart';
import '../datasources/remote/service/offer_service.dart';
import 'repository_guard.dart';

class OfferRepositoryImpl with RepositoryGuard implements OfferRepository {
  const OfferRepositoryImpl(this._service);

  final OfferService _service;

  @override
  Future<DataState<List<Offer>>> getOffers({String? status}) =>
      guard(() => _service.getOffers(status: status));

  @override
  Future<DataState<Offer>> getOffer(int offerId) =>
      guard(() => _service.getOffer(offerId));

  @override
  Future<DataState<int>> createMasterOffer({
    required int categoryId,
    required int skuId,
    double? minOrderQty,
    String? handlingClass,
    List<OfferPhoto> photos = const <OfferPhoto>[],
    String? description,
  }) =>
      guard(() => _service.createMasterOffer(
            categoryId: categoryId,
            skuId: skuId,
            minOrderQty: minOrderQty,
            handlingClass: handlingClass,
            photos: photos,
            description: description,
          ));

  @override
  Future<DataState<int>> createFreeformOffer({
    required int categoryId,
    required String freeformName,
    required double freeformWeightKg,
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    double? minOrderQty,
    String? handlingClass,
    List<OfferPhoto> photos = const <OfferPhoto>[],
    String? description,
  }) =>
      guard(() => _service.createFreeformOffer(
            categoryId: categoryId,
            freeformName: freeformName,
            freeformWeightKg: freeformWeightKg,
            lengthCm: lengthCm,
            widthCm: widthCm,
            heightCm: heightCm,
            minOrderQty: minOrderQty,
            handlingClass: handlingClass,
            photos: photos,
            description: description,
          ));

  @override
  Future<DataState<Offer>> updateOffer(
    int offerId, {
    double? minOrderQty,
    String? handlingClass,
    List<OfferPhoto>? photos,
    String? description,
    String? freeformName,
  }) =>
      guard(() => _service.updateOffer(
            offerId,
            minOrderQty: minOrderQty,
            handlingClass: handlingClass,
            photos: photos,
            description: description,
            freeformName: freeformName,
          ));

  @override
  Future<DataState<List<PriceTier>>> replacePriceTiers(
    int offerId,
    List<PriceTier> tiers,
  ) =>
      guard(() => _service.replacePriceTiers(offerId, tiers));

  @override
  Future<DataState<OfferGates>> getGates(int offerId) =>
      guard(() => _service.getGates(offerId));

  @override
  Future<DataState<OfferGates>> activate(int offerId) =>
      guard(() => _service.activate(offerId));

  @override
  Future<DataState<bool>> deactivate(int offerId) => guard(() async {
        await _service.deactivate(offerId);
        return true;
      });
}
