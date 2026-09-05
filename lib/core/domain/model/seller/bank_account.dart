import '../../../utils/json_parse.dart';
import '../enums.dart';

class BankAccount {
  const BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNo,
    required this.accountHolder,
    this.status,
  });

  final int id;
  final String bankName;
  final String accountNo;
  final String accountHolder;

  /// `PENDING` until Admin Finance verifies it. Withdrawals against an
  /// unverified account are rejected with 409 (API doc 5.9).
  final String? status;

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
        id: asInt(json['id'] ?? json['bank_account_id']),
        bankName: asString(json['bank_name']),
        accountNo: asString(json['account_no']),
        accountHolder: asString(json['account_holder']),
        status: asStringOrNull(json['status']),
      );

  bool get isVerified => status == DocStatus.verified;

  /// `1234567890` -> `••••••7890`. The full number is never needed on screen.
  String get maskedAccountNo {
    if (accountNo.length <= 4) return accountNo;
    return '${'•' * (accountNo.length - 4)}${accountNo.substring(accountNo.length - 4)}';
  }
}
