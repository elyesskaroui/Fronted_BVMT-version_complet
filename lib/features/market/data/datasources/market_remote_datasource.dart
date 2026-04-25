import 'package:dio/dio.dart';
import '../../../home/domain/entities/stock_entity.dart';
import '../../domain/entities/index_entity.dart';
import 'market_mock_datasource.dart';

/// Source de données distante — Market
/// Appelle le backend NestJS qui proxifie l'API BVMT Live Market
class MarketRemoteDataSource extends MarketMockDataSource {
  final Dio _dio;

  MarketRemoteDataSource({required Dio dio}) : _dio = dio;

  @override
  Future<List<StockEntity>> getAllStocks() async {
    print('>>> [MarketRemote] GET /api/live-market/market');
    final response = await _dio.get('/api/live-market/market');
    print('>>> [MarketRemote] Response status: ${response.statusCode}, items: ${(response.data as List).length}');
    final data = response.data as List;
    return data.map((json) => _stockFromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<StockEntity>> getStocksBySearch(String query) async {
    final all = await getAllStocks();
    final q = query.toLowerCase();
    return all
        .where((s) =>
            s.symbol.toLowerCase().contains(q) ||
            s.companyName.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<IndexEntity>> getMarketIndices() async {
    final response = await _dio.get('/api/live-market/indices');
    final data = response.data as List;
    return data.map((json) => _indexFromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<StockEntity> getStockDetail(String symbol) async {
    final all = await getAllStocks();
    return all.firstWhere(
      (s) => s.symbol == symbol,
      orElse: () => all.isNotEmpty ? all.first : const StockEntity(symbol: '', companyName: '', lastPrice: 0, changePercent: 0),
    );
  }

  @override
  Future<List<StockEntity>> getTopGainers() async {
    final all = await getAllStocks();
    final sorted = List<StockEntity>.from(all)
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    return sorted.take(5).toList();
  }

  @override
  Future<List<StockEntity>> getTopLosers() async {
    final all = await getAllStocks();
    final sorted = List<StockEntity>.from(all)
      ..sort((a, b) => a.changePercent.compareTo(b.changePercent));
    return sorted.take(5).toList();
  }

  @override
  Future<List<StockEntity>> getMostActive() async {
    final all = await getAllStocks();
    final sorted = List<StockEntity>.from(all)
      ..sort((a, b) => b.volume.compareTo(a.volume));
    return sorted.take(5).toList();
  }

  StockEntity _stockFromJson(Map<String, dynamic> json) {
    return StockEntity(
      symbol: json['mnemo'] as String? ?? '',
      companyName: json['fullInstrumentName'] as String? ?? '',
      lastPrice: double.tryParse(json['lastTradePrice']?.toString() ?? '') ?? 0,
      changePercent: double.tryParse(json['varPrevClose']?.toString() ?? '') ?? 0,
      volume: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      openPrice: double.tryParse(json['openPrice']?.toString() ?? '') ?? 0,
      highPrice: double.tryParse(json['pHaut']?.toString() ?? '') ?? 0,
      lowPrice: double.tryParse(json['pbas']?.toString() ?? '') ?? 0,
      closePrice: double.tryParse(json['referencePrice']?.toString() ?? '') ?? 0,
    );
  }

  IndexEntity _indexFromJson(Map<String, dynamic> json) {
    final value = double.tryParse(json['indexLevel']?.toString() ?? '') ?? 0;
    final prevClose = double.tryParse(json['prevcDayClose']?.toString() ?? '') ?? 0;
    return IndexEntity(
      name: json['fullIndiceName'] as String? ?? '',
      value: value,
      changePercent: double.tryParse(json['varLastPrice']?.toString() ?? '') ?? 0,
      changeValue: value - prevClose,
    );
  }
}
