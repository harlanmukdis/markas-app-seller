import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/catalog/offer.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

class OfferService extends BaseService {
  const OfferService(super.dio);

  /// With a `SEL` token this returns only this store's offers, DRAFT included.
  Future<List<Offer>> getOffers({String? status}) async {
    final envelope = await getRequest(
      ApiEndpoints.offers,
      query: <String, dynamic>{'status': status},
    );
    return envelope
        .listAt('offers')
        .map(Offer.fromJson)
        .toList(growable: false);
  }

  Future<Offer> getOffer(int offerId) async {
    final envelope = await getRequest(ApiEndpoints.offer(offerId));
    return Offer.fromJson(envelope.map);
  }

  /// Creates a MASTER-path offer (attached to an existing master SKU).
  ///
  /// [photos] must carry real pixel dimensions: validation reads `width` and
  /// `height` from each entry and never opens the file, so a bare URL list
  /// makes `photos_ok` fail forever with no clear reason (PRD-11).
  Future<int> createMasterOffer({
    required int categoryId,
    required int skuId,
    double? minOrderQty,
    String? handlingClass,
    List<OfferPhoto> photos = const <OfferPhoto>[],
    String? description,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.offers,
      body: <String, dynamic>{
        'category_id': categoryId,
        'sku_id': skuId,
        'min_order_qty': minOrderQty,
        'handling_class': handlingClass,
        'photos_json': photos.map((photo) => photo.toJson()).toList(),
        'description': description,
      },
    );
    return asInt(envelope.map['id']);
  }

  /// Creates a freeform offer, only valid in a `BEBAS` category.
  Future<int> createFreeformOffer({
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
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.offers,
      body: <String, dynamic>{
        'category_id': categoryId,
        'is_freeform': true,
        'freeform_name': freeformName,
        'freeform_weight_kg': freeformWeightKg,
        'freeform_length_cm': lengthCm,
        'freeform_width_cm': widthCm,
        'freeform_height_cm': heightCm,
        'min_order_qty': minOrderQty,
        'handling_class': handlingClass,
        'photos_json': photos.map((photo) => photo.toJson()).toList(),
        'description': description,
      },
    );
    return asInt(envelope.map['id']);
  }

  Future<Offer> updateOffer(
    int offerId, {
    double? minOrderQty,
    String? handlingClass,
    List<OfferPhoto>? photos,
    String? description,
    String? freeformName,
  }) async {
    final envelope = await putRequest(
      ApiEndpoints.offer(offerId),
      body: <String, dynamic>{
        'min_order_qty': minOrderQty,
        'handling_class': handlingClass,
        'photos_json': photos?.map((photo) => photo.toJson()).toList(),
        'description': description,
        'freeform_name': freeformName,
      },
    );
    return Offer.fromJson(envelope.map);
  }

  /// **Replaces** every tier, it does not append. To change one price, read
  /// the current tiers, edit locally, and send the complete list back.
  ///
  /// At least one RETAIL tier is mandatory (`422 MISSING_RETAIL_TIER`) — that
  /// is what stops wholesale pricing leaking to retail buyers (PRD-06).
  Future<List<PriceTier>> replacePriceTiers(
    int offerId,
    List<PriceTier> tiers,
  ) async {
    final envelope = await postRequest(
      ApiEndpoints.offerPriceTiers(offerId),
      body: <String, dynamic>{
        'tiers': tiers.map((tier) => tier.toJson()).toList(),
      },
    );
    final data = envelope.data;
    if (data is List) {
      return asMapList(data).map(PriceTier.fromJson).toList(growable: false);
    }
    return asModelList(envelope.map['tiers'], PriceTier.fromJson);
  }

  Future<OfferGates> getGates(int offerId) async {
    final envelope = await getRequest(ApiEndpoints.offerGates(offerId));
    // Returns 200 with `data: null` for an unknown offer rather than a 404.
    if (envelope.isNull) return const OfferGates();
    return OfferGates.fromJson(envelope.map);
  }

  /// `422 GATES_NOT_PASSED` carries the failing gates in `error.details`.
  Future<OfferGates> activate(int offerId) async {
    final envelope = await postRequest(ApiEndpoints.offerActivate(offerId));
    return OfferGates.fromJson(asMap(envelope.map['gates']));
  }

  Future<void> deactivate(int offerId) async {
    await postRequest(ApiEndpoints.offerDeactivate(offerId));
  }
}
