import '../../data_state.dart';
import '../model/seller/activation_gates.dart';
import '../model/seller/bank_account.dart';
import '../model/seller/kyc_document.dart';
import '../model/seller/seller_model.dart';
import '../model/seller/warehouse.dart';

abstract class SellerRepository {
  Future<DataState<SellerModel>> getSeller();

  Future<DataState<SellerModel>> updateSeller({
    String? name,
    String? legalName,
  });

  Future<DataState<KycUploadResult>> uploadKyc({
    required String docType,
    required String fileUrl,
  });

  Future<DataState<BankAccount>> addBankAccount({
    required String bankName,
    required String accountNo,
    required String accountHolder,
  });

  Future<DataState<List<BankAccount>>> getBankAccounts();

  Future<DataState<ActivationGates>> signAgreement();

  Future<DataState<List<Warehouse>>> getWarehouses();

  Future<DataState<Warehouse>> createWarehouse({
    required String name,
    int? addressId,
  });
}
