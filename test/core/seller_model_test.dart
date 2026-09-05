import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/seller/activation_gates.dart';
import 'package:navy_wear/core/domain/model/seller/bank_account.dart';
import 'package:navy_wear/core/domain/model/seller/seller_model.dart';

/// Parsed against the exact `GET /sellers/{id}` payload printed in the API
/// documentation, string-typed numbers and all.
void main() {
  const Map<String, dynamic> sellerPayload = <String, dynamic>{
    'id': '1',
    'owner_user_id': '2',
    'name': 'Distributor Jaya',
    'slug': 'distributor-jaya-2',
    'legal_name': null,
    'npwp': null,
    'nib_siup_no': null,
    'is_official_store': '0',
    'seller_type': 'DISTRIBUTOR',
    'pkp_status': 'NON_PKP',
    'pkp_effective_date': null,
    'status': 'DRAFT',
    'kyc_approved_at': null,
    'bank_verified_at': null,
    'agreement_signed_at': null,
    'trial_started_at': '2026-09-05 09:39:13',
    'trial_max_order_value': null,
    'trial_hold_days_override': null,
    'net_settled_tx_count': '0',
    'score': '100.00',
    'pph22_exempt': '0',
    'activation_gates': <String, dynamic>{
      'kyc_approved': false,
      'bank_verified': false,
      'has_shipping_rate': false,
      'agreement_signed': false,
      'all_passed': false,
    },
  };

  group('SellerModel.fromJson', () {
    test('reads the documented payload without throwing', () {
      final seller = SellerModel.fromJson(sellerPayload);

      expect(seller.id, 1);
      expect(seller.ownerUserId, 2);
      expect(seller.name, 'Distributor Jaya');
      expect(seller.sellerType, 'DISTRIBUTOR');
      expect(seller.status, 'DRAFT');
      expect(seller.netSettledTxCount, 0);
    });

    test('turns "0" into false, not into a truthy non-empty string', () {
      final seller = SellerModel.fromJson(sellerPayload);

      expect(seller.isOfficialStore, isFalse);
      expect(seller.pph22Exempt, isFalse);
    });

    test('parses the score sent as "100.00"', () {
      expect(SellerModel.fromJson(sellerPayload).score, 100.0);
    });

    test('leaves null timestamps null and parses the one that is set', () {
      final seller = SellerModel.fromJson(sellerPayload);

      expect(seller.kycApprovedAt, isNull);
      expect(seller.agreementSignedAt, isNull);
      expect(seller.trialStartedAt, isNotNull);
      expect(seller.trialStartedAt!.day, 5);
    });

    test('survives a response with fields missing entirely', () {
      final seller = SellerModel.fromJson(<String, dynamic>{'id': '9'});

      expect(seller.id, 9);
      expect(seller.name, '');
      expect(seller.activationGates.allPassed, isFalse);
    });
  });

  group('ActivationGates', () {
    test('counts passed gates and lists the pending ones', () {
      final gates = ActivationGates.fromJson(<String, dynamic>{
        'kyc_approved': true,
        'bank_verified': true,
        'has_shipping_rate': false,
        'agreement_signed': false,
        'all_passed': false,
      });

      expect(gates.passedCount, 2);
      expect(gates.pending, <SellerGate>[
        SellerGate.shippingRate,
        SellerGate.agreement,
      ]);
    });

    test('marks only the two self-serve gates as actionable', () {
      final selfServe = SellerGate.values.where((g) => g.isSelfServe);

      expect(selfServe, <SellerGate>[
        SellerGate.shippingRate,
        SellerGate.agreement,
      ]);
    });
  });

  group('BankAccount', () {
    test('accepts the create response, which uses bank_account_id', () {
      final account = BankAccount.fromJson(<String, dynamic>{
        'bank_account_id': '3',
        'bank_name': 'BCA',
        'account_no': '1234567890',
        'account_holder': 'PT Toko Jaya',
        'status': 'PENDING',
      });

      expect(account.id, 3);
      expect(account.isVerified, isFalse);
    });

    test('masks all but the last four digits', () {
      const account = BankAccount(
        id: 1,
        bankName: 'BCA',
        accountNo: '1234567890',
        accountHolder: 'PT Toko Jaya',
      );

      expect(account.maskedAccountNo, endsWith('7890'));
      expect(account.maskedAccountNo, isNot(contains('123456')));
    });
  });
}
