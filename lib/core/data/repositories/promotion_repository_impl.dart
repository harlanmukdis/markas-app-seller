import '../../data_state.dart';
import '../../domain/model/promotion/flash_sale.dart';
import '../../domain/model/promotion/flash_sale_product.dart';
import '../../domain/model/promotion/store_voucher.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../datasources/remote/service/promotion_service.dart';
import 'repository_guard.dart';

class PromotionRepositoryImpl with RepositoryGuard implements PromotionRepository {
  const PromotionRepositoryImpl(this._service);

  final PromotionService _service;

  @override
  Future<DataState<List<StoreVoucher>>> getStoreVouchers(int storeId) =>
      guard(() => _service.getStoreVouchers(storeId));

  @override
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
  }) =>
      guard(() async {
        await _service.createVoucher(
          storeId,
          name: name,
          discountType: discountType,
          discountValue: discountValue,
          quota: quota,
          validFrom: validFrom,
          validUntil: validUntil,
          code: code,
          maxDiscount: maxDiscount,
          minSpend: minSpend,
          maxUsePerUser: maxUsePerUser,
        );
        return _service.getStoreVouchers(storeId);
      });

  @override
  Future<DataState<List<FlashSale>>> getStoreFlashSales(int storeId) =>
      guard(() => _service.getStoreFlashSales(storeId));

  @override
  Future<DataState<List<FlashSale>>> createFlashSale(
    int storeId, {
    required String name,
    required DateTime startAt,
    required DateTime endAt,
  }) =>
      guard(() async {
        await _service.createFlashSale(
          storeId,
          name: name,
          startAt: startAt,
          endAt: endAt,
        );
        return _service.getStoreFlashSales(storeId);
      });

  @override
  Future<DataState<List<FlashSaleProduct>>> getFlashSaleProducts(
    int flashSaleId,
  ) =>
      guard(() => _service.getFlashSaleProducts(flashSaleId));

  @override
  Future<DataState<List<FlashSaleProduct>>> addFlashSaleProduct(
    int flashSaleId, {
    required int productVariantId,
    required int flashPrice,
    required int stockQuota,
    int maxQtyPerUser = 1,
  }) =>
      guard(() async {
        await _service.addFlashSaleProduct(
          flashSaleId,
          productVariantId: productVariantId,
          flashPrice: flashPrice,
          stockQuota: stockQuota,
          maxQtyPerUser: maxQtyPerUser,
        );
        return _service.getFlashSaleProducts(flashSaleId);
      });
}
