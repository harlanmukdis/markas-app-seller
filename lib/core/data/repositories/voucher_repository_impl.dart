import '../../data_state.dart';
import '../../domain/model/voucher/voucher.dart';
import '../../domain/repositories/voucher_repository.dart';
import '../datasources/remote/service/voucher_service.dart';
import 'repository_guard.dart';

class VoucherRepositoryImpl with RepositoryGuard implements VoucherRepository {
  const VoucherRepositoryImpl(this._service);

  final VoucherService _service;

  @override
  Future<DataState<List<Voucher>>> getVouchers({int? sellerId}) =>
      guard(() => _service.getVouchers(sellerId: sellerId));

  @override
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
  }) =>
      guard(() => _service.createVoucher(
            code: code,
            discountType: discountType,
            discountValue: discountValue,
            quotaTotal: quotaTotal,
            validFrom: validFrom,
            validTo: validTo,
            maxDiscountAmount: maxDiscountAmount,
            minSpend: minSpend,
            quotaPerUser: quotaPerUser,
          ));

  @override
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
  }) =>
      guard(() => _service.updateVoucher(
            voucherId,
            discountValue: discountValue,
            maxDiscountAmount: maxDiscountAmount,
            minSpend: minSpend,
            quotaTotal: quotaTotal,
            quotaPerUser: quotaPerUser,
            validFrom: validFrom,
            validTo: validTo,
            status: status,
          ));

  @override
  Future<DataState<bool>> deleteVoucher(int voucherId) => guard(() async {
        await _service.deleteVoucher(voucherId);
        return true;
      });
}
