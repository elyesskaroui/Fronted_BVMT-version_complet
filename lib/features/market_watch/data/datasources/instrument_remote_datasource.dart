import 'package:dio/dio.dart';
import '../../domain/entities/instrument_entity.dart';
import 'instrument_mock_datasource.dart';

/// Source de données distante — Instruments BVMT
/// Appelle le backend NestJS /api/live-market/market + limits/bid + limits/ask
class InstrumentRemoteDataSource extends InstrumentMockDataSource {
  final Dio _dio;

  InstrumentRemoteDataSource({required Dio dio}) : _dio = dio;

  @override
  Future<List<InstrumentEntity>> getActions() async {
    final results = await Future.wait([
      _dio.get('/api/live-market/market'),
      _dio.get('/api/live-market/limits/bid'),
      _dio.get('/api/live-market/limits/ask'),
    ]);

    final marketData = (results[0].data as List).cast<Map<String, dynamic>>();
    final bidData = (results[1].data as List).cast<Map<String, dynamic>>();
    final askData = (results[2].data as List).cast<Map<String, dynamic>>();

    // Construire maps codeIsin → meilleure offre
    final bidMap = <String, Map<String, dynamic>>{};
    for (final b in bidData) {
      final isin = b['codeIsin'] as String? ?? '';
      bidMap.putIfAbsent(isin, () => b);
    }
    final askMap = <String, Map<String, dynamic>>{};
    for (final a in askData) {
      final isin = a['codeIsin'] as String? ?? '';
      askMap.putIfAbsent(isin, () => a);
    }

    return marketData
        .map((json) => _instrumentFromJson(json, bidMap, askMap))
        .toList();
  }

  @override
  Future<List<InstrumentEntity>> getLignesSecondaires() async => [];

  @override
  Future<List<InstrumentEntity>> getObligations() async => [];

  @override
  Future<List<InstrumentEntity>> getMarcheHorsCote() async => [];

  @override
  Future<List<InstrumentEntity>> getByMarket(InstrumentMarket market) {
    switch (market) {
      case InstrumentMarket.actions:
        return getActions();
      case InstrumentMarket.lignesSecondaires:
        return getLignesSecondaires();
      case InstrumentMarket.obligations:
        return getObligations();
      case InstrumentMarket.marcheHorsCote:
        return getMarcheHorsCote();
    }
  }

  @override
  Future<List<InstrumentEntity>> searchInMarket(
    String query,
    InstrumentMarket market,
  ) async {
    final all = await getByMarket(market);
    final q = query.toLowerCase();
    return all
        .where((i) =>
            i.mnemo.toLowerCase().contains(q) ||
            i.valeur.toLowerCase().contains(q))
        .toList();
  }

  InstrumentEntity _instrumentFromJson(
    Map<String, dynamic> json,
    Map<String, Map<String, dynamic>> bidMap,
    Map<String, Map<String, dynamic>> askMap,
  ) {
    final isin = json['codeIsin'] as String? ?? '';
    final bid = bidMap[isin];
    final ask = askMap[isin];

    final statusStr = json['status'] as String? ?? '';
    final statut = (statusStr == 'Continuous' ||
            statusStr == 'PreOpening' ||
            statusStr == 'Open')
        ? 'Open'
        : 'Closed';

    return InstrumentEntity(
      mnemo: json['mnemo'] as String? ?? '',
      valeur: json['fullInstrumentName'] as String? ?? '',
      statut: statut,
      qteAchat: (bid?['quantity'] as num?)?.toInt() ?? 0,
      achat: _parseDouble(bid?['bidPrice']),
      vente: _parseDouble(ask?['askPrice']),
      qteVente: (ask?['quantity'] as num?)?.toInt() ?? 0,
      dernier: _parseDouble(json['lastTradePrice']),
      coursRef: _parseDouble(json['referencePrice']),
      variation: _parseDouble(json['varPrevClose']),
      capitaux: _parseDouble(json['capit']),
      quantite: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      nbTransactions: (json['tradeCount'] as num?)?.toInt() ?? 0,
      ouverture: _parseDouble(json['openPrice']),
      plusHaut: _parseDouble(json['pHaut']),
      plusBas: _parseDouble(json['pbas']),
      seuilHaut: _parseDouble(json['sHaut']),
      seuilBas: _parseDouble(json['sBas']),
      market: InstrumentMarket.actions,
    );
  }

  double _parseDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;
}
