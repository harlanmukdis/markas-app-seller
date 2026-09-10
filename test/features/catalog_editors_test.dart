import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/catalog/offer.dart';
import 'package:navy_wear/core/utils/local_network.dart';
import 'package:navy_wear/features/seller_catalog/presentation/views/widgets/photo_editor.dart';
import 'package:navy_wear/features/seller_catalog/presentation/views/widgets/price_tier_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Both editors exist to stop a store from finding out about a rule through a
/// 422, or worse, through a listing that never goes live and never says why.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await CachedHelper.init();
  });

  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  group('PriceTierEditor', () {
    testWidgets('demands a RETAIL tier and names the error it prevents',
        (tester) async {
      await pump(
        tester,
        PriceTierEditor(tiers: const <PriceTier>[], onChanged: (_) {}),
      );

      expect(find.textContaining('MISSING_RETAIL_TIER'), findsOneWidget);
    });

    testWidgets('a PROJECT-only list still counts as missing RETAIL',
        (tester) async {
      // The trap: the store sets a wholesale price, sees tiers on screen, and
      // assumes it is done. Retail buyers would see no price at all.
      await pump(
        tester,
        PriceTierEditor(
          tiers: const <PriceTier>[
            PriceTier(segment: PriceSegment.project, minQty: 10, price: 78000),
          ],
          onChanged: (_) {},
        ),
      );

      expect(find.textContaining('MISSING_RETAIL_TIER'), findsOneWidget);
    });

    testWidgets('says the save replaces the whole list once RETAIL is there',
        (tester) async {
      await pump(
        tester,
        PriceTierEditor(
          tiers: const <PriceTier>[
            PriceTier(segment: PriceSegment.retail, minQty: 1, price: 85000),
          ],
          onChanged: (_) {},
        ),
      );

      expect(find.textContaining('mengganti SELURUH'), findsOneWidget);
      expect(find.textContaining('MISSING_RETAIL_TIER'), findsNothing);
    });

    testWidgets('removing a tier hands back the list without it',
        (tester) async {
      List<PriceTier>? emitted;
      await pump(
        tester,
        PriceTierEditor(
          tiers: const <PriceTier>[
            PriceTier(segment: PriceSegment.retail, minQty: 1, price: 85000),
            PriceTier(segment: PriceSegment.retail, minQty: 50, price: 80000),
          ],
          onChanged: (tiers) => emitted = tiers,
        ),
      );

      await tester.tap(find.byTooltip('Hapus').first);
      await tester.pump();

      expect(emitted, isNotNull);
      expect(emitted!.single.price, 80000);
    });
  });

  group('PhotoEditor', () {
    testWidgets('counts how many photos are still missing', (tester) async {
      await pump(
        tester,
        PhotoEditor(
          photos: const <OfferPhoto>[
            OfferPhoto(url: 'https://x/1.jpg', width: 900, height: 900),
          ],
          onChanged: (_) {},
        ),
      );

      expect(find.textContaining('Kurang 2 foto lagi'), findsOneWidget);
    });

    testWidgets('flags an undersized photo even when the count is met',
        (tester) async {
      // 800×800 is the gate. A 640px photo passes every visual check the store
      // can make and still blocks activation with nothing to point at.
      await pump(
        tester,
        PhotoEditor(
          photos: const <OfferPhoto>[
            OfferPhoto(url: 'https://x/1.jpg', width: 900, height: 900),
            OfferPhoto(url: 'https://x/2.jpg', width: 900, height: 900),
            OfferPhoto(url: 'https://x/3.jpg', width: 640, height: 640),
          ],
          onChanged: (_) {},
        ),
      );

      expect(find.textContaining('1 foto di bawah 800×800'), findsOneWidget);
    });

    testWidgets('confirms plainly once the gate is satisfied', (tester) async {
      await pump(
        tester,
        PhotoEditor(
          photos: const <OfferPhoto>[
            OfferPhoto(url: 'https://x/1.jpg', width: 900, height: 900),
            OfferPhoto(url: 'https://x/2.jpg', width: 1200, height: 900),
            OfferPhoto(url: 'https://x/3.jpg', width: 800, height: 800),
          ],
          onChanged: (_) {},
        ),
      );

      expect(
        find.text('3 foto, semuanya memenuhi syarat.'),
        findsOneWidget,
      );
    });
  });
}
