import 'package:dio/dio.dart';
import '../../../home/domain/entities/market_summary_entity.dart';
import 'market_watch_mock_datasource.dart';

/// Source de données distante — Market Watch
/// Appelle le backend NestJS /api/live-market/*
class MarketWatchRemoteDataSource extends MarketWatchMockDataSource {
  final Dio _dio;

  MarketWatchRemoteDataSource({required Dio dio}) : _dio = dio;

  @override
  Future<MarketSummaryEntity> getMarketSummary() async {
    final results = await Future.wait([
      _dio.get('/api/live-market/statistics'),
      _dio.get('/api/live-market/indices'),
      _dio.get('/api/live-market/market-status'),
    ]);

    final stats = results[0].data as Map<String, dynamic>;
    final indicesData = results[1].data as List;
    final statusData = results[2].data as List;

    // Statut marché principal (emm=1)
    final mainStatus = statusData.firstWhere(
      (s) => (s['emm'] as num?)?.toInt() == 1,
      orElse: () => statusData.isNotEmpty ? statusData.first : <String, dynamic>{},
    ) as Map<String, dynamic>;
    final isOpen = (mainStatus['status'] as String? ?? '') == 'Open';
    final sessionDate = mainStatus['sessionDate'] as String? ?? '';

    // Indices
    final tunindexData = indicesData.firstWhere(
      (i) {
        final name = (i['fullIndiceName'] as String? ?? '').toUpperCase();
        return name == 'TUNINDEX';
      },
      orElse: () => <String, dynamic>{},
    ) as Map<String, dynamic>;
    final tunindex20Data = indicesData.firstWhere(
      (i) => (i['fullIndiceName'] as String? ?? '').toUpperCase().contains('TUNINDEX20'),
      orElse: () => <String, dynamic>{},
    ) as Map<String, dynamic>;

    return MarketSummaryEntity(
      sessionDate: 'Séance du $sessionDate',
      isSessionOpen: isOpen,
      isBlocMarketOpen: isOpen,
      tunindex: IndexData(
        name: 'TUNINDEX',
        value: double.tryParse(tunindexData['indexLevel']?.toString() ?? '') ?? 0,
        changePercent: double.tryParse(tunindexData['varLastPrice']?.toString() ?? '') ?? 0,
        yearChangePercent: (tunindexData['yearlyVariation'] as num?)?.toDouble() ?? 0,
      ),
      tunindex20: IndexData(
        name: 'TUNINDEX20',
        value: double.tryParse(tunindex20Data['indexLevel']?.toString() ?? '') ?? 0,
        changePercent: double.tryParse(tunindex20Data['varLastPrice']?.toString() ?? '') ?? 0,
        yearChangePercent: (tunindex20Data['yearlyVariation'] as num?)?.toDouble() ?? 0,
      ),
      marketCap: double.tryParse(stats['capi']?.toString() ?? '') ?? 0,
      totalCapitaux: (stats['capitaux'] as num?)?.toDouble() ?? 0,
      totalQuantity: (stats['quantite'] as num?)?.toInt() ?? 0,
      totalTransactions: (stats['transactions'] as num?)?.toInt() ?? 0,
      nbHausses: (stats['hausses'] as num?)?.toInt() ?? 0,
      nbBaisses: (stats['baisses'] as num?)?.toInt() ?? 0,
      activeValues: (stats['nbSocieteActives'] as num?)?.toInt() ?? 0,
      totalValues: (stats['nbSocieteCote'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<List<ChartPoint>> getTunindexIntraday() async => [];

  @override
  Future<List<ChartPoint>> getTunindex20Intraday() async => [];

  @override
  Future<List<TopStockEntry>> getTopHausses() async {
    final data = await _getMarketData();
    data.sort((a, b) => _parseDouble(b['varPrevClose']).compareTo(_parseDouble(a['varPrevClose'])));
    return _toTopStockEntries(data.where((d) => _parseDouble(d['varPrevClose']) > 0).take(10).toList(), 'varPrevClose');
  }

  @override
  Future<List<TopStockEntry>> getTopBaisses() async {
    final data = await _getMarketData();
    data.sort((a, b) => _parseDouble(a['varPrevClose']).compareTo(_parseDouble(b['varPrevClose'])));
    return _toTopStockEntries(data.where((d) => _parseDouble(d['varPrevClose']) < 0).take(10).toList(), 'varPrevClose');
  }

  @override
  Future<List<TopStockEntry>> getTopCapitaux() async {
    final data = await _getMarketData();
    data.sort((a, b) => _parseDouble(b['capit']).compareTo(_parseDouble(a['capit'])));
    return _toTopStockEntries(data.take(10).toList(), 'capit');
  }

  @override
  Future<List<TopStockEntry>> getTopQuantite() async {
    final data = await _getMarketData();
    data.sort((a, b) => _parseInt(b['quantity']).compareTo(_parseInt(a['quantity'])));
    return _toTopStockEntries(data.take(10).toList(), 'quantity');
  }

  @override
  Future<List<TopStockEntry>> getTopTransactions() async {
    final data = await _getMarketData();
    data.sort((a, b) => ((b['tradeCount'] as num?) ?? 0).compareTo((a['tradeCount'] as num?) ?? 0));
    return _toTopStockEntries(data.take(10).toList(), 'tradeCount');
  }

  Future<List<Map<String, dynamic>>> _getMarketData() async {
    final response = await _dio.get('/api/live-market/market');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  List<TopStockEntry> _toTopStockEntries(List<Map<String, dynamic>> data, String metricField) {
    return data.map((json) {
      final double metric;
      if (metricField == 'tradeCount') {
        metric = ((json['tradeCount'] as num?) ?? 0).toDouble();
      } else if (metricField == 'quantity') {
        metric = _parseInt(json['quantity']).toDouble();
      } else {
        metric = _parseDouble(json[metricField]).abs();
      }
      return TopStockEntry(
        symbol: json['mnemo'] as String? ?? '',
        lastPrice: _parseDouble(json['lastTradePrice']),
        changePercent: _parseDouble(json['varPrevClose']),
        metricValue: metric,
      );
    }).toList();
  }

  double _parseDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;
  int _parseInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
}
