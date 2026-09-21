part of 'notification_cubit.dart';

sealed class NotificationState {
  const NotificationState();
}

final class NotificationInProgress extends NotificationState {
  const NotificationInProgress();
}

final class NotificationFailure extends NotificationState {
  const NotificationFailure(this.error);

  final DataError error;
}

final class NotificationLoaded extends NotificationState {
  const NotificationLoaded({
    required this.notifications,
    this.page = 1,
    this.hasMore = false,
    this.isBusy = false,
  });

  /// Newest first, as the server returns them.
  final List<AppNotification> notifications;

  final int page;

  /// Inferred from the last page coming back full — this API sends no `meta`
  /// on the inbox, so there is no total to compare against.
  final bool hasMore;

  final bool isBusy;

  int get unreadCount =>
      notifications.where((notification) => !notification.isRead).length;

  bool get hasUnread => unreadCount > 0;

  NotificationLoaded copyWith({
    List<AppNotification>? notifications,
    int? page,
    bool? hasMore,
    bool? isBusy,
  }) =>
      NotificationLoaded(
        notifications: notifications ?? this.notifications,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isBusy: isBusy ?? this.isBusy,
      );
}
