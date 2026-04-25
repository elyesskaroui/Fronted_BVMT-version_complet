import 'dart:math' as math;
import '../../domain/entities/indices_stock_entity.dart';
import '../../domain/entities/index_summary_entity.dart';

/// Source de données mock — Tableau des indices BVMT
/// Données réalistes correspondant au tableau du site web BVMT
/// *En différé de 15 minutes
class IndicesMockDataSource {
  Future<List<IndicesStockEntity>> getAllIndicesStocks() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const [
      // ── A ──
      IndicesStockEntity(name: 'ADWYA', openPrice: null, closePrice: 4.800, changePercent: 0.00),
      IndicesStockEntity(name: 'ARTES', openPrice: 15.000, closePrice: 15.120, changePercent: -0.79, transactions: 38, volume: 4997, capitaux: 75009),
      IndicesStockEntity(name: 'ASSU MAGHREBIA VIE', openPrice: 8.210, closePrice: 8.190, changePercent: 0.24, transactions: 20, volume: 4324, capitaux: 35054),
      IndicesStockEntity(name: 'ASSUR MAGHREBIA', openPrice: 61.040, closePrice: 59.500, changePercent: 2.59, transactions: 26, volume: 7033, capitaux: 423404),
      IndicesStockEntity(name: 'ASTREE', openPrice: 45.410, closePrice: 47.540, changePercent: -4.48, transactions: 2, volume: 25, capitaux: 1135),
      IndicesStockEntity(name: 'ATELIER MEUBLE INT', openPrice: 4.820, closePrice: 4.840, changePercent: -0.41, transactions: 49, volume: 5402, capitaux: 25846),
      IndicesStockEntity(name: 'ATB', openPrice: 3.750, closePrice: 3.740, changePercent: 0.27, transactions: 99, volume: 98630, capitaux: 368971),
      IndicesStockEntity(name: 'ATL', openPrice: 8.210, closePrice: 8.200, changePercent: 0.12, transactions: 46, volume: 21256, capitaux: 174600),
      IndicesStockEntity(name: 'ATTIJARI BANK', openPrice: 74.000, closePrice: 75.000, changePercent: -1.33, transactions: 31, volume: 1387, capitaux: 102460),
      IndicesStockEntity(name: 'ATTIJARI LEASING', openPrice: 33.500, closePrice: 33.500, changePercent: 0.00, transactions: 5, volume: 210, capitaux: 7038),
      IndicesStockEntity(name: 'BEST LEASE', openPrice: 2.270, closePrice: 2.270, changePercent: 0.00, transactions: 0, volume: 0, capitaux: 0),
      IndicesStockEntity(name: 'BH LEASING', openPrice: 3.800, closePrice: 3.800, changePercent: 0.00, transactions: 0, volume: 0, capitaux: 0),
      IndicesStockEntity(name: 'AMEN BANK', openPrice: 60.700, closePrice: 61.290, changePercent: -0.96, transactions: 155, volume: 10058, capitaux: 612518),

      // ── B ──
      IndicesStockEntity(name: 'BH ASSURANCE', openPrice: null, closePrice: 65.500, changePercent: 0.00),
      IndicesStockEntity(name: 'BH BANK', openPrice: 10.190, closePrice: 10.040, changePercent: 1.49, transactions: 1, volume: 1, capitaux: 10),
      IndicesStockEntity(name: 'BIAT', openPrice: 142.300, closePrice: 145.990, changePercent: -2.53, transactions: 77, volume: 2881, capitaux: 413333),
      IndicesStockEntity(name: 'BNA', openPrice: 14.750, closePrice: 14.880, changePercent: -0.87, transactions: 103, volume: 10326, capitaux: 152620),
      IndicesStockEntity(name: 'BNA ASSURANCES', openPrice: 3.030, closePrice: 3.140, changePercent: -3.50, transactions: 41, volume: 7990, capitaux: 24309),
      IndicesStockEntity(name: 'BT', openPrice: 7.500, closePrice: 7.350, changePercent: 2.04, transactions: 155, volume: 92319, capitaux: 690428),
      IndicesStockEntity(name: 'BTE (ADP)', openPrice: 6.050, closePrice: 6.050, changePercent: 0.00, transactions: 5, volume: 181, capitaux: 1095),

      // ── C ──
      IndicesStockEntity(name: 'CARTHAGE CEMENT', openPrice: 1.980, closePrice: 1.970, changePercent: 0.51, transactions: 58, volume: 46799, capitaux: 92018),
      IndicesStockEntity(name: 'CELLCOM', openPrice: 2.530, closePrice: 2.520, changePercent: 0.40, transactions: 25, volume: 10098, capitaux: 25257),
      IndicesStockEntity(name: 'CIL', openPrice: 33.900, closePrice: 34.000, changePercent: -0.29, transactions: 35, volume: 4670, capitaux: 157840),
      IndicesStockEntity(name: 'CIMENTS DE BIZERTE', openPrice: null, closePrice: 0.470, changePercent: 0.00),
      IndicesStockEntity(name: 'CITY CARS', openPrice: 25.830, closePrice: 26.000, changePercent: -0.65, transactions: 29, volume: 2195, capitaux: 56605),

      // ── D ──
      IndicesStockEntity(name: 'DELICE HOLDING', openPrice: 15.890, closePrice: 15.800, changePercent: 0.57, transactions: 66, volume: 10635, capitaux: 168402),

      // ── E ──
      IndicesStockEntity(name: 'ENNAKL AUTOMOBILES', openPrice: 17.500, closePrice: 17.400, changePercent: 0.58, transactions: 9, volume: 1806, capitaux: 31564),
      IndicesStockEntity(name: 'ESSOUKNA', openPrice: 3.770, closePrice: 3.700, changePercent: 1.89, transactions: 10, volume: 2083, capitaux: 7727),
      IndicesStockEntity(name: 'EURO-CYCLES', openPrice: 11.760, closePrice: 11.760, changePercent: 0.00, transactions: 26, volume: 3955, capitaux: 46617),

      // ── H ──
      IndicesStockEntity(name: 'HANNIBAL LEASE', openPrice: null, closePrice: 7.250, changePercent: 0.00),

      // ── I ──
      IndicesStockEntity(name: 'ICF', openPrice: 78.500, closePrice: 78.000, changePercent: 0.64, transactions: 45, volume: 2058, capitaux: 160282),

      // ── L ──
      IndicesStockEntity(name: 'LAND OR', openPrice: 15.630, closePrice: 15.640, changePercent: -0.06, transactions: 24, volume: 1870, capitaux: 28631),

      // ── M ──
      IndicesStockEntity(name: 'MAGASIN GENERAL', openPrice: null, closePrice: 10.360, changePercent: 0.00),
      IndicesStockEntity(name: 'MONOPRIX', openPrice: null, closePrice: 6.800, changePercent: 0.00),
      IndicesStockEntity(name: 'MPBS', openPrice: 8.200, closePrice: 8.200, changePercent: 0.00, transactions: 47, volume: 11171, capitaux: 91709),

      // ── N ──
      IndicesStockEntity(name: 'NEW BODY LINE', openPrice: 3.880, closePrice: 3.960, changePercent: -2.02, transactions: 6, volume: 1395, capitaux: 5511),

      // ── O ──
      IndicesStockEntity(name: 'OFFICEPLAST', openPrice: 1.960, closePrice: 1.960, changePercent: 0.00, transactions: 19, volume: 9240, capitaux: 17586),
      IndicesStockEntity(name: 'ONE TECH HOLDING', openPrice: 8.660, closePrice: 8.690, changePercent: -0.35, transactions: 41, volume: 8578, capitaux: 74304),

      // ── P ──
      IndicesStockEntity(name: 'PLAC. TSIE-SICAF', openPrice: null, closePrice: 41.810, changePercent: 0.00),
      IndicesStockEntity(name: 'POULINA GP HOLDING', openPrice: 23.950, closePrice: 24.000, changePercent: -0.21, transactions: 99, volume: 15562, capitaux: 365178),

      // ── S ──
      IndicesStockEntity(name: 'SAH', openPrice: 14.000, closePrice: 14.060, changePercent: -0.43, transactions: 119, volume: 51417, capitaux: 719525),
      IndicesStockEntity(name: 'SFBT', openPrice: 13.140, closePrice: 13.140, changePercent: 0.00, transactions: 39, volume: 10070, capitaux: 132379),
      IndicesStockEntity(name: 'SIAME', openPrice: 3.200, closePrice: 3.140, changePercent: 1.91, transactions: 64, volume: 9113, capitaux: 29382),
      IndicesStockEntity(name: 'SIMPAR', openPrice: null, closePrice: 34.400, changePercent: 0.00),
      IndicesStockEntity(name: 'SITS', openPrice: null, closePrice: 3.880, changePercent: 0.00),
      IndicesStockEntity(name: 'SMART TUNISIE', openPrice: 20.750, closePrice: 20.600, changePercent: 0.73, transactions: 11, volume: 711, capitaux: 14772),
      IndicesStockEntity(name: 'SOTETEL', openPrice: 6.600, closePrice: 6.600, changePercent: 0.00, transactions: 31, volume: 13502, capitaux: 89827),
      IndicesStockEntity(name: 'SOTIPAPIER', openPrice: 2.640, closePrice: 2.640, changePercent: 0.00, transactions: 7, volume: 1240, capitaux: 3278),
      IndicesStockEntity(name: 'SOTRAPIL', openPrice: 26.200, closePrice: 26.000, changePercent: 0.77, transactions: 2, volume: 70, capitaux: 1834),
      IndicesStockEntity(name: 'SOTUMAG', openPrice: 9.650, closePrice: 9.750, changePercent: -1.03, transactions: 4, volume: 582, capitaux: 5616),
      IndicesStockEntity(name: 'SOTUVER', openPrice: null, closePrice: 16.840, changePercent: 0.00),
      IndicesStockEntity(name: 'SPDIT - SICAF', openPrice: 14.000, closePrice: 14.000, changePercent: 0.00, transactions: 5, volume: 903, capitaux: 12648),

      // ── S (suite) ──
      IndicesStockEntity(name: 'STA', openPrice: 58.990, closePrice: 59.980, changePercent: -1.65, transactions: 14, volume: 367, capitaux: 21876),
      IndicesStockEntity(name: 'STAR', openPrice: 63.810, closePrice: 63.500, changePercent: 0.49, transactions: 108, volume: 10433, capitaux: 665774),
      IndicesStockEntity(name: 'STB', openPrice: 4.120, closePrice: 4.240, changePercent: -2.83, transactions: 95, volume: 119264, capitaux: 489856),

      // ── T ──
      IndicesStockEntity(name: 'TELNET HOLDING', openPrice: 6.400, closePrice: 6.390, changePercent: 0.16, transactions: 16, volume: 3817, capitaux: 24389),
      IndicesStockEntity(name: 'TPR', openPrice: 13.520, closePrice: 13.600, changePercent: -0.59, transactions: 69, volume: 9583, capitaux: 129981),
      IndicesStockEntity(name: 'TUNINVEST-SICAR', openPrice: 41.450, closePrice: 41.100, changePercent: 0.85, transactions: 1, volume: 1, capitaux: 41),
      IndicesStockEntity(name: 'TUNIS RE', openPrice: 14.600, closePrice: 14.800, changePercent: -1.35, transactions: 27, volume: 6938, capitaux: 101386),
      IndicesStockEntity(name: 'TUNISIE LEASING F', openPrice: 41.300, closePrice: 41.300, changePercent: 0.00, transactions: 14, volume: 684, capitaux: 27738),

      // ── U ──
      IndicesStockEntity(name: 'UBCI', openPrice: 37.600, closePrice: 37.500, changePercent: 0.27, transactions: 3, volume: 500, capitaux: 18800),
      IndicesStockEntity(name: 'UIB', openPrice: 28.000, closePrice: 28.000, changePercent: 0.00, transactions: 4, volume: 206, capitaux: 5748),
      IndicesStockEntity(name: 'UNIMED', openPrice: 8.810, closePrice: 9.150, changePercent: -3.72, transactions: 501, volume: 218065, capitaux: 1930839),

      // ── W ──
      IndicesStockEntity(name: 'WIFACK INT BANK', openPrice: 7.650, closePrice: 7.600, changePercent: 0.66, transactions: 6, volume: 471, capitaux: 3599),
    ];
  }

  Future<List<IndicesStockEntity>> searchStocks(String query) async {
    final all = await getAllIndicesStocks();
    if (query.isEmpty) return all;
    final q = query.toUpperCase();
    return all.where((s) => s.name.toUpperCase().contains(q)).toList();
  }

  /// Retourne les noms des indices disponibles
  List<String> getAvailableIndices() => const [
    'TUNINDEX',
    'TUNINDEX20',
    'INDICE AGRO ALIMENTAIRE ET BOISSONS',
    'INDICE DE BATIMENT ET MATERIAUX DE CONSTRUCTION',
    'INDICE DE DISTRIBUTION',
    'INDICE DES ASSURANCES',
    'INDICE DES BANQUES',
    'INDICE DES BIENS DE CONSOMMATION',
    'INDICE DES INDUSTRIES',
    'INDICE DES MATERIAUX DE BASE',
    'INDICE DES PRODUITS MENAGERS ET DE SOIN PERSONNEL',
    'INDICE DES SERVICES AUX CONSOMMATEURS',
    'INDICE DES SERVICES FINANCIERS',
    'INDICE DES STE FINANCIERES',
  ];

  /// Retourne le résumé d'un indice donné
  Future<IndexSummaryEntity> getIndexSummary(String indexName) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Données réalistes pour chaque indice
    const data = <String, List<double>>{
      'TUNINDEX': [10066.69, 10068.97, -0.21, 10070.98, 10065.46, 7.76],
      'TUNINDEX20': [4580.23, 4592.45, -0.27, 4598.10, 4575.88, 6.42],
      'INDICE AGRO ALIMENTAIRE ET BOISSONS': [6823.54, 6810.30, 0.19, 6835.00, 6798.20, 4.65],
      'INDICE DE BATIMENT ET MATERIAUX DE CONSTRUCTION': [412.67, 415.20, -0.61, 416.00, 411.50, -2.30],
      'INDICE DE DISTRIBUTION': [3215.80, 3220.10, -0.13, 3228.00, 3210.44, 3.10],
      'INDICE DES ASSURANCES': [2980.45, 2965.30, 0.51, 2988.00, 2960.12, 5.23],
      'INDICE DES BANQUES': [5431.20, 5445.80, -0.27, 5450.00, 5420.30, 8.15],
      'INDICE DES BIENS DE CONSOMMATION': [1875.60, 1870.90, 0.25, 1880.00, 1868.40, 2.78],
      'INDICE DES INDUSTRIES': [2340.15, 2348.70, -0.36, 2352.00, 2335.88, 1.92],
      'INDICE DES MATERIAUX DE BASE': [1520.33, 1525.00, -0.31, 1528.50, 1518.00, -1.15],
      'INDICE DES PRODUITS MENAGERS ET DE SOIN PERSONNEL': [4100.90, 4088.50, 0.30, 4112.00, 4085.20, 6.80],
      'INDICE DES SERVICES AUX CONSOMMATEURS': [780.45, 783.20, -0.35, 785.00, 778.90, -0.55],
      'INDICE DES SERVICES FINANCIERS': [1950.28, 1942.60, 0.40, 1955.00, 1940.10, 4.10],
      'INDICE DES STE FINANCIERES': [3645.70, 3658.40, -0.35, 3662.00, 3640.20, 5.48],
    };
    final d = data[indexName] ?? data['TUNINDEX']!;
    return IndexSummaryEntity(
      name: indexName,
      value: d[0],
      previousClose: d[1],
      changePercent: d[2],
      high: d[3],
      low: d[4],
      yearChangePercent: d[5],
    );
  }

  /// Retourne les données intraday du graphique pour un indice
  Future<List<IndexChartPoint>> getIndexChartData(String indexName) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final rng = math.Random(indexName.hashCode);

    // Générer des points réalistes entre 09:00 et 13:45
    final bases = <String, double>{
      'TUNINDEX': 10060.0, 'TUNINDEX20': 4580.0,
      'INDICE AGRO ALIMENTAIRE ET BOISSONS': 6820.0,
      'INDICE DE BATIMENT ET MATERIAUX DE CONSTRUCTION': 412.0,
      'INDICE DE DISTRIBUTION': 3215.0,
      'INDICE DES ASSURANCES': 2980.0,
      'INDICE DES BANQUES': 5430.0,
      'INDICE DES BIENS DE CONSOMMATION': 1875.0,
      'INDICE DES INDUSTRIES': 2340.0,
      'INDICE DES MATERIAUX DE BASE': 1520.0,
      'INDICE DES PRODUITS MENAGERS ET DE SOIN PERSONNEL': 4100.0,
      'INDICE DES SERVICES AUX CONSOMMATEURS': 780.0,
      'INDICE DES SERVICES FINANCIERS': 1950.0,
      'INDICE DES STE FINANCIERES': 3645.0,
    };
    final baseValue = bases[indexName] ?? 8350.0;
    final points = <IndexChartPoint>[];

    double current = baseValue;
    for (double m = 0; m <= 285; m += 3) {
      // 285 minutes = 09:00 à 13:45
      final drift = (rng.nextDouble() - 0.48) * 4;
      current += drift;
      // Clamp to realistic range
      current = current.clamp(baseValue - 30, baseValue + 25);
      points.add(IndexChartPoint(minutesSince9: m, value: current));
    }
    return points; 
    
  }

  /// Mapping des actions par indice sectoriel
  static const _indexComposition = <String, List<String>>{
    'INDICE AGRO ALIMENTAIRE ET BOISSONS': [
      'DELICE HOLDING', 'LAND OR', 'POULINA GP HOLDING', 'SFBT',
    ],
    'INDICE DE BATIMENT ET MATERIAUX DE CONSTRUCTION': [
      'CARTHAGE CEMENT', 'CIMENTS DE BIZERTE', 'ESSOUKNA', 'MPBS', 'SIMPAR', 'SITS',
    ],
    'INDICE DE DISTRIBUTION': [
      'ARTES', 'CELLCOM', 'CITY CARS', 'ENNAKL AUTOMOBILES', 'MAGASIN GENERAL', 'MONOPRIX', 'SMART TUNISIE', 'SOTUMAG', 'STA',
    ],
    'INDICE DES ASSURANCES': [
      'ASSU MAGHREBIA VIE', 'ASSUR MAGHREBIA', 'ASTREE', 'BH ASSURANCE', 'BNA ASSURANCES', 'STAR', 'TUNIS RE',
    ],
    'INDICE DES BANQUES': [
      'AMEN BANK', 'ATB', 'ATTIJARI BANK', 'BH BANK', 'BIAT', 'BNA', 'BT', 'BTE (ADP)', 'STB', 'UBCI', 'UIB', 'WIFACK INT BANK',
    ],
    'INDICE DES BIENS DE CONSOMMATION': [
      'ATELIER MEUBLE INT', 'DELICE HOLDING', 'EURO-CYCLES', 'LAND OR', 'NEW BODY LINE', 'OFFICEPLAST', 'POULINA GP HOLDING', 'SAH', 'SFBT',
    ],
    'INDICE DES INDUSTRIES': [
      'CARTHAGE CEMENT', 'CIMENTS DE BIZERTE', 'ESSOUKNA', 'MPBS', 'ONE TECH HOLDING', 'SIAME', 'SIMPAR', 'SITS', 'SOTUVER',
    ],
    'INDICE DES MATERIAUX DE BASE': [
      'ICF', 'SOTIPAPIER', 'TPR',
    ],
    'INDICE DES PRODUITS MENAGERS ET DE SOIN PERSONNEL': [
      'ATELIER MEUBLE INT', 'EURO-CYCLES', 'NEW BODY LINE', 'OFFICEPLAST', 'SAH',
    ],
    'INDICE DES SERVICES AUX CONSOMMATEURS': [
      'ARTES', 'CELLCOM', 'CITY CARS', 'ENNAKL AUTOMOBILES', 'MAGASIN GENERAL', 'MONOPRIX', 'SMART TUNISIE', 'SOTUMAG', 'STA',
    ],
    'INDICE DES SERVICES FINANCIERS': [
      'ATL', 'ATTIJARI LEASING', 'BEST LEASE', 'BH LEASING', 'CIL', 'HANNIBAL LEASE', 'PLAC. TSIE-SICAF', 'SPDIT - SICAF', 'TUNINVEST-SICAR', 'TUNISIE LEASING F',
    ],
    'INDICE DES STE FINANCIERES': [
      'AMEN BANK', 'ASSU MAGHREBIA VIE', 'ASSUR MAGHREBIA', 'ASTREE', 'ATB', 'ATL', 'ATTIJARI BANK', 'ATTIJARI LEASING',
      'BEST LEASE', 'BH ASSURANCE', 'BH BANK', 'BH LEASING', 'BIAT', 'BNA', 'BNA ASSURANCES',
      'BT', 'BTE (ADP)', 'CIL', 'HANNIBAL LEASE', 'PLAC. TSIE-SICAF', 'SPDIT - SICAF',
      'STAR', 'STB', 'TUNINVEST-SICAR', 'TUNIS RE', 'TUNISIE LEASING F', 'UBCI', 'UIB', 'WIFACK INT BANK',
    ],
    'TUNINDEX20': [
      'AMEN BANK', 'ATB', 'ATTIJARI BANK', 'BIAT', 'BNA', 'BT', 'CARTHAGE CEMENT', 'DELICE HOLDING',
      'EURO-CYCLES', 'MPBS', 'ONE TECH HOLDING', 'POULINA GP HOLDING', 'SAH', 'SFBT', 'SOTUVER',
      'STB', 'TPR', 'TUNISIE LEASING F', 'UIB', 'UNIMED',
    ],
  };

  /// Retourne la composition (actions) d'un indice donné
  Future<List<IndicesStockEntity>> getIndexComposition(String indexName) async {
    final all = await getAllIndicesStocks();
    // TUNINDEX affiche toutes les actions
    if (indexName == 'TUNINDEX') return all;
    // Indices sectoriels : filtrer par composition
    final names = _indexComposition[indexName];
    if (names == null) return all;
    return all.where((s) => names.contains(s.name)).toList();
  }
}
