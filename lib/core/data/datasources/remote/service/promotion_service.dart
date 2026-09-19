import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/promotion/flash_sale.dart';
import '../../../../domain/model/promotion/flash_sale_product.dart';
import '../../../../domain/model/promotion/store_voucher.dart';
import '../../../../utils/format_helper.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

/// Store vouchers and flash sales.
///
/// Both surfaces are **create and list only**. Neither path implements `PATCH`
/// or `DELETE`, so nothing here can edit, pause or remove what it made — which
/// is the single most important thing for a screen above this to say out loud
/// before it submits.
///
/// The controller validates almost nothing. Only a voucher's `name` is checked
/// (a proper `422`); every other field is read straight out of the decoded body
/// with no fallback, so **omitting one is an HTTP 500 carrying a PHP warning**,
/// not a validation error. Each required argument below is required for that
/// reason rather than for tidiness.
class PromotionService extends BaseService {
  const PromotionService(super.dio);

  // ------------------------------------------------------------- vouchers

  /// Every voucher the store has ever created, newest first.
  ///
  /// Unusually for this API the query carries no `LIMIT`, so this one really
  /// is the whole list rather than a silently truncated first page.
  Future<List<StoreVoucher>> getStoreVouchers(int storeId) async {
    final envelope = await getRequest(
      ApiEndpoints.storeVouchers(storeId),
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return asModelList(envelope.data, StoreVoucher.fromJson);
  }

  /// Creates a voucher and returns its id.
  ///
  /// [code] is optional: left out, the server generates `VC-XXXXXXXX`. Supplied
  /// and already taken, the `UNIQUE` column raises a duplicate-key error that
  /// nothing catches — an HTML 500 rather than a 409 — and the uniqueness is
  /// platform-wide, so another store's code can collide with this one.
  ///
  /// [discountValue] is a percentage when [discountType] is `percentage` and
  /// rupiah otherwise. Neither the enum nor the range is enforced server-side:
  /// MySQL is not in strict mode, so an unrecognised `discount_type` is coerced
  /// to `''` and stored, and `500` percent is accepted.
  Future<int> createVoucher(
    int storeId, {
    required String name,
    required String discountType,
    required int discountValue,
    required int quota,
    required DateTime validFrom,
    required DateTime validUntil,
    String? code,
    int? maxDiscount,
    int minSpend = 0,
    int maxUsePerUser = 1,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.storeVouchers(storeId),
      body: <String, dynamic>{
        'name': name,
        'discount_type': discountType,
        'discount_value': discountValue,
        'quota': quota,
        'valid_from': formatApiDateTime(validFrom),
        'valid_until': formatApiDateTime(validUntil),
        if (code != null && code.isNotEmpty) 'code': code,
        if (maxDiscount != null) 'max_discount': maxDiscount,
        'min_spend': minSpend,
        'max_use_per_user': maxUsePerUser,
      },
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return asInt(envelope.map['id']);
  }

  // ---------------------------------------------------------- flash sales

  /// The store's flash sales, newest window first.
  Future<List<FlashSale>> getStoreFlashSales(int storeId) async {
    final envelope = await getRequest(
      ApiEndpoints.storeFlashSales(storeId),
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return asModelList(envelope.data, FlashSale.fromJson);
  }

  /// Creates a flash sale and returns its id.
  ///
  /// The controller checks nothing at all here — not even the name — so an
  /// absent field is a 500 and a backwards window is a cheerful `201`.
  ///
  /// The created `status` is computed once, by SQL, from whether the window
  /// already covers `NOW()`. A sale created for **later** is therefore born
  /// `scheduled` and depends on `flash_sale_status_worker.php` to ever go
  /// `active`; where that cron is not running it stays `scheduled` through its
  /// entire window and buyers never see it. Nothing the app can call fixes
  /// that, so the screen warns instead.
  Future<int> createFlashSale(
    int storeId, {
    required String name,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.storeFlashSales(storeId),
      body: <String, dynamic>{
        'name': name,
        'start_at': formatApiDateTime(startAt),
        'end_at': formatApiDateTime(endAt),
      },
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return asInt(envelope.map['id']);
  }

  /// What is in a sale. Public on the server; the token is sent anyway because
  /// every other call does.
  Future<List<FlashSaleProduct>> getFlashSaleProducts(int flashSaleId) async {
    final envelope = await getRequest(ApiEndpoints.flashSaleProducts(flashSaleId));
    return asModelList(envelope.data, FlashSaleProduct.fromJson);
  }

  /// Puts one variant into a sale at [flashPrice].
  ///
  /// Two failures to keep away from: the same variant twice in one sale breaks
  /// a `UNIQUE` key and answers an HTML 500, and a flash sale id that does not
  /// exist dereferences null in the controller and answers 403. Both are the
  /// caller's job to avoid.
  ///
  /// [stockQuota] is the sale's own allowance and is **not** checked against
  /// warehouse stock, so a quota above what is on hand will oversell.
  Future<int> addFlashSaleProduct(
    int flashSaleId, {
    required int productVariantId,
    required int flashPrice,
    required int stockQuota,
    int maxQtyPerUser = 1,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.flashSaleProducts(flashSaleId),
      body: <String, dynamic>{
        'product_variant_id': productVariantId,
        'flash_price': flashPrice,
        'stock_quota': stockQuota,
        'max_qty_per_user': maxQtyPerUser,
      },
    );
    return asInt(envelope.map['id']);
  }
}
