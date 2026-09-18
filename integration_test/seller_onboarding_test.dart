import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:navy_wear/config/route/app_route_seller.dart';
import 'package:navy_wear/core/data/local/session_store.dart';
import 'package:navy_wear/core/utils/app_routes.dart';
import 'package:navy_wear/core/utils/local_network.dart';
import 'package:navy_wear/di/injector.dart';
import 'package:navy_wear/main.dart';

/// Drives verification and warehouse/stock against the **running** backend.
///
/// Registers a throwaway account each run and opens a fresh store, because both
/// flows are one-way: a store can only be verified once, and stock movements
/// cannot be deleted. Reusing a seeded store would leave permanent residue.
///
///     flutter test integration_test -d macos
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) {
        // Routes fade in; a widget that exists can still refuse a tap.
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 250));
        }
        return;
      }
    }
    fail('Timed out waiting for: ${finder.describeMatch(Plurality.zero)}');
  }

  /// The dashboard grows a row per domain as they land, so a target that used
  /// to be on screen drifts below the fold — where a tap hits nothing.
  Future<void> tapText(WidgetTester tester, String text) async {
    final target = find.text(text).first;
    await tester.ensureVisible(target);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(target);
  }

  /// These forms are taller than the window, so the submit button usually sits
  /// below the fold — where a tap silently lands on nothing.
  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.widgetWithText(FilledButton, label).first;
    await tester.ensureVisible(button);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(button);
  }

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

  testWidgets('a new store submits verification and stocks a warehouse',
      (tester) async {
    final stamp = DateTime.now().millisecondsSinceEpoch.toString();
    final email = 'e2e$stamp@probe.test';

    await CachedHelper.init();
    await initialize(onSessionExpired: () => router.go(SellerRoutes.login));
    await injector<SessionStore>().clear();

    router.go(SellerRoutes.register);
    await tester.pumpWidget(Phoenix(child: const MyApp()));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ------------------------------------------------------------- register
    final fields = find.byType(TextFormField);
    expect(fields, findsAtLeastNWidgets(4),
        reason: 'name, email, phone and password');
    await tester.enterText(fields.at(0), 'E2E Probe');
    await tester.enterText(fields.at(1), email);
    await tester.enterText(fields.at(2), '0819${stamp.substring(stamp.length - 6)}');
    await tester.enterText(fields.at(3), 'Password123');
    await tester.pump();

    await tapButton(tester, 'Daftar');
    // Registration chains register -> verify -> login, then the bootstrap sends
    // an account with no store to the picker rather than straight home.
    await pumpUntil(tester, find.text('Pilih toko'));
    expect(find.textContaining('belum punya toko'), findsOneWidget);

    // ---------------------------------------------------------- open a store
    await tester.tap(find.byType(FloatingActionButton));
    await pumpUntil(tester, find.text('Toko baru'));

    final storeFields = find.byType(TextFormField);
    await tester.enterText(storeFields.at(0), 'Toko E2E $stamp');
    await tester.pump();
    await tapButton(tester, 'Buka toko');
    await pumpUntil(tester, find.text('Beranda'));

    // A store opens inactive, and the dashboard says so.
    expect(find.text('Belum aktif'), findsOneWidget);

    // ---------------------------------------------------------- verification
    await tapText(tester, 'Verifikasi toko');
    await pumpUntil(tester, find.text('Ajukan verifikasi'));

    final vFields = find.byType(TextFormField);
    await tester.enterText(vFields.at(0), '3171234567890001'); // KTP
    await tester.enterText(vFields.at(2), 'BCA'); // bank
    await tester.enterText(vFields.at(3), 'E2E Probe'); // account holder
    await tester.enterText(vFields.at(4), '1234567890'); // account number
    await tester.pump();

    await tapButton(tester, 'Kirim pengajuan');
    // Submitting flips the screen to the status view, which is also the only
    // place documents can be attached — the endpoint rejects uploads before a
    // request exists.
    await pumpUntil(tester, find.text('Menunggu ditinjau'));
    expect(find.text('Dokumen'), findsOneWidget);
    expect(find.textContaining('Masih kurang'), findsOneWidget);

    await back(tester);
    await pumpUntil(tester, find.text('Beranda'));

    // ------------------------------------------------------------- warehouse
    await tapText(tester, 'Gudang & stok');
    await pumpUntil(tester, find.textContaining('Belum ada gudang'));

    await tapButton(tester, 'Buat gudang pertama');
    await pumpUntil(tester, find.text('Gudang baru'));

    final wFields = find.byType(TextFormField);
    await tester.enterText(wFields.at(0), 'Gudang E2E');
    await tester.enterText(wFields.at(1), 'Jl. Percobaan 1');
    await tester.enterText(wFields.at(2), 'Jakarta Timur');
    await tester.enterText(wFields.at(3), 'DKI Jakarta');
    await tester.enterText(wFields.at(4), '13920');
    await tester.pump();

    await tapButton(tester, 'Tambah gudang');
    // Waiting on the default pill rather than the name: the name is still in
    // the sheet's own text field until the sheet closes, so `find.text` would
    // match it a beat too early.
    await pumpUntil(tester, find.text('Utama'));

    // The server marks the first warehouse as the store's default, whatever the
    // client asked for — and the list has to show that rather than guess.
    expect(find.text('Gudang E2E'), findsOneWidget);

    // ----------------------------------------------------------- empty stock
    await tapText(tester, 'Stok');
    await pumpUntil(tester, find.textContaining('Belum ada stok'));
    expect(find.text('Stok masuk'), findsWidgets);

    await back(tester);
    await pumpUntil(tester, find.text('Gudang E2E'));
    await back(tester);
    await pumpUntil(tester, find.text('Beranda'));

    // --------------------------------------------------------------- couriers
    await tapText(tester, 'Kurir pengiriman');
    await pumpUntil(tester, find.text('JNE'));

    // A new store has no restriction, which the backend treats as "every
    // courier" rather than "none". The screen has to say which way round that
    // is, because the opposite reading is the natural one.
    expect(find.textContaining('Belum ada batasan kurir'), findsOneWidget);

    await tester.tap(find.text('JNE'));
    await tester.pump(const Duration(milliseconds: 300));
    await tapButton(tester, 'Simpan pilihan');
    await pumpUntil(tester, find.text('Pilihan kurir tersimpan.'));

    // Once a restriction exists the notice goes, and the copy switches to
    // explaining that buyers now only see what is ticked.
    expect(find.textContaining('Belum ada batasan kurir'), findsNothing);
    expect(find.textContaining('hanya bisa memilih kurir'), findsOneWidget);
  }, timeout: const Timeout(Duration(minutes: 5)));
}
