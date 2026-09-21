import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/merchandising/product_bundle.dart';
import 'package:navy_wear/core/domain/model/merchandising/store_showcase.dart';

/// Payloads captured from the running marketplace API.
void main() {
  group('ProductBundle.fromJson', () {
    // Verbatim from GET /bundles/{id}.
    Map<String, dynamic> detail({String price = '90000.00'}) =>
        <String, dynamic>{
          'id': '1',
          'store_id': '23',
          'name': 'Paket Hemat',
          'bundle_price': price,
          'status': 'active',
          'created_at': '2026-09-21 21:58:15',
          'items': <dynamic>[
            <String, dynamic>{
              'id': '1',
              'product_id': '21',
              'variant_id': '27',
              'quantity': '2',
              'product_name': 'Produk Aktif BS',
              'unit_price': '50000.00',
            },
            <String, dynamic>{
              'id': '2',
              'product_id': '22',
              'variant_id': null,
              'quantity': '1',
              'product_name': 'Produk Draf BS',
              'unit_price': '50000.00',
            },
          ],
        };

    test('reads a bundle and its items', () {
      final bundle = ProductBundle.fromJson(detail());

      expect(bundle.id, 1);
      expect(bundle.bundlePrice, 90000);
      expect(bundle.isActive, isTrue);
      expect(bundle.items, hasLength(2));
      expect(bundle.items.first.variantId, 27);
      expect(bundle.items.last.variantId, isNull,
          reason: 'a line may name the product alone');
    });

    test('works out what the parts would cost separately', () {
      final bundle = ProductBundle.fromJson(detail());

      // 50 000 × 2 + 50 000 × 1
      expect(bundle.itemsTotal, 150000);
      expect(bundle.savings, 60000);
      expect(bundle.discountPercent, 40);
    });

    test('a bundle dearer than its parts is not a discount', () {
      // The server checks only that the price is above zero, so this is a
      // real state — it must not render as a saving.
      final bundle = ProductBundle.fromJson(detail(price: '200000.00'));

      expect(bundle.savings, 0);
      expect(bundle.discountPercent, 0);
      expect(bundle.isNotADiscount, isTrue);
    });

    test('a list row carries no items, so it can claim no saving', () {
      // GET /stores/{id}/bundles does not join items — verbatim from it.
      final row = ProductBundle.fromJson(<String, dynamic>{
        'id': '2',
        'store_id': '23',
        'name': 'Paket Nonaktif',
        'bundle_price': '80000.00',
        'status': 'inactive',
        'created_at': '2026-09-21 21:58:15',
      });

      expect(row.items, isEmpty);
      expect(row.isActive, isFalse);
      expect(row.itemsTotal, 0);
      expect(row.savings, 0);
      expect(row.isNotADiscount, isFalse,
          reason: 'unknown is not the same as "no saving"');
    });
  });

  group('StoreShowcase and its products', () {
    test('reads a showcase row', () {
      final showcase = StoreShowcase.fromJson(<String, dynamic>{
        'id': '2',
        'store_id': '23',
        'name': 'Etalase Kopi',
        'sort_order': '1',
        'created_at': '2026-09-21 21:58:15',
      });

      expect(showcase.id, 2);
      expect(showcase.name, 'Etalase Kopi');
      expect(showcase.sortOrder, 1);
    });

    test('reads a product row from a showcase', () {
      // Verbatim from GET /showcases/{id}/products — a partial product, not
      // the full one: no status, no stock, no variants.
      final product = ShowcaseProduct.fromJson(<String, dynamic>{
        'id': '21',
        'name': 'Produk Aktif BS',
        'slug': 'produk-aktif-bs-cec29c',
        'base_price': '50000.00',
        'rating_avg': '0.00',
        'rating_count': '0',
        'image_url': null,
      });

      expect(product.id, 21, reason: 'the product id, not a membership id');
      expect(product.basePrice, 50000);
      expect(product.hasRating, isFalse);
      expect(product.imageUrl, isNull);
    });

    test('a rated product reports its rating', () {
      final product = ShowcaseProduct.fromJson(<String, dynamic>{
        'id': '1',
        'name': 'Kopi Arabika Gayo 250g',
        'base_price': '75000.00',
        'rating_avg': '4.80',
        'rating_count': '152',
        'image_url': 'https://picsum.photos/seed/kopi/600/600',
      });

      expect(product.hasRating, isTrue);
      expect(product.ratingAvg, closeTo(4.8, 0.001));
      expect(product.ratingCount, 152);
    });
  });
}
