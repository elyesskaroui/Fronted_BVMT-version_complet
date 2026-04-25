import 'package:dio/dio.dart';
import '../../domain/entities/indices_stock_entity.dart';
import 'indices_mock_datasource.dart';

/// Source de données distante — Indices BVMT
/// Appelle le backend NestJS /api/live-market/market
class IndicesRemoteDataSource extends IndicesMockDataSource {
  final Dio _dio;

  IndicesRemoteDataSource({required Dio dio}) : _dio = dio;

  @override
  Future<List<IndicesStockEntity>> getAllIndicesStocks() async {
    final response = await _dio.get('/api/live-market/market');
    final data = response.data as List;
    return data.map((json) => _fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<IndicesStockEntity>> searchStocks(String query) async {
    final all = await getAllIndicesStocks();
    final q = query.toLowerCase();
    return all.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  IndicesStockEntity _fromJson(Map<String, dynamic> json) {
    return IndicesStockEntity(
      name: json['fullInstrumentName'] as String? ?? '',
      openPrice: double.tryParse(json['openPrice']?.toString() ?? ''),
      closePrice: double.tryParse(json['lastTradePrice']?.toString() ?? '') ?? 0,
      changePercent: double.tryParse(json['varPrevClose']?.toString() ?? '') ?? 0,
      transactions: (json['tradeCount'] as num?)?.toInt(),
      volume: int.tryParse(json['quantity']?.toString() ?? ''),
      capitaux: double.tryParse(json['capit']?.toString() ?? '')?.toInt(),
    );
  }
}
