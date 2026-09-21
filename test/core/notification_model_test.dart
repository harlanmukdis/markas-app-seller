import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/notification/app_notification.dart';
import 'package:navy_wear/core/domain/model/notification/notification_preference.dart';

/// Payloads captured from the running marketplace API.
void main() {
  group('AppNotification.fromJson', () {
    // Verbatim from GET /me/notifications for the owner of store 1.
    Map<String, dynamic> row({
      String isRead = '0',
      String? data =
          '{"order_id":473,"order_number":"ORD-PWW8LTAVB4"}',
      String type = 'order_new',
    }) =>
        <String, dynamic>{
          'id': '180',
          'user_id': '10',
          'type': type,
          'title': 'Pesanan Baru Masuk',
          'body': 'Order #ORD-PWW8LTAVB4 senilai Rp39.000 menunggu diproses',
          'data': data,
          'is_read': isRead,
          'created_at': '2026-09-21 21:17:40',
        };

    test('reads a new-order notification', () {
      final notification = AppNotification.fromJson(row());

      expect(notification.id, 180);
      expect(notification.type, NotificationType.orderNew);
      expect(notification.title, 'Pesanan Baru Masuk');
      expect(notification.isRead, isFalse);
    });

    test('data arrives as a JSON string and still yields the order', () {
      // The column hands back encoded JSON rather than an object — the same
      // trap as `variant_options`. Read raw, `data['order_id']` would be null
      // and the row would lead nowhere.
      final notification = AppNotification.fromJson(row());

      expect(notification.orderId, 473);
      expect(notification.orderNumber, 'ORD-PWW8LTAVB4');
      expect(notification.isAboutOrder, isTrue);
    });

    test('a notification with no data leads nowhere, and says so', () {
      final notification = AppNotification.fromJson(row(data: null));

      expect(notification.data, isEmpty);
      expect(notification.orderId, isNull);
      expect(notification.isAboutOrder, isFalse);
    });

    test('is_read is a string flag like everything else here', () {
      expect(AppNotification.fromJson(row(isRead: '1')).isRead, isTrue);
    });

    test('an unknown type still renders rather than vanishing', () {
      // `type` is free text and admin broadcasts can carry anything, so the
      // label falls through to the raw value.
      final notification = AppNotification.fromJson(row(type: 'promo_blast'));

      expect(NotificationType.label(notification.type), 'promo_blast');
    });
  });

  group('NotificationPreference', () {
    // Verbatim from GET /me/notification-preferences. Note the channel values
    // are real booleans, not the "1"/"0" strings the rest of the API sends —
    // this array is built in PHP rather than read off a MySQL row.
    NotificationPreference preference({
      bool push = true,
      bool email = true,
      bool whatsapp = true,
      bool sms = true,
    }) =>
        NotificationPreference.fromJson(<String, dynamic>{
          'notification_type': 'order_new',
          'channels': <String, dynamic>{
            'push': push,
            'email': email,
            'whatsapp': whatsapp,
            'sms': sms,
          },
        });

    test('reads the channel switches', () {
      final pref = preference(email: false);

      expect(pref.type, NotificationType.orderNew);
      expect(pref.isEnabled(NotificationChannel.email), isFalse);
      expect(pref.isEnabled(NotificationChannel.push), isTrue);
      expect(pref.isFullyMuted, isFalse);
    });

    test('a channel the server did not mention defaults to on', () {
      // The server only stores overrides; anything absent is enabled.
      final pref = NotificationPreference.fromJson(<String, dynamic>{
        'notification_type': 'order_new',
        'channels': <String, dynamic>{'push': false},
      });

      expect(pref.isEnabled(NotificationChannel.push), isFalse);
      expect(pref.isEnabled(NotificationChannel.sms), isTrue);
    });

    test('fully muted means every outside channel is off', () {
      final pref = preference(
        push: false,
        email: false,
        whatsapp: false,
        sms: false,
      );

      expect(pref.isFullyMuted, isTrue);
    });

    test('in_app is not among the channels that can be muted', () {
      // The server answers 422 for it: the inbox doubles as the history, so
      // offering the switch at all would be offering a request that fails.
      expect(NotificationChannel.mutable,
          isNot(contains(NotificationChannel.inApp)));
      expect(NotificationChannel.mutable, hasLength(4));
    });

    test('withChannel leaves the others alone', () {
      final pref = preference().withChannel(NotificationChannel.sms, false);

      expect(pref.isEnabled(NotificationChannel.sms), isFalse);
      expect(pref.isEnabled(NotificationChannel.push), isTrue);
      expect(pref.isEnabled(NotificationChannel.email), isTrue);
    });
  });
}
