import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/catalog/product_variant.dart';
import 'package:navy_wear/core/domain/model/shipping/courier.dart';

/// Payloads captured from the running marketplace API.
void main() {
  group('Courier.fromJson', () {
    test('reads a row of the platform master list', () {
      // GET /couriers
      final courier = Courier.fromJson(<String, dynamic>{
        'code': 'jne',
        'name': 'JNE',
        'is_active': '1',
      });

      expect(courier.code, 'jne');
      expect(courier.name, 'JNE');
      expect(courier.isActive, isTrue);
    });

    test('a store row has no is_active and is active by definition', () {
      // GET /stores/{id}/couriers returns only code and name — a courier listed
      // for a store is one it has enabled.
      final courier = Courier.fromJson(<String, dynamic>{
        'code': 'jnt',
        'name': 'J&T Express',
      });

      expect(courier.code, 'jnt');
      expect(courier.isActive, isTrue);
    });

    test('an inactive platform courier reads as inactive', () {
      final courier = Courier.fromJson(<String, dynamic>{
        'code': 'lama',
        'name': 'Kurir Lama',
        'is_active': '0',
      });

      expect(courier.isActive, isFalse);
    });
  });

  group('ProductVariant origin', () {
    test('reads the warehouse the variant would ship from', () {
      // Added to GET /products/{id} on 2026-09-15: the warehouse holding the
      // most of this variant, not a sum across warehouses.
      final variant = ProductVariant.fromJson(<String, dynamic>{
        'id': '1',
        'sku': 'KOPI-GAYO-250',
        'price': '75000.00',
        'stock': 42,
        'warehouse_city': 'Banda Aceh',
        'warehouse_province': 'Aceh',
      });

      expect(variant.warehouseCity, 'Banda Aceh');
      expect(variant.originLabel, 'Banda Aceh, Aceh');
    });

    test('no origin when nothing is in stock anywhere', () {
      final variant = ProductVariant.fromJson(<String, dynamic>{
        'id': '2',
        'sku': 'KOSONG',
        'price': '1000.00',
        'stock': 0,
        'warehouse_city': null,
        'warehouse_province': null,
      });

      expect(variant.warehouseCity, isNull);
      expect(variant.originLabel, isEmpty);
    });
  });
}
