import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/notification/app_notification.dart';
import '../../../../domain/model/notification/notification_preference.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

/// The account's notification inbox and its mute switches.
///
/// Per **user**, not per store: an account with several shops gets one
/// stream, and nothing distinguishes them beyond whatever each notification
/// put in its `data`.
class NotificationService extends BaseService {
  const NotificationService(super.dio);

  /// One page — twenty rows, newest first, and no `meta`. A short page is the
  /// only end-of-list signal there is.
  Future<List<AppNotification>> getNotifications({int page = 1}) async {
    final envelope = await getRequest(
      ApiEndpoints.notifications,
      query: <String, dynamic>{'page': page},
    );
    return asModelList(envelope.data, AppNotification.fromJson);
  }

  /// Scoped to the caller server-side, so another user's id simply does
  /// nothing. It also does nothing for an id that does not exist — the update
  /// matches no row and still answers `200`, so success here does not prove
  /// the notification was real.
  Future<void> markRead(int notificationId) async {
    await postRequest(ApiEndpoints.notificationRead(notificationId));
  }

  Future<void> markAllRead() async {
    await postRequest(ApiEndpoints.notificationsReadAll);
  }

  /// The mute switches, one entry per notification type the account has
  /// **already received** — the server derives the list from the inbox, so it
  /// is empty until something arrives.
  Future<List<NotificationPreference>> getPreferences() async {
    final envelope = await getRequest(ApiEndpoints.notificationPreferences);
    return asModelList(envelope.data, NotificationPreference.fromJson);
  }

  /// Sets one switch. The endpoint takes a single triple rather than a map,
  /// so a screen toggling several sends several requests.
  ///
  /// `in_app` is rejected with a 422: it is the inbox itself and doubles as
  /// the history, so it is deliberately not mutable.
  Future<void> setPreference({
    required String type,
    required String channel,
    required bool isEnabled,
  }) async {
    await patchRequest(
      ApiEndpoints.notificationPreferences,
      body: <String, dynamic>{
        'notification_type': type,
        'channel': channel,
        'is_enabled': isEnabled,
      },
    );
  }
}
