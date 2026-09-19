import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/wallet/store_wallet.dart';

/// Payloads captured from the running marketplace API.
void main() {
  Map<String, dynamic> tx({
    required String id,
    required String type,
    required String amount,
    required String before,
    required String after,
    String? referenceType,
    String? referenceId,
  }) =>
      <String, dynamic>{
        'id': id,
        'wallet_type': 'seller',
        'wallet_id': '1',
        'type': type,
        'amount': amount,
        'balance_before': before,
        'balance_after': after,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'idempotency_key': 'k-$id',
        'created_at': '2026-09-19 10:00:00',
      };

  group('StoreWallet.fromJson', () {
    test('reads an untouched wallet', () {
      // Exactly what seed store 1 answers today.
      final wallet = StoreWallet.fromJson(<String, dynamic>{
        'id': '1',
        'store_id': '1',
        'balance': '0.00',
        'held_balance': '0.00',
        'status': 'active',
        'updated_at': '2026-09-19 09:00:00',
        'transactions': <dynamic>[],
      });

      expect(wallet.balance, 0);
      expect(wallet.isFrozen, isFalse);
      expect(wallet.canWithdraw, isFalse, reason: 'below the 50k minimum');
      expect(wallet.totalEarned, 0);
    });

    test('money arrives as a two-decimal string but has no cents', () {
      final wallet = StoreWallet.fromJson(<String, dynamic>{
        'id': '1',
        'store_id': '1',
        'balance': '144750.00',
        'held_balance': '0.00',
        'status': 'active',
      });

      expect(wallet.balance, 144750);
      expect(wallet.canWithdraw, isTrue);
    });

    test('a frozen wallet cannot be withdrawn from however full it is', () {
      final wallet = StoreWallet.fromJson(<String, dynamic>{
        'id': '1',
        'store_id': '1',
        'balance': '5000000.00',
        'status': 'frozen',
      });

      expect(wallet.isFrozen, isTrue);
      expect(wallet.canWithdraw, isFalse);
    });

    test('totalEarned counts only what came in', () {
      final wallet = StoreWallet.fromJson(<String, dynamic>{
        'id': '1',
        'store_id': '1',
        'balance': '94750.00',
        'transactions': <dynamic>[
          tx(
            id: '3',
            type: 'withdraw',
            amount: '50000.00',
            before: '144750.00',
            after: '94750.00',
          ),
          tx(
            id: '2',
            type: 'revenue',
            amount: '72375.00',
            before: '72375.00',
            after: '144750.00',
            referenceType: 'order',
            referenceId: '208',
          ),
          tx(
            id: '1',
            type: 'revenue',
            amount: '72375.00',
            before: '0.00',
            after: '72375.00',
            referenceType: 'order',
            referenceId: '207',
          ),
        ],
      });

      // The withdrawal is excluded; only the two revenue rows count.
      expect(wallet.totalEarned, 144750);
      expect(wallet.transactions, hasLength(3));
    });
  });

  group('WalletTransaction direction', () {
    // The server stores every amount as abs() and leaves the direction to
    // `type`, so a ledger that renders `amount` raw shows a withdrawal as if
    // money came in. Direction is recovered from the balance either side.
    test('a withdrawal is a debit even though its amount is positive', () {
      final transaction = WalletTransaction.fromJson(tx(
        id: '3',
        type: 'withdraw',
        amount: '50000.00',
        before: '144750.00',
        after: '94750.00',
      ));

      expect(transaction.amount, 50000, reason: 'stored positive');
      expect(transaction.isCredit, isFalse);
      expect(transaction.signedAmount, -50000);
    });

    test('revenue is a credit and points back at its order', () {
      final transaction = WalletTransaction.fromJson(tx(
        id: '2',
        type: 'revenue',
        amount: '72375.00',
        before: '72375.00',
        after: '144750.00',
        referenceType: 'order',
        referenceId: '208',
      ));

      expect(transaction.isCredit, isTrue);
      expect(transaction.signedAmount, 72375);
      expect(transaction.isOrderRevenue, isTrue);
      expect(transaction.referenceId, 208);
    });

    test('an unknown transaction type still reads the right direction', () {
      // Direction comes from the balance columns, not from a type whitelist,
      // so a type added to the backend later is not silently mis-rendered.
      final transaction = WalletTransaction.fromJson(tx(
        id: '9',
        type: 'some_future_type',
        amount: '1000.00',
        before: '5000.00',
        after: '4000.00',
      ));

      expect(transaction.isCredit, isFalse);
      expect(transaction.signedAmount, -1000);
      expect(transaction.isOrderRevenue, isFalse);
    });
  });
}
