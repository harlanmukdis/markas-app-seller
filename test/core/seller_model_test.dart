import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/seller/activation_gates.dart';
import 'package:navy_wear/core/domain/model/seller/bank_account.dart';
import 'package:navy_wear/core/domain/model/order/order_model.dart';
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

  _nestedSubOrderTests();

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

/// Captured from `GET /orders/{id}` on the v2.2 backend. The store's line is
/// reached only through the order's nested `sub_orders[]` — `GET /orders`
/// returns plain order rows with no sub-order data at all, so the ids here are
/// the authoritative ones.
void _nestedSubOrderTests() {
  group('SubOrder.fromJson (nested in an order)', () {
    const Map<String, dynamic> nested = <String, dynamic>{
      'id': '5',
      'sub_order_no': 'SO-260907-F6BD6FAD',
      'order_id': '5',
      'seller_id': '1',
      'status_id': '43',
      'status': 'MENUNGGU_KONFIRMASI',
      'seller_confirm_deadline': '2026-09-08 09:01:04',
      'fleet_handover_warn_at': '2026-09-09 09:01:04',
      'fleet_handover_cancel_at': '2026-09-11 09:01:04',
      'subtotal': '190000.00',
      'shipping_total': '750000.00',
      'total': '940000.00',
      'has_custom_item': '0',
      'created_date': '2026-09-07 14:01:04',
      'modified_date': '2026-09-07 14:01:04',
      'created_by': 'SYSTEM',
      'items': <dynamic>[
        <String, dynamic>{
          'id': '5',
          'sub_order_id': '5',
          'offer_id': '69',
          'item_name_snapshot': 'Bata Ringan AAC 7,5 cm',
          'unit_name_snapshot': 'unit',
          'qty': '20.0000',
          'unit_price_snapshot': '9500.00',
          'line_subtotal': '190000.00',
          'weight_kg_snapshot': '144.000',
          'handling_class_snapshot': 'NORMAL',
        },
      ],
      'shipments': <dynamic>[],
    };

    test('reads ids, number and totals', () {
      final subOrder = SubOrder.fromJson(nested);

      expect(subOrder.id, 5);
      expect(subOrder.orderId, 5);
      expect(subOrder.sellerId, 1);
      expect(subOrder.subOrderNo, 'SO-260907-F6BD6FAD');
      expect(subOrder.total, 940000);
      expect(subOrder.items, hasLength(1));
    });

    test('keeps reading the string status, not the new numeric status_id', () {
      // v2.2 added `status_id` alongside `status`. The string is the contract;
      // the id is an internal master-table key.
      final subOrder = SubOrder.fromJson(nested);

      expect(subOrder.status, 'MENUNGGU_KONFIRMASI');
      expect(subOrder.awaitingConfirmation, isTrue);
    });

    test('reads created_date, since created_at no longer exists', () {
      final subOrder = SubOrder.fromJson(nested);

      expect(subOrder.createdAt, isNotNull);
      expect(subOrder.createdAt!.day, 7);
      expect(subOrder.createdAt!.hour, 14);
    });

    test('deadline fields were not renamed by the refactor', () {
      final subOrder = SubOrder.fromJson(nested);

      expect(subOrder.sellerConfirmDeadline, isNotNull);
      expect(subOrder.fleetHandoverCancelAt, isNotNull);
      expect(subOrder.activeDeadline, subOrder.sellerConfirmDeadline);
    });

    test('allows confirm and reject while awaiting confirmation', () {
      final subOrder = SubOrder.fromJson(nested);

      expect(subOrder.canReject, isTrue);
      expect(subOrder.canMarkReady, isFalse);
      expect(subOrder.canCreateShipment, isFalse);
    });

    test('locks rejection for a confirmed sub-order with a custom item', () {
      final locked = SubOrder.fromJson(<String, dynamic>{
        ...nested,
        'status': 'DIKONFIRMASI',
        'has_custom_item': '1',
      });

      expect(locked.canReject, isFalse);
      expect(locked.canMarkReady, isTrue);
    });

    test('reads the item quantity from its DECIMAL string', () {
      final item = SubOrder.fromJson(nested).items.single;

      expect(item.qty, 20);
      expect(item.qtyLabel, '20');
      expect(item.lineSubtotal, 190000);
    });
  });
}
