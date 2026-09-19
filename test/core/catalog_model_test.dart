import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/catalog/category.dart';
import 'package:navy_wear/core/domain/model/catalog/flash_sale_info.dart';
import 'package:navy_wear/core/domain/model/catalog/product.dart';
import 'package:navy_wear/core/domain/model/catalog/product_variant.dart';

/// Payloads here are captured from the running marketplace API, not invented.
void main() {
  group('Category.fromJson', () {
    test('reads a node and its children out of the tree', () {
      final category = Category.fromJson(<String, dynamic>{
        'id': '1',
        'parent_id': null,
        'name': 'Elektronik & Gadget',
        'slug': 'elektronik-gadget',
        'icon_url': null,
        'level': '0',
        'sort_order': '1',
        'is_active': '1',
        'children': <dynamic>[
          <String, dynamic>{
            'id': '13',
            'parent_id': '1',
            'name': 'Laptop & Komputer',
            'level': '1',
            'is_active': '1',
            'children': <dynamic>[],
          },
        ],
      });

      expect(category.id, 1);
      expect(category.parentId, isNull);
      expect(category.isActive, isTrue);
      expect(category.hasChildren, isTrue);
      expect(category.children.single.id, 13);
      expect(category.children.single.parentId, 1);
    });

    test('flattenCategories labels children with their parent', () {
      final tree = <Category>[
        const Category(
          id: 2,
          name: 'Fashion Pria',
          children: <Category>[
            Category(id: 21, name: 'Sepatu Pria', parentId: 2, level: 1),
          ],
        ),
        const Category(
          id: 3,
          name: 'Fashion Wanita',
          children: <Category>[
            Category(id: 28, name: 'Sepatu Wanita', parentId: 3, level: 1),
          ],
        ),
      ];

      final options = flattenCategories(tree);

      expect(options.map((option) => option.id), <int>[2, 21, 3, 28]);
      // Both trees have a "Sepatu" leaf; the parent is what tells them apart.
      expect(options[1].label, 'Fashion Pria › Sepatu Pria');
      expect(options[3].label, 'Fashion Wanita › Sepatu Wanita');
      // A parent is offered too — the API accepts a level-0 category_id.
      expect(options.first.label, 'Fashion Pria');
    });

    test('skips an inactive category', () {
      final options = flattenCategories(<Category>[
        const Category(id: 9, name: 'Tersembunyi', isActive: false),
        const Category(id: 10, name: 'Terlihat'),
      ]);

      expect(options.map((option) => option.id), <int>[10]);
    });
  });

  group('ProductVariant.fromJson', () {
    test('decodes variant_options, which arrives as a JSON string', () {
      final variant = ProductVariant.fromJson(<String, dynamic>{
        'id': '30',
        'product_id': '22',
        'sku': 'PROBE-RED-L',
        'variant_options': '{"color":"red","size":"L"}',
        'price': '169000.00',
        'weight_grams': '300',
        'image_url': null,
        'is_active': '1',
      });

      expect(variant.id, 30);
      expect(variant.options['color'], 'red');
      expect(variant.options['size'], 'L');
      expect(variant.optionsLabel, 'red · L');
      // Money arrives as a two-decimal string but the platform has no cents.
      expect(variant.price, 169000);
      expect(variant.isGenerated, isFalse);
    });

    test('recognises the default variant the server generates on create', () {
      final variant = ProductVariant.fromJson(<String, dynamic>{
        'id': '29',
        'product_id': '22',
        'sku': 'SKU-22-E7485D',
        'variant_options': null,
        'price': '149000.00',
        'weight_grams': null,
        'is_active': '1',
      });

      expect(variant.isGenerated, isTrue);
      expect(variant.options, isEmpty);
      expect(variant.optionsLabel, isEmpty);
      expect(variant.weightGrams, isNull);
    });

    test('reads stock, which is an integer while its neighbours are strings',
        () {
      final variant = ProductVariant.fromJson(<String, dynamic>{
        'id': '1',
        'sku': 'KOPI-GAYO-250',
        'price': '75000.00',
        'stock': 150,
      });

      expect(variant.stock, 150);
    });
  });

  group('Product.fromJson', () {
    test('reads a row from the seller list, which carries no nested data', () {
      final product = Product.fromJson(<String, dynamic>{
        'id': '22',
        'store_id': '11',
        'name': 'Produk Probe',
        'slug': 'produk-probe-91083c',
        'product_type': 'physical',
        'description': 'probe',
        'base_price': '149000.00',
        'compare_at_price': null,
        'weight_grams': '300',
        'status': 'draft',
        'sold_count': '0',
        'rating_avg': '0.00',
        'rating_count': '0',
        'created_at': '2026-09-14 20:27:36',
        'deleted_at': null,
      });

      expect(product.id, 22);
      expect(product.basePrice, 149000);
      expect(product.isDraft, isTrue);
      expect(product.isActive, isFalse);
      expect(product.variants, isEmpty);
      // Absent from this payload — not the same as "no stock".
      expect(product.stock, isNull);
      expect(product.createdAt, DateTime(2026, 9, 14, 20, 27, 36));
    });

    test('reads the detail payload with variants, images and stock', () {
      final product = Product.fromJson(<String, dynamic>{
        'id': '1',
        'store_id': '1',
        'name': 'Kopi Arabika Gayo 250g',
        'base_price': '75000.00',
        'compare_at_price': null,
        'status': 'active',
        'stock': 150,
        'variants': <dynamic>[
          <String, dynamic>{
            'id': '1',
            'sku': 'KOPI-GAYO-250',
            'price': '75000.00',
            'variant_options': null,
            'stock': 150,
          },
        ],
        'images': <dynamic>[
          <String, dynamic>{
            'id': '1',
            'image_url': 'https://cdn.example/kopi.jpg',
            'sort_order': '0',
          },
        ],
      });

      expect(product.stock, 150);
      expect(product.isActive, isTrue);
      expect(product.variants.single.stock, 150);
      expect(product.images.single.imageUrl, 'https://cdn.example/kopi.jpg');
      // No sale running: the key is absent rather than null.
      expect(product.flashSale, isNull);
      expect(product.effectivePrice, 75000);
    });

    test('reads the flash_sale block when a sale is running', () {
      final product = Product.fromJson(<String, dynamic>{
        'id': '1',
        'name': 'Kopi',
        'base_price': '75000.00',
        'status': 'active',
        'flash_sale': <String, dynamic>{
          'flash_price': 59000,
          'sold_count': 12,
          'stock_quota': 100,
          'ends_at': '2026-09-20 23:59:59',
        },
      });

      expect(product.flashSale, isNotNull);
      expect(product.flashSale!.flashPrice, 59000);
      expect(product.flashSale!.remainingQuota, 88);
      // The sale price is what a buyer pays, so it wins over base_price.
      expect(product.effectivePrice, 59000);
    });

    test('per-variant flash_sale is always present, product-level is not', () {
      // v1.1.0 added variants[i].flash_sale. The two levels disagree on how
      // "no sale" looks: the product omits the key entirely, the variant keeps
      // it and sets null.
      final product = Product.fromJson(<String, dynamic>{
        'id': '5',
        'name': 'Kaos Multi Varian',
        'base_price': '100000.00',
        'status': 'active',
        'variants': <dynamic>[
          <String, dynamic>{
            'id': '11',
            'sku': 'KAOS-M',
            'price': '100000.00',
            'flash_sale': <String, dynamic>{
              'flash_price': 79000,
              'sold_count': 3,
              'stock_quota': 50,
              'ends_at': '2026-09-20 23:59:59',
            },
          },
          <String, dynamic>{
            'id': '12',
            'sku': 'KAOS-L',
            'price': '110000.00',
            'flash_sale': null,
          },
        ],
      });

      // No product-level key at all, even though one variant is discounted.
      expect(product.flashSale, isNull);

      final discounted = product.variants.first;
      final full = product.variants.last;
      expect(discounted.flashSale, isNotNull);
      expect(discounted.effectivePrice, 79000);
      expect(discounted.flashSale!.remainingQuota, 47);

      expect(full.flashSale, isNull);
      // Pricing this one off the product-level block would have discounted it.
      expect(full.effectivePrice, 110000);

      expect(product.hasPartialFlashSale, isTrue);
    });

    test('a sale covering every variant is not partial', () {
      final product = Product.fromJson(<String, dynamic>{
        'id': '6',
        'name': 'Semua Diskon',
        'base_price': '50000.00',
        'variants': <dynamic>[
          <String, dynamic>{
            'id': '21',
            'sku': 'A',
            'price': '50000.00',
            'flash_sale': <String, dynamic>{'flash_price': 40000},
          },
          <String, dynamic>{
            'id': '22',
            'sku': 'B',
            'price': '50000.00',
            'flash_sale': <String, dynamic>{'flash_price': 40000},
          },
        ],
      });

      expect(product.hasPartialFlashSale, isFalse);
    });

    test('FlashSaleInfo.maybeFrom treats a missing key and null alike', () {
      expect(FlashSaleInfo.maybeFrom(null), isNull);
      expect(FlashSaleInfo.maybeFrom(<String, dynamic>{}), isNull);
      expect(
        FlashSaleInfo.maybeFrom(<String, dynamic>{'flash_price': 1000})!
            .flashPrice,
        1000,
      );
    });

    test('authoredVariants hides the generated default', () {
      final product = Product.fromJson(<String, dynamic>{
        'id': '22',
        'name': 'Produk',
        'base_price': '149000.00',
        'variants': <dynamic>[
          <String, dynamic>{
            'id': '29',
            'sku': 'SKU-22-E7485D',
            'price': '149000.00',
            'variant_options': null,
          },
          <String, dynamic>{
            'id': '30',
            'sku': 'PROBE-RED-L',
            'price': '169000.00',
            'variant_options': '{"color":"red"}',
          },
        ],
      });

      expect(product.variants, hasLength(2));
      expect(product.authoredVariants, hasLength(1));
      expect(product.authoredVariants.single.sku, 'PROBE-RED-L');
    });
  });
}
