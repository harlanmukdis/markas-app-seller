import '../../../utils/json_parse.dart';

/// A set of products sold together for one price.
///
/// Two asymmetries shape every screen built on this. First, the seller's list
/// (`GET /stores/{id}/bundles`) returns bundle rows **without their items** —
/// contents come only from the detail call. Second, that detail call is
/// **public and active-only**: `find_detail` filters `status = 'active'`, so
/// switching a bundle off makes its own owner unable to read it back. Verified
/// live — a bundle created `inactive`, and an active one patched to
/// `inactive`, both answer `404 BUNDLE_NOT_FOUND` to the account that owns
/// them.
///
/// Items are fixed at creation. `PATCH /bundles/{id}` whitelists `name`,
/// `bundle_price` and `status` only, and no route adds or removes an item —
/// so changing what is in a bundle means building another one. There is no
/// `DELETE` either (405); `status: inactive` is the way to retire one.
class ProductBundle {
  const ProductBundle({
    required this.id,
    required this.name,
    this.storeId,
    this.bundlePrice = 0,
    this.status = BundleStatus.active,
    this.items = const <BundleItem>[],
    this.createdAt,
  });

  final int id;
  final String name;
  final int? storeId;
  final int bundlePrice;
  final String status;

  /// Empty on a list row — the seller listing does not join them — and
  /// populated only by `GET /bundles/{id}`.
  final List<BundleItem> items;

  final DateTime? createdAt;

  factory ProductBundle.fromJson(Map<String, dynamic> json) => ProductBundle(
        id: asInt(json['id']),
        name: asString(json['name']),
        storeId: asIntOrNull(json['store_id']),
        bundlePrice: asInt(json['bundle_price']),
        status: asString(json['status'], fallback: BundleStatus.active),
        items: asModelList(json['items'], BundleItem.fromJson),
        createdAt: asCreatedDate(json),
      );

  bool get isActive => status == BundleStatus.active;

  /// What the same goods would cost bought separately — the figure the bundle
  /// price is meant to undercut. Zero when the items have not been loaded.
  int get itemsTotal =>
      items.fold(0, (sum, item) => sum + item.lineTotal);

  int get savings {
    final total = itemsTotal;
    if (total <= 0 || bundlePrice >= total) return 0;
    return total - bundlePrice;
  }

  int get discountPercent {
    final total = itemsTotal;
    if (total <= 0 || bundlePrice >= total) return 0;
    return savings * 100 ~/ total;
  }

  /// True when the bundle costs at least as much as its parts. The server
  /// checks only that the price is above zero, so this is possible.
  bool get isNotADiscount => items.isNotEmpty && savings == 0;
}

/// One line of a bundle, as `GET /bundles/{id}` joins it.
class BundleItem {
  const BundleItem({
    required this.id,
    required this.productId,
    this.variantId,
    this.quantity = 1,
    this.productName = '',
    this.unitPrice = 0,
  });

  final int id;
  final int productId;

  /// Optional: a bundle line may name the product only, in which case the
  /// price falls back to the product's `base_price`.
  final int? variantId;

  final int quantity;
  final String productName;

  /// `COALESCE(variant.price, product.base_price)` — the per-unit price as it
  /// stands **now**, not a snapshot taken when the bundle was built.
  final int unitPrice;

  factory BundleItem.fromJson(Map<String, dynamic> json) => BundleItem(
        id: asInt(json['id']),
        productId: asInt(json['product_id']),
        variantId: asIntOrNull(json['variant_id']),
        quantity: asInt(json['quantity'], fallback: 1),
        productName: asString(json['product_name']),
        unitPrice: asInt(json['unit_price']),
      );

  int get lineTotal => unitPrice * quantity;
}

abstract class BundleStatus {
  static const String active = 'active';
  static const String inactive = 'inactive';

  static const List<String> all = <String>[active, inactive];

  static String label(String? status) => switch (status) {
        active => 'Aktif',
        inactive => 'Nonaktif',
        _ => status ?? '-',
      };
}
