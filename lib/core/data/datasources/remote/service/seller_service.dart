import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/seller/activation_gates.dart';
import '../../../../domain/model/seller/bank_account.dart';
import '../../../../domain/model/seller/kyc_document.dart';
import '../../../../domain/model/seller/seller_model.dart';
import '../../../../domain/model/seller/warehouse.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

class SellerService extends BaseService {
  const SellerService(super.dio);

  /// The onboarding dashboard's primary read. Always carries
  /// `activation_gates`, which is the only trustworthy source for the
  /// checklist.
  ///
  /// [sellerId] must match the `seller_id` claim in the token or the backend
  /// answers 403 — the path segment is redundant but still checked (API doc 2).
  Future<SellerModel> getSeller(int sellerId) async {
    final envelope = await getRequest(ApiEndpoints.seller(sellerId));
    return SellerModel.fromJson(envelope.map);
  }

  /// A store may only change these two fields. Everything else is admin-only
  /// or has its own endpoint so each transition is recorded; sending anything
  /// more comes back as 422 with `details.allowed` (API doc 5.2).
  Future<SellerModel> updateSeller(
    int sellerId, {
    String? name,
    String? legalName,
  }) async {
    final envelope = await putRequest(
      ApiEndpoints.seller(sellerId),
      body: <String, dynamic>{'name': name, 'legal_name': legalName},
    );
    return SellerModel.fromJson(envelope.map);
  }

  /// Records a KYC document. There is no file upload endpoint anywhere in this
  /// API — the caller must have already put the file in its own storage and
  /// pass the resulting URL (API doc 8).
  Future<KycUploadResult> uploadKyc(
    int sellerId, {
    required String docType,
    required String fileUrl,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.kycUpload(sellerId),
      body: <String, dynamic>{'doc_type': docType, 'file_url': fileUrl},
    );
    return KycUploadResult.fromJson(envelope.map);
  }

  Future<BankAccount> addBankAccount(
    int sellerId, {
    required String bankName,
    required String accountNo,
    required String accountHolder,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.bankAccountAdd(sellerId),
      body: <String, dynamic>{
        'bank_name': bankName,
        'account_no': accountNo,
        'account_holder': accountHolder,
      },
    );
    // The create response is a stub — `{ bank_account_id, status }` — so the
    // submitted values are folded back in to make a complete object.
    final body = envelope.map;
    return BankAccount(
      id: asInt(body['bank_account_id'] ?? body['id']),
      bankName: bankName,
      accountNo: accountNo,
      accountHolder: accountHolder,
      status: asStringOrNull(body['status']),
    );
  }

  Future<List<BankAccount>> getBankAccounts(int sellerId) async {
    final envelope = await getRequest(ApiEndpoints.bankAccounts(sellerId));
    return envelope
        .listAt('bank_accounts')
        .map(BankAccount.fromJson)
        .toList(growable: false);
  }

  /// Signs the cooperation agreement (gate 4).
  ///
  /// Idempotent: signing twice does not overwrite the original date. `confirm`
  /// must be truthy or the call is rejected with 422.
  Future<ActivationGates> signAgreement(int sellerId) async {
    final envelope = await postRequest(
      ApiEndpoints.signAgreement(sellerId),
      body: <String, dynamic>{'confirm': true},
    );
    return ActivationGates.fromJson(asMap(envelope.map['activation_gates']));
  }

  Future<List<Warehouse>> getWarehouses(int sellerId) async {
    final envelope = await getRequest(ApiEndpoints.warehouses(sellerId));
    return envelope
        .listAt('warehouses')
        .map(Warehouse.fromJson)
        .toList(growable: false);
  }

  Future<Warehouse> createWarehouse(
    int sellerId, {
    required String name,
    int? addressId,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.warehouses(sellerId),
      body: <String, dynamic>{'name': name, 'address_id': addressId},
    );
    final body = envelope.map;
    return Warehouse(
      id: asInt(body['warehouse_id'] ?? body['id']),
      name: name,
      addressId: addressId,
    );
  }
}
