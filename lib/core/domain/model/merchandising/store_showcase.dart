import '../../../utils/json_parse.dart';

/// A seller's own grouping of products — an "etalase", independent of the
/// platform's category tree.
///
/// One product may sit in several showcases at once, which is what separates
/// this from a category. Full CRUD exists, `DELETE` included — unusual on this
/// API, where most things can only be created.
///
/// The list carries **no product count**, so a showcase's size costs one call
/// per showcase. The screens here show the count only where they have already
/// loaded the contents.
class StoreShowcase {
  const StoreShowcase({
    required this.id,
    required this.name,
    this.storeId,
    this.sortOrder = 0,
    this.createdAt,
  });

  final int id;
  final String name;
  final int? storeId;

  /// What the list is ordered by. Duplicates are allowed and the server does
  /// not renumber, so two showcases can share a position.
  final int sortOrder;

  final DateTime? createdAt;

  factory StoreShowcase.fromJson(Map<String, dynamic> json) => StoreShowcase(
        id: asInt(json['id']),
        name: asString(json['name']),
        storeId: asIntOrNull(json['store_id']),
        sortOrder: asInt(json['sort_order']),
        createdAt: asCreatedDate(json),
      );
}

/// One product inside a showcase, as `GET /showcases/{id}/products` joins it.
///
/// ⚠️ **The query filters `p.status = 'active'`.** A draft product can be
/// added — the ownership check passes and the call answers `201` — and then
/// never appears in this list, to the seller as much as to a buyer. Verified
/// live. Nothing reports it, so a showcase can look emptier than it is.
class ShowcaseProduct {
  const ShowcaseProduct({
    required this.id,
    required this.name,
    this.slug,
    this.basePrice = 0,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.imageUrl,
  });

  /// The product's id — this row is the product, not a join row, so there is
  /// no separate membership id to remove by. Removal is by product id.
  final int id;

  final String name;
  final String? slug;
  final int basePrice;
  final double ratingAvg;
  final int ratingCount;

  /// Resolved the same way as the product listing: the first gallery image,
  /// falling back to a variant's. Null when the product has neither.
  final String? imageUrl;

  factory ShowcaseProduct.fromJson(Map<String, dynamic> json) =>
      ShowcaseProduct(
        id: asInt(json['id']),
        name: asString(json['name']),
        slug: asStringOrNull(json['slug']),
        basePrice: asInt(json['base_price']),
        ratingAvg: asDouble(json['rating_avg']),
        ratingCount: asInt(json['rating_count']),
        imageUrl: asStringOrNull(json['image_url']),
      );

  bool get hasRating => ratingCount > 0;
}
