import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/voucher/voucher.dart';
import 'base_service.dart';

class VoucherService extends BaseService {
  const VoucherService(super.dio);

  Future<List<Voucher>> getVouchers({int? sellerId}) async {
    final envelope = await getRequest(
      ApiEndpoints.vouchers,
      query: <String, dynamic>{'seller_id': sellerId},
    );
    return envelope
        .listAt('vouchers')
        .map(Voucher.fromJson)
        .toList(growable: false);
  }

  /// `funded_by` is forced to SELLER for a `SEL` token, and `seller_id` comes
  /// from the token — a store cannot create a platform-funded voucher. The
  /// cost is deducted from its payouts as `voucher_seller_burden`.
  Future<Voucher> createVoucher({
    required String code,
    required String discountType,
    required double discountValue,
    required int quotaTotal,
    required String validFrom,
    required String validTo,
    int? maxDiscountAmount,
    int? minSpend,
    int? quotaPerUser,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.vouchers,
      body: <String, dynamic>{
        'code': code,
        'discount_type': discountType,
        'discount_value': discountValue,
        'quota_total': quotaTotal,
        'valid_from': validFrom,
        'valid_to': validTo,
        'max_discount_amount': maxDiscountAmount,
        'min_spend': minSpend,
        'quota_per_user': quotaPerUser,
      },
    );
    return Voucher.fromJson(envelope.map);
  }

  Future<Voucher> updateVoucher(
    int voucherId, {
    double? discountValue,
    int? maxDiscountAmount,
    int? minSpend,
    int? quotaTotal,
    int? quotaPerUser,
    String? validFrom,
    String? validTo,
    String? status,
  }) async {
    final envelope = await putRequest(
      ApiEndpoints.voucher(voucherId),
      body: <String, dynamic>{
        'discount_value': discountValue,
        'max_discount_amount': maxDiscountAmount,
        'min_spend': minSpend,
        'quota_total': quotaTotal,
        'quota_per_user': quotaPerUser,
        'valid_from': validFrom,
        'valid_to': validTo,
        'status': status,
      },
    );
    return Voucher.fromJson(envelope.map);
  }

  /// Soft delete — the voucher becomes INACTIVE rather than disappearing.
  Future<void> deleteVoucher(int voucherId) async {
    await deleteRequest(ApiEndpoints.voucher(voucherId));
  }
}
