import '../../../config/network/api_exception.dart';
import '../../data_state.dart';
import '../../domain/model/seller/activation_gates.dart';
import '../../domain/model/seller/bank_account.dart';
import '../../domain/model/seller/kyc_document.dart';
import '../../domain/model/seller/seller_model.dart';
import '../../domain/model/seller/warehouse.dart';
import '../../domain/repositories/seller_repository.dart';
import '../datasources/remote/service/seller_service.dart';
import '../local/session_store.dart';
import 'repository_guard.dart';

class SellerRepositoryImpl with RepositoryGuard implements SellerRepository {
  const SellerRepositoryImpl(this._sellerService, this._sessionStore);

  final SellerService _sellerService;
  final SessionStore _sessionStore;

  /// Every seller endpoint needs the id in its path. The backend still checks
  /// it against the token's claim, so this is only about building the URL.
  ///
  /// Throws rather than returning, so [guard] converts it into the same
  /// `NO_SELLER_CONTEXT` failure the backend would have produced — the UI then
  /// has one code path for "this account is not a store".
  int get _sellerId {
    final id = _sessionStore.sellerId;
    if (id == null) {
      throw const ApiException(
        code: DataErrorCode.noSellerContext,
        message: 'Akun ini tidak terhubung ke toko mana pun. Masuk ulang '
            'dengan akun toko.',
        statusCode: 403,
      );
    }
    return id;
  }

  @override
  Future<DataState<SellerModel>> getSeller() =>
      guard(() => _sellerService.getSeller(_sellerId));

  @override
  Future<DataState<SellerModel>> updateSeller({
    String? name,
    String? legalName,
  }) =>
      guard(() => _sellerService.updateSeller(
            _sellerId,
            name: name,
            legalName: legalName,
          ));

  @override
  Future<DataState<KycUploadResult>> uploadKyc({
    required String docType,
    required String fileUrl,
  }) =>
      guard(() async {
        final result = await _sellerService.uploadKyc(
          _sellerId,
          docType: docType,
          fileUrl: fileUrl,
        );
        // Local bookkeeping only — the API has no endpoint that lists KYC
        // documents back, so this is how the upload screen knows what has
        // already been sent.
        await _sessionStore.markKycDocTypeSubmitted(docType);
        return result;
      });

  @override
  Future<DataState<BankAccount>> addBankAccount({
    required String bankName,
    required String accountNo,
    required String accountHolder,
  }) =>
      guard(() => _sellerService.addBankAccount(
            _sellerId,
            bankName: bankName,
            accountNo: accountNo,
            accountHolder: accountHolder,
          ));

  @override
  Future<DataState<List<BankAccount>>> getBankAccounts() =>
      guard(() => _sellerService.getBankAccounts(_sellerId));

  @override
  Future<DataState<ActivationGates>> signAgreement() =>
      guard(() => _sellerService.signAgreement(_sellerId));

  @override
  Future<DataState<List<Warehouse>>> getWarehouses() =>
      guard(() => _sellerService.getWarehouses(_sellerId));

  @override
  Future<DataState<Warehouse>> createWarehouse({
    required String name,
    int? addressId,
  }) =>
      guard(() => _sellerService.createWarehouse(
            _sellerId,
            name: name,
            addressId: addressId,
          ));
}
