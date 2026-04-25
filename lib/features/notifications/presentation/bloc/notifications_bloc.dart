import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/notifications_remote_datasource.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRemoteDataSource dataSource;

  NotificationsBloc({required this.dataSource})
      : super(const NotificationsInitial()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationsRefreshRequested>(_onLoad);
    on<NotificationMarkRead>(_onMarkRead);
    on<NotificationsMarkAllRead>(_onMarkAllRead);
  }

  Future<void> _onLoad(
    NotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (event is NotificationsLoadRequested) {
      emit(const NotificationsLoading());
    }
    try {
      final result = await dataSource.getNotifications();
      emit(NotificationsLoaded(
        notifications: result['data'],
        unreadCount: result['unread'] as int,
        total: result['total'] as int,
      ));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkRead(
    NotificationMarkRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await dataSource.markAsRead(event.id);
      final current = state;
      if (current is NotificationsLoaded) {
        final updated = current.notifications.map((n) {
          return n.id == event.id ? n.copyWith(isRead: true) : n;
        }).toList();
        final newUnread = updated.where((n) => !n.isRead).length;
        emit(NotificationsLoaded(
          notifications: updated,
          unreadCount: newUnread,
          total: current.total,
        ));
      }
    } catch (_) {}
  }

  Future<void> _onMarkAllRead(
    NotificationsMarkAllRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await dataSource.markAllAsRead();
      final current = state;
      if (current is NotificationsLoaded) {
        final updated = current.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        emit(NotificationsLoaded(
          notifications: updated,
          unreadCount: 0,
          total: current.total,
        ));
      }
    } catch (_) {}
  }
}
