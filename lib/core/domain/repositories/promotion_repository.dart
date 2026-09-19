import '../../data_state.dart';
import '../model/promotion/flash_sale.dart';
import '../model/promotion/flash_sale_product.dart';
import '../model/promotion/store_voucher.dart';

/// Store vouchers and flash sales.
///
/// Every create returns the list as it stands afterwards rather than the row it
/// made: `POST` answers `{ "id": N }` and nothing on these paths can be read
/// back individually, so re-reading the list is the only way to show what was
/// saved.
abstract class PromotionRepository {
  Future<DataState<List<StoreVoucher>>> getStoreVouchers(int storeId);

  Future<DataState<List<StoreVoucher>>> createVoucher(
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
  });

  Future<DataState<List<FlashSale>>> getStoreFlashSales(int storeId);

  Future<DataState<List<FlashSale>>> createFlashSale(
    int storeId, {
    required String name,
    required DateTime startAt,
    required DateTime endAt,
  });

  Future<DataState<List<FlashSaleProduct>>> getFlashSaleProducts(
    int flashSaleId,
  );

  Future<DataState<List<FlashSaleProduct>>> addFlashSaleProduct(
    int flashSaleId, {
    required int productVariantId,
    required int flashPrice,
    required int stockQuota,
    int maxQtyPerUser = 1,
  });
}
