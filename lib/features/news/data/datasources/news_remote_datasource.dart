import 'package:dio/dio.dart';
import '../../domain/entities/news_entity.dart';

/// Source de données distante — appelle le backend NestJS
class NewsRemoteDataSource {
  final Dio _dio;

  NewsRemoteDataSource({required Dio dio}) : _dio = dio;

  /// Récupère les publications depuis le backend
  Future<List<NewsEntity>> getAllNews({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _dio.get(
      '/api/publications',
      queryParameters: queryParams,
    );

    final data = response.data['data'] as List;
    return data.map((json) => _fromJson(json)).toList();
  }

  /// Récupère les catégories disponibles
  Future<List<String>> getCategories() async {
    final response = await _dio.get('/api/publications/categories');
    final data = response.data['data'] as List;
    return data.cast<String>();
  }

  /// Force un nouveau scraping (admin)
  Future<void> triggerScrape() async {
    await _dio.post('/api/publications/scrape');
  }

  NewsEntity _fromJson(Map<String, dynamic> json) {
    // Parse la date DD/MM/YYYY en DateTime
    DateTime publishedAt = DateTime.now();
    final dateStr = json['date'] as String? ?? '';
    if (dateStr.contains('/')) {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        publishedAt = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    }

    return NewsEntity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['description'] as String? ?? '',
      source: json['source'] as String? ?? 'BVMT',
      category: json['category'] as String? ?? '',
      publishedAt: publishedAt,
      pdfUrl: json['pdfUrl'] as String? ?? '',
      detailUrl: json['detailUrl'] as String? ?? '',
    );
  }
}
