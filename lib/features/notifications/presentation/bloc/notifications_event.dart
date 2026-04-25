import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// Charger les notifications
class NotificationsLoadRequested extends NotificationsEvent {
  const NotificationsLoadRequested();
}

/// Rafraîchir (pull-to-refresh)
class NotificationsRefreshRequested extends NotificationsEvent {
  const NotificationsRefreshRequested();
}

/// Marquer une notification comme lue
class NotificationMarkRead extends NotificationsEvent {
  final String id;
  const NotificationMarkRead(this.id);

  @override
  List<Object?> get props => [id];
}

/// Marquer toutes comme lues
class NotificationsMarkAllRead extends NotificationsEvent {
  const NotificationsMarkAllRead();
}
