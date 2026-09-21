import '../../data_state.dart';
import '../model/notification/app_notification.dart';
import '../model/notification/notification_preference.dart';

/// The account's notification inbox. Per user, not per store.
abstract class NotificationRepository {
  Future<DataState<List<AppNotification>>> getNotifications({int page});

  /// Returns the inbox as it stands afterwards; the write itself answers
  /// `data: null`.
  Future<DataState<List<AppNotification>>> markRead(int notificationId);

  Future<DataState<List<AppNotification>>> markAllRead();

  /// Empty until the account has received something — the server derives the
  /// list from the inbox rather than from a fixed set of types.
  Future<DataState<List<NotificationPreference>>> getPreferences();

  Future<DataState<List<NotificationPreference>>> setPreference({
    required String type,
    required String channel,
    required bool isEnabled,
  });
}
