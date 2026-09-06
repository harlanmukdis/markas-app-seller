import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/catalog/offer.dart';
import 'package:navy_wear/core/utils/local_network.dart';
import 'package:navy_wear/features/seller_catalog/presentation/views/widgets/seller_product_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The card is mostly padding, a decorated box and gaps between text lines.
/// With GestureDetector's default `deferToChild`, a tap that did not land
/// directly on a glyph did nothing — the grid looked interactive and wasn't.
void main() {
  setUp(() async {
    // The kit reads theme and language synchronously from prefs while building.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await CachedHelper.init();
  });

  const offer = Offer(
    id: 7,
    status: OfferStatus.active,
    minOrderQty: 5,
    priceTiers: <PriceTier>[
      PriceTier(segment: PriceSegment.retail, minQty: 1, price: 65000),
      PriceTier(segment: PriceSegment.retail, minQty: 200, price: 63000),
    ],
  );

  Future<void> pumpCard(WidgetTester tester, VoidCallback onTap) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 300,
              child: SellerProductItem(
                offer: offer,
                name: 'Semen Tiga Roda 40 kg',
                stock: 950,
                tiersLoaded: true,
                onTap: onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('a tap on empty space inside the card still opens it',
      (tester) async {
    var taps = 0;
    await pumpCard(tester, () => taps++);

    // Bottom-right: the text block is left-aligned, so this corner sits over
    // no child at all. Under the default `deferToChild` the tap is swallowed
    // and the card looks interactive without being it.
    final rect = tester.getRect(find.byType(SellerProductItem));
    await tester.tapAt(Offset(rect.right - 6, rect.bottom - 6));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('shows the lowest RETAIL price, not the first tier',
      (tester) async {
    await pumpCard(tester, () {});

    expect(find.text('Rp 63.000'), findsOneWidget);
    expect(find.text('Rp 65.000'), findsNothing);
  });

  testWidgets('says the price is loading rather than missing before tiers land',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 300,
            child: SellerProductItem(
              // No tiers yet, and the detail read has not finished.
              offer: const Offer(id: 7, status: OfferStatus.draft),
              name: 'Belum dimuat',
              tiersLoaded: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Harga …'), findsOneWidget);
    expect(find.text('Harga belum diatur'), findsNothing);
  });

  testWidgets('reports a missing price once every tier has been read',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 300,
            child: SellerProductItem(
              offer: const Offer(id: 7, status: OfferStatus.draft),
              name: 'Tanpa harga',
              tiersLoaded: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Harga belum diatur'), findsOneWidget);
  });
}
