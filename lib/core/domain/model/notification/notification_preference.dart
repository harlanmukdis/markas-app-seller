import '../../../utils/json_parse.dart';

/// One row of `GET /me/notification-preferences` (v1.5.0).
///
/// ⚠️ **The list is derived from what the account has already received.** The
/// server builds it from `SELECT DISTINCT type FROM notifications WHERE
/// user_id = …`, so a seller who has never had an order sees **no rows at
/// all** and cannot pre-configure anything. The list grows as notifications
/// arrive, which is worth saying on screen — an empty page here is not a bug.
///
/// A channel with no stored override defaults to **on**, so every switch
/// starts enabled.
class NotificationPreference {
  const NotificationPreference({
    required this.type,
    this.channels = const <String, bool>{},
  });

  final String type;

  /// Keyed by channel. Unusually for this API the values are **real
  /// booleans**, not `"1"`/`"0"` strings — the server builds this array in
  /// PHP rather than handing back a MySQL row.
  final Map<String, bool> channels;

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    final raw = asMapOrNull(json['channels']) ?? const <String, dynamic>{};
    return NotificationPreference(
      type: asString(json['notification_type']),
      channels: <String, bool>{
        for (final entry in raw.entries) entry.key: asBool(entry.value),
      },
    );
  }

  bool isEnabled(String channel) => channels[channel] ?? true;

  /// True when every channel this type can use is switched off. `in_app` is
  /// not among them, so the notification still reaches the app's own inbox —
  /// muting here silences the outside world, not this screen.
  bool get isFullyMuted =>
      NotificationChannel.mutable.every((channel) => !isEnabled(channel));

  NotificationPreference withChannel(String channel, bool isEnabled) =>
      NotificationPreference(
        type: type,
        channels: <String, bool>{...channels, channel: isEnabled},
      );
}

abstract class NotificationChannel {
  /// The app's own inbox. **Cannot be muted** — the server rejects it with a
  /// 422 — because it doubles as the notification history.
  static const String inApp = 'in_app';

  static const String push = 'push';
  static const String email = 'email';
  static const String whatsapp = 'whatsapp';
  static const String sms = 'sms';

  /// The four the `PATCH` accepts. Sending [inApp] is a validation error.
  static const List<String> mutable = <String>[push, email, whatsapp, sms];

  static String label(String channel) => switch (channel) {
        push => 'Push',
        email => 'Email',
        whatsapp => 'WhatsApp',
        sms => 'SMS',
        inApp => 'Dalam aplikasi',
        _ => channel,
      };
}
