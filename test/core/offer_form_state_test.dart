import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/catalog/category.dart';
import 'package:navy_wear/core/domain/model/catalog/sku_master.dart';
import 'package:navy_wear/features/seller_catalog/presentation/cubits/offer_form_cubit/offer_form_cubit.dart';

/// The category's `jalur` is the only thing deciding whether a product needs a
/// platform SKU — and the server enforces none of it. Verified live: it
/// accepted a freeform offer in a MASTER category, a master offer in a BEBAS
/// one, and a duplicate of an offer the store already had. Since no endpoint
/// deletes an offer, these getters are the last line of defence.
void main() {
  const master = Category(id: 1, name: 'Semen', jalur: CategoryJalur.master);
  const bebas = Category(id: 11, name: 'Perkakas', jalur: CategoryJalur.bebas);

  group('OfferFormReady', () {
    test('a MASTER category demands a SKU and forbids freeform', () {
      const state = OfferFormReady(
        categories: <Category>[master, bebas],
        category: master,
      );

      expect(state.needsSku, isTrue);
      expect(state.isFreeform, isFalse);
    });

    test('a BEBAS category lets the store describe the product itself', () {
      const state = OfferFormReady(
        categories: <Category>[master, bebas],
        category: bebas,
      );

      expect(state.needsSku, isFalse);
      expect(state.isFreeform, isTrue);
    });

    test('neither path is taken until a category is chosen', () {
      const state = OfferFormReady(categories: <Category>[master, bebas]);

      expect(state.needsSku, isFalse);
      expect(state.isFreeform, isFalse);
    });

    test('an unknown jalur is treated as neither, not as freeform', () {
      // A new jalur added server-side must not silently unlock the freeform
      // path, which would let a store invent products in a curated category.
      const state = OfferFormReady(
        categories: <Category>[],
        category: Category(id: 9, name: 'Baru', jalur: 'SOMETHING_NEW'),
      );

      expect(state.needsSku, isFalse);
      expect(state.isFreeform, isFalse);
    });

    test('clearSku wins over an omitted sku argument', () {
      const sku = SkuMaster(id: 3, name: 'Semen Padang 50 kg');
      const state = OfferFormReady(
        categories: <Category>[master],
        category: master,
        sku: sku,
      );

      expect(state.copyWith().sku, sku);
      expect(state.copyWith(clearSku: true).sku, isNull);
    });
  });
}
