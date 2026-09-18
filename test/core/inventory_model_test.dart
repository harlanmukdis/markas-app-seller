import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/inventory/stock_movement.dart';
import 'package:navy_wear/core/domain/model/inventory/warehouse.dart';
import 'package:navy_wear/core/domain/model/inventory/warehouse_stock.dart';
import 'package:navy_wear/core/domain/model/verification/store_verification.dart';

/// Payloads captured from the running marketplace API.
void main() {
  group('Warehouse.fromJson', () {
    test('reads a row, flags included', () {
      final warehouse = Warehouse.fromJson(<String, dynamic>{
        'id': '10',
        'store_id': '10',
        'name': 'Gudang Satu',
        'address': 'Jl. Satu',
        'city': 'Jakarta Timur',
        'province': 'DKI Jakarta',
        'postal_code': '13920',
        'latitude': null,
        'longitude': null,
        'is_default': '1',
        'status': 'active',
        'created_at': '2026-09-15 07:53:15',
      });

      expect(warehouse.id, 10);
      expect(warehouse.isDefault, isTrue);
      expect(warehouse.isActive, isTrue);
      expect(warehouse.shortAddress, 'Jakarta Timur, DKI Jakarta');
    });

    test('an inactive warehouse reads as inactive', () {
      final warehouse = Warehouse.fromJson(<String, dynamic>{
        'id': '11',
        'name': 'Gudang Dua',
        'is_default': '0',
        'status': 'inactive',
      });

      expect(warehouse.isDefault, isFalse);
      expect(warehouse.isActive, isFalse);
      // No city or province in this payload — the label must not invent commas.
      expect(warehouse.shortAddress, isEmpty);
    });
  });

  group('WarehouseStock.fromJson', () {
    test('reads the joined stock row', () {
      final stock = WarehouseStock.fromJson(<String, dynamic>{
        'id': '31',
        'warehouse_id': '10',
        'product_variant_id': '69',
        'quantity_on_hand': '43',
        'quantity_reserved': '0',
        'quantity_available': '43',
        'reorder_point': '0',
        'updated_at': '2026-09-15 07:53:15',
        'sku': 'SKU-61-BCDD58',
        'variant_options': null,
        'product_name': 'Barang Inv',
      });

      expect(stock.productVariantId, 69);
      expect(stock.quantityOnHand, 43);
      expect(stock.quantityAvailable, 43);
      expect(stock.productName, 'Barang Inv');
      expect(stock.optionsLabel, isEmpty);
      // reorder_point is 0 until someone sets one; that must not read as "low".
      expect(stock.isLow, isFalse);
      expect(stock.isOutOfStock, isFalse);
    });

    test('decodes variant_options and flags a low row', () {
      final stock = WarehouseStock.fromJson(<String, dynamic>{
        'id': '32',
        'product_variant_id': '70',
        'quantity_on_hand': '5',
        'quantity_reserved': '2',
        'quantity_available': '3',
        'reorder_point': '5',
        'variant_options': '{"warna":"merah","ukuran":"L"}',
      });

      expect(stock.optionsLabel, 'merah · L');
      expect(stock.isLow, isTrue);
      expect(stock.isOutOfStock, isFalse);
    });

    test('nothing available reads as out of stock', () {
      final stock = WarehouseStock.fromJson(<String, dynamic>{
        'id': '33',
        'product_variant_id': '71',
        'quantity_on_hand': '4',
        'quantity_reserved': '4',
        'quantity_available': '0',
      });

      expect(stock.isOutOfStock, isTrue);
      // Everything on hand is spoken for by checkout — which is why a stock-out
      // of 4 would be refused despite "4 on hand".
      expect(stock.quantityReserved, 4);
    });
  });

  group('StockMovement.fromJson', () {
    test('keeps the sign the ledger stores', () {
      final out = StockMovement.fromJson(<String, dynamic>{
        'id': '6',
        'warehouse_id': '10',
        'product_variant_id': '69',
        'type': 'stock_out',
        'quantity': '-5',
        'notes': 'rusak',
        'created_by': '94',
        'created_at': '2026-09-15 07:53:15',
      });

      expect(out.quantity, -5);
      expect(out.isIncoming, isFalse);
      expect(out.signedQuantity, '-5');
      expect(StockMovementType.label(out.type), 'Stok keluar');
    });

    test('an incoming movement is positive', () {
      final into = StockMovement.fromJson(<String, dynamic>{
        'id': '5',
        'type': 'stock_in',
        'quantity': '50',
        'notes': 'awal',
      });

      expect(into.isIncoming, isTrue);
      expect(into.signedQuantity, '+50');
    });
  });

  group('StoreVerification.fromJson', () {
    Map<String, dynamic> payload({
      String status = 'submitted',
      String type = 'individual',
      List<dynamic> documents = const <dynamic>[],
    }) =>
        <String, dynamic>{
          'id': '1',
          'store_id': '10',
          'type': type,
          'id_card_number': '3171234567890001',
          'tax_number': '01.234.567.8-901.000',
          'business_doc_url': null,
          'bank_account_name': 'Inv Probe',
          'bank_account_number': '1234567890',
          'bank_name': 'BCA',
          'status': status,
          'reviewed_by': null,
          'rejection_reason': null,
          'submitted_at': '2026-09-15 07:53:15',
          'reviewed_at': null,
          'created_at': '2026-09-15 07:53:15',
          'documents': documents,
          'history': <dynamic>[
            <String, dynamic>{
              'id': '1',
              'verification_id': '1',
              'actor_user_id': '94',
              'from_status': null,
              'to_status': 'submitted',
              'notes': null,
              'created_at': '2026-09-15 07:53:15',
            },
          ],
        };

    test('reads a submitted request with its history', () {
      final verification = StoreVerification.fromJson(payload());

      expect(verification.id, 1);
      expect(verification.isPending, isTrue);
      expect(verification.isApproved, isFalse);
      expect(verification.history.single.fromStatus, isNull);
      expect(verification.history.single.toStatus, 'submitted');
    });

    test('an individual request needs KTP and a selfie', () {
      final verification = StoreVerification.fromJson(payload(
        documents: <dynamic>[
          <String, dynamic>{
            'id': '1',
            'doc_type': 'ktp',
            'file_url': 'http://localhost:8080/marketplace-api/uploads/a.png',
            'uploaded_at': '2026-09-15 07:53:15',
          },
        ],
      ));

      expect(verification.documents.single.docType, 'ktp');
      expect(verification.missingDocuments, <String>['selfie']);
    });

    test('a business request asks for the company papers too', () {
      final verification = StoreVerification.fromJson(payload(type: 'business'));

      expect(
        verification.missingDocuments,
        <String>['ktp', 'npwp', 'siup', 'nib', 'selfie'],
      );
    });

    test('a document URL is rewritten off the host that serves nothing', () {
      final verification = StoreVerification.fromJson(payload(
        documents: <dynamic>[
          <String, dynamic>{
            'id': '1',
            'doc_type': 'ktp',
            'file_url':
                'http://localhost:8080/marketplace-api/uploads/verification/2026/09/a.png',
          },
        ],
      ));

      // The upload endpoint builds URLs from its own configured base_url, which
      // points at a port nothing listens on.
      expect(verification.documents.single.fileUrl, contains('/uploads/'));
      expect(verification.documents.single.fileUrl, isNot(contains(':8080')));
    });

    test('a rejected request carries the reason and can be resubmitted', () {
      final json = payload(status: 'rejected')
        ..['rejection_reason'] = 'Foto KTP buram';
      final verification = StoreVerification.fromJson(json);

      expect(verification.isRejected, isTrue);
      expect(verification.isPending, isFalse);
      expect(verification.rejectionReason, 'Foto KTP buram');
    });
  });
}
