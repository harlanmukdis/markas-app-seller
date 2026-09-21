import '../../data_state.dart';
import '../../domain/model/notification/app_notification.dart';
import '../../domain/model/notification/notification_preference.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/remote/service/notification_service.dart';
import 'repository_guard.dart';

class NotificationRepositoryImpl
    with RepositoryGuard
    implements NotificationRepository {
  const NotificationRepositoryImpl(this._service);

  final NotificationService _service;

  @override
  Future<DataState<List<AppNotification>>> getNotifications({int page = 1}) =>
      guard(() => _service.getNotifications(page: page));

  @override
  Future<DataState<List<AppNotification>>> markRead(int notificationId) =>
      guard(() async {
        await _service.markRead(notificationId);
        return _service.getNotifications();
      });

  @override
  Future<DataState<List<AppNotification>>> markAllRead() => guard(() async {
        await _service.markAllRead();
        return _service.getNotifications();
      });

  @override
  Future<DataState<List<NotificationPreference>>> getPreferences() =>
      guard(() => _service.getPreferences());

  @override
  Future<DataState<List<NotificationPreference>>> setPreference({
    required String type,
    required String channel,
    required bool isEnabled,
  }) =>
      guard(() async {
        await _service.setPreference(
          type: type,
          channel: channel,
          isEnabled: isEnabled,
        );
        return _service.getPreferences();
      });
}
