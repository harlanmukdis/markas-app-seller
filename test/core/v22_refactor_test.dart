import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/data_state.dart';
import 'package:navy_wear/core/domain/model/auth/auth_session.dart';
import 'package:navy_wear/core/domain/model/inventory/inventory.dart';
import 'package:navy_wear/core/domain/model/review/review.dart';
import 'package:navy_wear/core/domain/model/seller/seller_model.dart';
import 'package:navy_wear/core/utils/json_parse.dart';

/// The v2.2 backend refactor renamed the audit columns across all 87 tables
/// and dropped the old names entirely. Payloads below are captured from the
/// running v2.2 backend.
void main() {
  group('audit timestamps', () {
    test('reads created_date and modified_date', () {
      const row = <String, dynamic>{
        'created_date': '2026-09-07 14:01:04',
        'modified_date': '2026-09-07 15:22:00',
      };

      expect(asCreatedDate(row)!.hour, 14);
      expect(asModifiedDate(row)!.hour, 15);
    });

    test('still accepts the pre-refactor names', () {
      // Costs nothing and keeps a rolled-back environment parsing.
      const legacy = <String, dynamic>{
        'created_at': '2026-09-05 09:00:00',
        'updated_at': '2026-09-05 10:00:00',
      };

      expect(asCreatedDate(legacy)!.hour, 9);
      expect(asModifiedDate(legacy)!.hour, 10);
    });

    test('is null when neither name is present', () {
      expect(asCreatedDate(const <String, dynamic>{}), isNull);
      expect(asModifiedDate(const <String, dynamic>{}), isNull);
    });

    test('an inventory ledger row parses its new column name', () {
      final entry = InventoryLedgerEntry.fromJson(<String, dynamic>{
        'id': '3',
        'offer_id': '1',
        'movement_type': 'STOCK_IN',
        'qty_physical_delta': '100.0000',
        'created_date': '2026-09-07 08:30:00',
      });

      expect(entry.createdAt, isNotNull);
      expect(entry.isInbound, isTrue);
    });
  });

  group('seller payload', () {
    // Semantic timestamps were NOT renamed — only the audit columns were.
    const seller = <String, dynamic>{
      'id': '1',
      'name': 'Toko Sumber Bangunan',
      'status': 'VERIFIED',
      'status_id': '6',
      'score': '98.00',
      'kyc_approved_at': '2026-09-06 10:00:00',
      'trial_started_at': '2026-09-05 09:00:00',
      'created_date': '2026-09-05 09:00:00',
      'modified_date': '2026-09-07 09:00:00',
      'activation_gates': <String, dynamic>{
        'kyc_approved': true,
        'bank_verified': true,
        'has_shipping_rate': true,
        'agreement_signed': true,
        'all_passed': true,
      },
    };

    test('keeps the string status and ignores the new numeric status_id', () {
      final parsed = SellerModel.fromJson(seller);

      expect(parsed.status, 'VERIFIED');
      expect(parsed.activationGates.allPassed, isTrue);
    });

    test('still reads the semantic *_at timestamps, which kept their names',
        () {
      final parsed = SellerModel.fromJson(seller);

      expect(parsed.kycApprovedAt, isNotNull);
      expect(parsed.trialStartedAt, isNotNull);
    });
  });

  group('AuthSession', () {
    test('reads actor_type for a store account', () {
      final session = AuthSession.fromJson(<String, dynamic>{
        'user_id': 3,
        'role': 'SEL',
        'seller_id': 1,
        'actor_type': 'MERCHANT',
        'access_token': 'token',
        'refresh_token': 'refresh',
        'expires_in': 7200,
      });

      expect(session.actorType, ActorType.merchant);
      expect(session.isMerchant, isTrue);
      // role, not actor_type, is what decides what the account can do.
      expect(session.role, 'SEL');
      expect(session.hasSellerContext, isTrue);
    });

    test('tolerates a response without actor_type', () {
      final session = AuthSession.fromJson(<String, dynamic>{
        'access_token': 'token',
      });

      expect(session.actorType, isNull);
      expect(session.isMerchant, isFalse);
    });
  });

  group('DataError', () {
    test('treats PERMISSION_DENIED as a refusal, like FORBIDDEN', () {
      // v2.2 added a group+menu permission layer with its own code. Both are
      // dead ends for the user, so the UI must not have to tell them apart.
      const denied = DataError(
        code: DataErrorCode.permissionDenied,
        message: 'Tidak diizinkan',
        statusCode: 403,
      );
      const forbidden = DataError(
        code: DataErrorCode.forbidden,
        message: 'Bukan milik toko Anda',
        statusCode: 403,
      );

      expect(denied.isForbidden, isTrue);
      expect(forbidden.isForbidden, isTrue);
      expect(
        const DataError(code: DataErrorCode.notFound, message: 'x').isForbidden,
        isFalse,
      );
    });
  });

  group('OfferReviews', () {
    test('reads the summary and items from the live shape', () {
      final reviews = OfferReviews.fromJson(<String, dynamic>{
        'summary': <String, dynamic>{
          'review_count': '1',
          'avg_rating': '4.00',
        },
        'items': <dynamic>[
          <String, dynamic>{
            'id': '2',
            'offer_id': '67',
            'buyer_id': '1',
            'buyer_name': 'Budi Retail',
            'rating': '4',
            'comment': 'Barang sesuai',
            'created_date': '2026-09-07 12:00:00',
          },
        ],
      });

      expect(reviews.reviewCount, 1);
      expect(reviews.averageRating, 4.0);
      expect(reviews.ratingLabel, '4,0');
      expect(reviews.items.single.rating, 4);
      expect(reviews.items.single.createdAt, isNotNull);
    });

    test('an offer with no reviews is empty, not an error', () {
      final reviews = OfferReviews.fromJson(<String, dynamic>{
        'summary': <String, dynamic>{
          'review_count': '0',
          'avg_rating': '0.00',
        },
        'items': <dynamic>[],
      });

      expect(reviews.hasReviews, isFalse);
      expect(reviews.items, isEmpty);
    });
  });
}
