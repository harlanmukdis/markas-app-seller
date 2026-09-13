import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/data/datasources/remote/service/media_service.dart';
import 'package:navy_wear/core/domain/model/auth/auth_session.dart';
import 'package:navy_wear/core/domain/model/store/store.dart';
import 'package:navy_wear/core/domain/model/store/store_settings.dart';
import 'package:navy_wear/core/domain/model/user/app_user.dart';

/// Payloads copied from the running marketplace backend, not from the docs.
void main() {
  group('AuthSession', () {
    test('carries no identity — only tokens and a fifteen minute life', () {
      // The previous backend put seller_id and role in here. This one puts
      // nothing, which is why the repository follows a login with GET /me.
      final session = AuthSession.fromJson(<String, dynamic>{
        'access_token': 'eyJ0eXAi...',
        'refresh_token': '4a922790b983',
        'expires_in': 900,
        'requires_reconsent': false,
      });

      expect(session.accessToken, 'eyJ0eXAi...');
      expect(session.expiresIn, 900);
      expect(session.requiresReconsent, isFalse);
    });

    test('a refresh that omits the refresh token leaves it null', () {
      final session = AuthSession.fromJson(<String, dynamic>{
        'access_token': 'fresh',
        'expires_in': 900,
      });

      // SessionStore relies on this being null rather than empty so it knows
      // to keep the stored one instead of clearing the session.
      expect(session.refreshToken, isNull);
    });
  });

  group('RegistrationResult', () {
    test('register creates the account without logging it in', () {
      final result = RegistrationResult.fromJson(<String, dynamic>{
        'user_id': 1,
        'dev_verification_token': 'ed829f3fe40d',
      });

      expect(result.userId, 1);
      expect(result.canSelfVerify, isTrue);
    });

    test('without a dev token the flow has to wait for a real email', () {
      final result =
          RegistrationResult.fromJson(<String, dynamic>{'user_id': 7});

      expect(result.canSelfVerify, isFalse);
    });
  });

  group('AppUser.fromJson', () {
    test('reads the string ids and flags the server actually sends', () {
      final user = AppUser.fromJson(<String, dynamic>{
        'id': '2',
        'email': 'fe2@marketplace.test',
        'phone': '081399900002',
        'full_name': 'Probe Dua',
        'status': 'active',
        'email_verified': '0',
        'phone_verified': '0',
        'created_at': '2026-09-13 13:59:59',
        'roles': <dynamic>[
          <String, dynamic>{'code': 'buyer', 'name': 'Buyer'},
        ],
        'stores': <dynamic>[],
      });

      expect(user.id, 2);
      expect(user.emailVerified, isFalse);
      expect(user.isSeller, isFalse);
      expect(user.hasStore, isFalse);
      expect(user.displayName, 'Probe Dua');
    });

    test('an account can hold the seller role and several stores at once', () {
      final user = AppUser.fromJson(<String, dynamic>{
        'id': '2',
        'roles': <dynamic>[
          <String, dynamic>{'code': 'buyer'},
          <String, dynamic>{'code': 'seller'},
        ],
        'stores': <dynamic>[
          <String, dynamic>{'id': '1', 'name': 'Toko A'},
          <String, dynamic>{'id': '2', 'name': 'Toko B'},
        ],
      });

      expect(user.isSeller, isTrue);
      expect(user.stores.map((s) => s.name), <String>['Toko A', 'Toko B']);
    });

    test('falls back to the email, then the id, for a display name', () {
      expect(
        AppUser.fromJson(<String, dynamic>{'id': '9', 'email': 'a@b.c'})
            .displayName,
        'a@b.c',
      );
      expect(AppUser.fromJson(<String, dynamic>{'id': '9'}).displayName,
          'Akun 9');
    });
  });

  group('Store.fromJson', () {
    test('a new store is inactive and cannot sell yet', () {
      final store = Store.fromJson(<String, dynamic>{
        'id': '1',
        'owner_user_id': '2',
        'name': 'Toko Probe FE',
        'slug': 'toko-probe-fe-ac4189',
        'type': 'physical',
        'status': 'inactive',
        'rating_avg': '0.00',
        'rating_count': '0',
      });

      expect(store.id, 1);
      expect(store.isActive, isFalse);
      expect(store.ratingAvg, 0);
      // The server appends a uniqueness suffix, so the slug that comes back is
      // not the one that was asked for.
      expect(store.publicSlug, 'toko-probe-fe-ac4189');
    });

    test('reads the DECIMAL rating the server sends as a string', () {
      final store = Store.fromJson(<String, dynamic>{
        'id': '3',
        'name': 'Toko Ramai',
        'status': 'active',
        'rating_avg': '4.75',
        'rating_count': '128',
      });

      expect(store.isActive, isTrue);
      expect(store.ratingAvg, 4.75);
      expect(store.ratingCount, 128);
    });
  });

  group('StoreSettings.fromJson', () {
    test('reads the 0/1 flags as booleans', () {
      final settings = StoreSettings.fromJson(<String, dynamic>{
        'id': '1',
        'store_id': '1',
        'auto_accept_order': '0',
        'vacation_mode': '1',
        'default_currency': 'IDR',
      });

      expect(settings.storeId, 1);
      expect(settings.autoAcceptOrder, isFalse);
      expect(settings.vacationMode, isTrue);
    });
  });

  group('normaliseUploadUrl', () {
    test('points an upload back at the API host', () {
      // The server builds this from its own configured host, which is a port
      // nothing listens on here; the same file is served by the API host.
      expect(
        normaliseUploadUrl(
          'http://localhost:8080/marketplace-api/uploads/2026/09/abc.png',
        ),
        'http://localhost:8000/uploads/2026/09/abc.png',
      );
    });

    test('leaves a URL on the API host alone', () {
      const url = 'http://localhost:8000/uploads/2026/09/abc.png';
      expect(normaliseUploadUrl(url), url);
    });

    test('leaves a real CDN URL alone', () {
      const url = 'https://cdn.marketplace.id/uploads/abc.png';
      expect(normaliseUploadUrl(url), url);
    });
  });
}
