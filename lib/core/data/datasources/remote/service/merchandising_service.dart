import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/merchandising/product_bundle.dart';
import '../../../../domain/model/merchandising/store_showcase.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

/// The two ways a seller groups products for sale: **bundles** (sold together
/// at one price) and **showcases** (an etalase — the shop's own shelves).
///
/// Both arrived in v1.2.0 and behave quite differently, so the differences are
/// worth stating once here:
///
/// * A bundle's **items are fixed at creation**; a showcase's products can be
///   added and removed freely.
/// * A bundle **cannot be deleted**, only switched off; a showcase can.
/// * A bundle's detail is **active-only**, so switching one off hides it from
///   its own owner; a showcase's contents stay readable.
///
/// Both validate ownership properly — an item or product belonging to another
/// store is refused with a `422` naming it, unlike
/// `POST /flash-sales/{id}/products`, which checks nothing.
class MerchandisingService extends BaseService {
  const MerchandisingService(super.dio);

  // -------------------------------------------------------------- bundles

  /// Every bundle the store has, any status — but **without items**. The
  /// listing does not join them; only [getBundle] carries contents.
  Future<List<ProductBundle>> getStoreBundles(int storeId) async {
    final envelope = await getRequest(
      ApiEndpoints.storeBundles(storeId),
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return asModelList(envelope.data, ProductBundle.fromJson);
  }

  /// One bundle with its items.
  ///
  /// Throws `BUNDLE_NOT_FOUND` for an **inactive** bundle even when the caller
  /// owns it — the query behind this filters on `status = 'active'`. The
  /// server's message for that code is the bare code itself, so a caller that
  /// shows it raw would put `BUNDLE_NOT_FOUND` in front of the user.
  Future<ProductBundle> getBundle(int bundleId) async {
    final envelope = await getRequest(ApiEndpoints.bundle(bundleId));
    return ProductBundle.fromJson(envelope.map);
  }

  /// Creates a bundle and returns its id.
  ///
  /// [items] must be non-empty and every product must belong to the store; a
  /// variant, when given, must belong to its product. All three are checked
  /// server-side and answered as a `422` with a readable message, so this is
  /// one of the few write paths on this API that fails politely.
  Future<int> createBundle(
    int storeId, {
    required String name,
    required int bundlePrice,
    required List<BundleItemDraft> items,
    String status = BundleStatus.active,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.storeBundles(storeId),
      body: <String, dynamic>{
        'name': name,
        'bundle_price': bundlePrice,
        'status': status,
        'items': items.map((item) => item.toJson()).toList(),
      },
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return asInt(envelope.map['id']);
  }

  /// Renames, reprices or switches a bundle. **Items cannot be changed** —
  /// they are not in the whitelist and no other route reaches them.
  Future<void> updateBundle(
    int bundleId, {
    String? name,
    int? bundlePrice,
    String? status,
  }) async {
    await patchRequest(
      ApiEndpoints.bundle(bundleId),
      body: <String, dynamic>{
        'name': name,
        'bundle_price': bundlePrice,
        'status': status,
      },
    );
  }

  // ------------------------------------------------------------ showcases

  /// The store's showcases, ordered by `sort_order`. Public, and carries no
  /// product count.
  Future<List<StoreShowcase>> getStoreShowcases(int storeId) async {
    final envelope = await getRequest(
      ApiEndpoints.storeShowcases(storeId),
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return asModelList(envelope.data, StoreShowcase.fromJson);
  }

  Future<int> createShowcase(
    int storeId, {
    required String name,
    int sortOrder = 0,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.storeShowcases(storeId),
      body: <String, dynamic>{'name': name, 'sort_order': sortOrder},
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return asInt(envelope.map['id']);
  }

  Future<void> updateShowcase(
    int showcaseId, {
    String? name,
    int? sortOrder,
  }) async {
    await patchRequest(
      ApiEndpoints.showcase(showcaseId),
      body: <String, dynamic>{'name': name, 'sort_order': sortOrder},
    );
  }

  /// Deletes the showcase itself. The products are untouched — only the
  /// grouping goes.
  Future<void> deleteShowcase(int showcaseId) async {
    await deleteRequest(ApiEndpoints.showcase(showcaseId));
  }

  /// The products in a showcase, paged at twenty.
  ///
  /// **Active products only.** A draft added here is accepted and then never
  /// listed, so what comes back can be smaller than what was put in.
  Future<List<ShowcaseProduct>> getShowcaseProducts(
    int showcaseId, {
    int page = 1,
  }) async {
    final envelope = await getRequest(
      ApiEndpoints.showcaseProducts(showcaseId),
      query: <String, dynamic>{'page': page},
    );
    return asModelList(envelope.data, ShowcaseProduct.fromJson);
  }

  /// Adds one product. Answers `201` with **no id at all**, so there is
  /// nothing to return — re-read the list instead.
  ///
  /// A product already in this showcase is a `422`, not a duplicate row: the
  /// pair is unique, and the server checks before inserting rather than
  /// letting the constraint fire.
  Future<void> addShowcaseProduct(
    int showcaseId, {
    required int productId,
    int sortOrder = 0,
  }) async {
    await postRequest(
      ApiEndpoints.showcaseProducts(showcaseId),
      body: <String, dynamic>{
        'product_id': productId,
        'sort_order': sortOrder,
      },
    );
  }

  /// Removal is **by product id**, not by a membership row id — and answers
  /// `404 SHOWCASE_PRODUCT_NOT_FOUND` when the product was not in there,
  /// rather than the silent `200` it used to give before v1.3.0.
  Future<void> removeShowcaseProduct(int showcaseId, int productId) async {
    await deleteRequest(ApiEndpoints.showcaseProduct(showcaseId, productId));
  }
}

/// One line of a bundle being created. Separate from [BundleItem], which is
/// what comes back — a draft has no id, no name and no price, because the
/// server resolves all three.
class BundleItemDraft {
  const BundleItemDraft({
    required this.productId,
    this.variantId,
    this.quantity = 1,
  });

  final int productId;
  final int? variantId;
  final int quantity;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'product_id': productId,
        if (variantId != null) 'variant_id': variantId,
        'quantity': quantity,
      };
}
