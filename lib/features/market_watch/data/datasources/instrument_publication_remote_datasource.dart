import 'package:dio/dio.dart';
import '../../domain/entities/instrument_detail_models.dart';
import '../../domain/entities/instrument_entity.dart';

/// Récupère les publications d'un instrument depuis le backend BVMT
/// Utilise l'endpoint /api/publications/company qui scrape directement
/// les publications de la société depuis le site BVMT avec le filtre type_societe
class InstrumentPublicationRemoteDataSource {
  final Dio _dio;

  InstrumentPublicationRemoteDataSource({required Dio dio}) : _dio = dio;

  /// Récupère TOUTES les publications d'une société depuis BVMT
  Future<List<StockPublication>> getPublications(
      InstrumentEntity instrument) async {
    try {
      print('📡 [PUB] Fetching publications for: "${instrument.valeur}" (mnemo: ${instrument.mnemo})');
      print('📡 [PUB] Dio baseUrl: ${_dio.options.baseUrl}');
      final response = await _dio.get(
        '/api/publications/company',
        queryParameters: {
          'name': instrument.valeur,
          'mnemo': instrument.mnemo,
          'pages': 3,
        },
      );

      print('📡 [PUB] Response status: ${response.statusCode}');
      print('📡 [PUB] Response data keys: ${response.data?.keys}');
      final data = response.data['data'] as List;
      print('📡 [PUB] Got ${data.length} publications');
      return data.map((json) => StockPublication(
        date: json['date'] as String? ?? '',
        titre: json['title'] as String? ?? '',
        description: json['description'] as String?,
        pdfUrl: json['pdfUrl'] as String?,
        detailUrl: json['detailUrl'] as String?,
      )).toList();
    } catch (e) {
      print('❌ [PUB] Error fetching publications: $e');
      return [];
    }
  }
}
