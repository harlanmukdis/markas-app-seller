import '../../data_state.dart';
import '../model/voucher/voucher.dart';

abstract class VoucherRepository {
  Future<DataState<List<Voucher>>> getVouchers({int? sellerId});

  Future<DataState<Voucher>> createVoucher({
    required String code,
    required String discountType,
    required double discountValue,
    required int quotaTotal,
    required String validFrom,
    required String validTo,
    int? maxDiscountAmount,
    int? minSpend,
    int? quotaPerUser,
  });

  Future<DataState<Voucher>> updateVoucher(
    int voucherId, {
    double? discountValue,
    int? maxDiscountAmount,
    int? minSpend,
    int? quotaTotal,
    int? quotaPerUser,
    String? validFrom,
    String? validTo,
    String? status,
  });

  /// Soft delete — sets the voucher INACTIVE.
  Future<DataState<bool>> deleteVoucher(int voucherId);
}
