import 'package:dio/dio.dart';
import '../../domain/entities/notification_entity.dart';

/// Datasource distant — appelle le backend NestJS /api/notifications
class NotificationsRemoteDataSource {
  final Dio _dio;

  NotificationsRemoteDataSource({required Dio dio}) : _dio = dio;

  /// Récupère les notifications paginées
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/api/notifications',
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data['data'] as List;
    final notifications = data.map((json) => _fromJson(json)).toList();

    return {
      'data': notifications,
      'total': response.data['total'] as int? ?? 0,
      'unread': response.data['unread'] as int? ?? 0,
    };
  }

  /// Récupère uniquement le nombre de non-lus (pour le badge)
  Future<int> getUnreadCount() async {
    final response = await _dio.get('/api/notifications/unread-count');
    return response.data['count'] as int? ?? 0;
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(String id) async {
    await _dio.patch('/api/notifications/$id/read');
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    await _dio.patch('/api/notifications/read-all');
  }

  NotificationEntity _fromJson(Map<String, dynamic> json) {
    DateTime createdAt = DateTime.now();
    final raw = json['createdAt'];
    if (raw != null) {
      createdAt = DateTime.tryParse(raw.toString()) ?? DateTime.now();
    }

    return NotificationEntity(
      id: json['_id']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      publicationTitle: json['publicationTitle']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      pdfUrl: json['pdfUrl']?.toString() ?? '',
      detailUrl: json['detailUrl']?.toString() ?? '',
      totalPublications: (json['totalPublications'] as num?)?.toInt() ?? 0,
      isRead: json['isRead'] as bool? ?? false,
      nodeId: json['nodeId']?.toString() ?? '',
      createdAt: createdAt,
    );
  }
}
