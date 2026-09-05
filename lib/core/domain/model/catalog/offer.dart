import '../../../utils/json_parse.dart';

/// What a buyer actually buys: one store's listing against one master SKU (or
/// a freeform product in a `BEBAS` category), carrying price, stock and MOQ.
class Offer {
  const Offer({
    required this.id,
    this.sellerId,
    this.skuId,
    this.categoryId,
    this.isFreeform = false,
    this.isTemporaryListing = false,
    this.freeformName,
    this.freeformWeightKg,
    this.freeformLengthCm,
    this.freeformWidthCm,
    this.freeformHeightCm,
    this.handlingClass,
    this.photos = const <OfferPhoto>[],
    this.minOrderQty = 1,
    this.status,
    this.rejectReason,
    this.description,
    this.priceTiers = const <PriceTier>[],
  });

  final int id;
  final int? sellerId;
  final int? skuId;
  final int? categoryId;
  final bool isFreeform;

  /// Set when the catalogue team did not answer a SKU request within 3×24h and
  /// the product went live automatically as this store's temporary listing
  /// (CAT-05).
  final bool isTemporaryListing;

  final String? freeformName;
  final double? freeformWeightKg;
  final double? freeformLengthCm;
  final double? freeformWidthCm;
  final double? freeformHeightCm;
  final String? handlingClass;
  final List<OfferPhoto> photos;
  final double minOrderQty;
  final String? status;
  final String? rejectReason;
  final String? description;
  final List<PriceTier> priceTiers;

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
        id: asInt(json['id']),
        sellerId: asIntOrNull(json['seller_id']),
        skuId: asIntOrNull(json['sku_id']),
        categoryId: asIntOrNull(json['category_id']),
        isFreeform: asBool(json['is_freeform']),
        isTemporaryListing: asBool(json['is_temporary_listing']),
        freeformName: asStringOrNull(json['freeform_name']),
        freeformWeightKg: asDoubleOrNull(json['freeform_weight_kg']),
        freeformLengthCm: asDoubleOrNull(json['freeform_length_cm']),
        freeformWidthCm: asDoubleOrNull(json['freeform_width_cm']),
        freeformHeightCm: asDoubleOrNull(json['freeform_height_cm']),
        handlingClass: asStringOrNull(json['handling_class']),
        // The backend returns this column as a JSON **string**, not an array.
        photos: asEncodedMapList(json['photos_json'])
            .map(OfferPhoto.fromJson)
            .toList(growable: false),
        minOrderQty: asDouble(json['min_order_qty'], fallback: 1),
        status: asStringOrNull(json['status']),
        rejectReason: asStringOrNull(json['reject_reason']),
        description: asStringOrNull(json['description']),
        priceTiers: asModelList(json['price_tiers'], PriceTier.fromJson),
      );

  bool get isActive => status == OfferStatus.active;

  List<PriceTier> get retailTiers =>
      priceTiers.where((tier) => tier.isRetail).toList();

  /// The four listing gates (W2) as far as the client can tell without calling
  /// `/offers/{id}/gates`. Used to grey out the activate button early.
  bool get hasRetailTier => retailTiers.isNotEmpty;

  bool get photosOk =>
      photos.length >= 3 && photos.every((photo) => photo.meetsMinimum);
}

abstract class OfferStatus {
  static const String draft = 'DRAFT';
  static const String pendingModeration = 'PENDING_MODERATION';
  static const String active = 'ACTIVE';
  static const String inactive = 'INACTIVE';
  static const String rejected = 'REJECTED';

  static String label(String? status) => switch (status) {
        draft => 'Draft',
        pendingModeration => 'Menunggu moderasi',
        active => 'Tayang',
        inactive => 'Tidak tayang',
        rejected => 'Ditolak',
        _ => status ?? '-',
      };
}

/// One entry of `photos_json`.
///
/// The dimensions matter: photo validation (PRD-11) reads `width`/`height`
/// from each element and never opens the file. A plain array of URL strings
/// makes width read as 0, `photos_ok` fail forever, and activation get
/// rejected with no clear reason — so the app must measure images itself.
class OfferPhoto {
  const OfferPhoto({
    required this.url,
    required this.width,
    required this.height,
  });

  static const int minimumEdge = 800;
  static const int minimumCount = 3;

  final String url;
  final int width;
  final int height;

  factory OfferPhoto.fromJson(Map<String, dynamic> json) => OfferPhoto(
        url: asString(json['url']),
        width: asInt(json['width']),
        height: asInt(json['height']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'url': url,
        'width': width,
        'height': height,
      };

  bool get meetsMinimum => width >= minimumEdge && height >= minimumEdge;
}

class PriceTier {
  const PriceTier({
    required this.segment,
    required this.minQty,
    required this.price,
    this.id,
    this.offerId,
    this.strikethroughPrice,
    this.strikethroughSince,
  });

  final String segment;
  final double minQty;
  final int price;
  final int? id;
  final int? offerId;

  /// Silently dropped by the server unless the price is proven to have held
  /// for ≥14 days in `price_history` (PRD-07) — no error is returned, the
  /// value simply vanishes from the response.
  final int? strikethroughPrice;
  final DateTime? strikethroughSince;

  factory PriceTier.fromJson(Map<String, dynamic> json) => PriceTier(
        segment: asString(json['segment'], fallback: PriceSegment.retail),
        minQty: asDouble(json['min_qty'], fallback: 1),
        price: asInt(json['price']),
        id: asIntOrNull(json['id']),
        offerId: asIntOrNull(json['offer_id']),
        strikethroughPrice: asIntOrNull(json['strikethrough_price']),
        strikethroughSince: asDateTime(json['strikethrough_since']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'segment': segment,
        'min_qty': minQty,
        'price': price,
        if (strikethroughPrice != null)
          'strikethrough_price': strikethroughPrice,
      };

  bool get isRetail => segment == PriceSegment.retail;
}

abstract class PriceSegment {
  static const String retail = 'RETAIL';

  /// Only visible to verified B2B buyers.
  static const String project = 'PROJECT';

  static const List<String> all = <String>[retail, project];

  static String label(String? segment) => switch (segment) {
        retail => 'Retail (eceran)',
        project => 'Project (B2B)',
        _ => segment ?? '-',
      };
}

/// `GET /offers/{id}/gates` — preview of the four listing gates.
class OfferGates {
  const OfferGates({
    this.sellerVerified = false,
    this.hasShippingRate = false,
    this.hasRetailTier = false,
    this.photosOk = false,
    this.allPassed = false,
  });

  final bool sellerVerified;
  final bool hasShippingRate;
  final bool hasRetailTier;
  final bool photosOk;
  final bool allPassed;

  factory OfferGates.fromJson(Map<String, dynamic> json) => OfferGates(
        sellerVerified: asBool(json['seller_verified']),
        hasShippingRate: asBool(json['has_shipping_rate']),
        hasRetailTier: asBool(json['has_retail_tier']),
        photosOk: asBool(json['photos_ok']),
        allPassed: asBool(json['all_passed']),
      );

  /// Human-readable list of what is still blocking the listing.
  List<String> get blockers => <String>[
        if (!sellerVerified) 'Toko belum berstatus VERIFIED',
        if (!hasShippingRate) 'Belum ada tarif ongkir',
        if (!hasRetailTier) 'Belum ada tier harga RETAIL',
        if (!photosOk)
          'Foto belum memenuhi syarat (minimal 3 foto, masing-masing ≥ 800×800)',
      ];
}
