import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:navy_wear/config/route/app_route_seller.dart';
import 'package:navy_wear/core/data/local/session_store.dart';
import 'package:navy_wear/core/utils/app_routes.dart';
import 'package:navy_wear/core/utils/local_network.dart';
import 'package:navy_wear/di/injector.dart';
import 'package:navy_wear/features/seller_catalog/presentation/views/widgets/product_card.dart';
import 'package:navy_wear/features/seller_orders/presentation/views/widgets/order_status_pill.dart';
import 'package:navy_wear/main.dart';

/// Drives the real app against the **running** marketplace API.
///
/// This is not a unit test: it boots the same widget tree `main()` does, talks
/// to `http://localhost:8000/api/v1` for real, and signs in as a seed seller.
/// It therefore needs the backend up and seeded — see
/// `docs/18-frontend-integration-guide.md` §3 for the accounts it uses.
///
///     flutter test integration_test -d macos
///
/// `DevicePreview` is skipped here on purpose: it wraps the app in a simulated
/// device frame that makes hit-testing depend on the preview's scaling.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String seedEmail = 'budi.santoso@kedaikopi.id';
  const String seedPassword = 'RahasiaAman123';

  /// Boots the app the way `main()` does, minus the preview frame, from a
  /// signed-out state so the run always starts at the login screen.
  Future<void> bootSignedOut(WidgetTester tester) async {
    await CachedHelper.init();
    await initialize(onSessionExpired: () => router.go(SellerRoutes.login));
    await injector<SessionStore>().clear();

    router.go(SellerRoutes.login);
    await tester.pumpWidget(Phoenix(child: const MyApp()));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// The app talks to a real server, so a fixed `pumpAndSettle` is not enough —
  /// this pumps until [finder] appears or the budget runs out.
  ///
  /// It then keeps pumping briefly: every route here is wrapped in a
  /// fade-through transition, and a widget that merely *exists* can still be
  /// mid-animation, where it will not accept a tap.
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) {
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 250));
        }
        return;
      }
    }
    fail('Timed out waiting for: ${finder.describeMatch(Plurality.zero)}');
  }

  /// `customAppBar` rolls its own back button out of a GestureDetector, so
  /// `pageBack()` — which looks for a Material or Cupertino one — finds nothing.
  Future<void> back(WidgetTester tester) async {
    await tester.tap(
      find
          .ancestor(
            of: find.byIcon(Icons.arrow_back_ios_new_outlined),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
  }

  testWidgets('a seller signs in and works through the catalogue',
      (tester) async {
    await bootSignedOut(tester);

    // ---------------------------------------------------------------- login
    expect(find.text('Masuk sebagai Toko'), findsOneWidget,
        reason: 'the app should start at the seller login screen');

    final fields = find.byType(TextFormField);
    expect(fields, findsAtLeastNWidgets(2));
    await tester.enterText(fields.at(0), seedEmail);
    await tester.enterText(fields.at(1), seedPassword);
    await tester.pump();

    await tester.tap(find.text('Masuk'));
    await pumpUntil(tester, find.text('Beranda'));

    // The dashboard names the store the session landed on, which is the proof
    // that login -> GET /me -> GET /stores all came back.
    expect(find.text('Kedai Kopi Nusantara'), findsOneWidget);

    // ------------------------------------------------------------ catalogue
    await tester.tap(find.text('Produk'));
    await pumpUntil(tester, find.byType(ProductCard));

    expect(find.byType(ProductCard), findsWidgets,
        reason: 'GET /stores/{id}/products should have produced rows');

    // Paging regression guard. The endpoint sends no `meta` but still caps each
    // response at 20 rows, so a catalogue read in one request is silently
    // truncated — this store's seed products sit past that cut. Scrolling to
    // one of them proves every page was fetched, not just the first.
    await tester.scrollUntilVisible(
      find.text('Kopi Arabika Gayo 250g'),
      300,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 200,
    );
    expect(find.text('Kopi Arabika Gayo 250g'), findsOneWidget);

    // The status filter is client-side, because the endpoint takes no status
    // parameter — the chips are the whole mechanism.
    expect(find.text('Semua'), findsOneWidget, reason: 'status filter chips');
    expect(find.text('Draf'), findsWidgets);

    // ----------------------------------------------------- open one product
    await tester.tap(find.byType(ProductCard).first);
    await pumpUntil(tester, find.text('Ubah produk'));

    // The edit form is fed by GET /products/{id}, so its presence proves the
    // detail payload parsed — variants, images, stock and all.
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Varian'), findsOneWidget);
    expect(find.textContaining('Stok tersedia'), findsOneWidget);

    // Category and type are read-only when editing: the API's PATCH accepts
    // neither, so the form must not offer them.
    expect(find.text('Kategori & jenis'), findsOneWidget);
    expect(find.text('Kategori'), findsNothing);

    // --------------------------------------------------- back, then create
    await back(tester);
    await pumpUntil(tester, find.text('Produk'));

    await tester.tap(find.byType(FloatingActionButton));
    await pumpUntil(tester, find.text('Produk baru'));

    // Creating needs the live category tree, which is what the dropdown holds.
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Jenis produk'), findsOneWidget);
    expect(find.text('Harga coret (opsional)'), findsOneWidget);

    // ------------------------------------------------------------- orders
    await back(tester);
    await pumpUntil(tester, find.byType(ProductCard));
    await back(tester);
    await pumpUntil(tester, find.text('Beranda'));

    await tester.tap(find.text('Pesanan'));
    await pumpUntil(tester, find.text('Perlu tindakan'));

    // Every seeded order is `pending`, so the default "needs action" filter is
    // legitimately empty — and that has to read as "nothing to do" rather than
    // as a failure.
    expect(find.textContaining('Tidak ada pesanan yang menunggu tindakan'),
        findsOneWidget);

    await tester.tap(find.text('Belum dibayar'));
    await pumpUntil(tester, find.byType(OrderStatusPill));

    // Opening one proves GET /orders/{id} parsed — items, totals, history.
    await tester.tap(find.byType(OrderStatusPill).first);
    await pumpUntil(tester, find.text('Detail pesanan'));
    expect(find.text('Barang'), findsOneWidget);
    expect(find.text('Pengiriman'), findsOneWidget);
    expect(find.textContaining('Pembeli belum membayar'), findsOneWidget);

    // A pending order offers cancellation and nothing else. The transition
    // buttons must stay hidden: the server answers an out-of-turn action with
    // an HTML exception page at HTTP 200, which cannot be reported usefully.
    expect(find.text('Batalkan'), findsOneWidget);
    expect(find.text('Terima pesanan'), findsNothing);
    expect(find.text('Tandai sudah dikemas'), findsNothing);
    expect(find.text('Serahkan ke kurir'), findsNothing);
  }, timeout: const Timeout(Duration(minutes: 4)));
}
