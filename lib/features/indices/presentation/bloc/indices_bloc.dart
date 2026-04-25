import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../data/datasources/indices_mock_datasource.dart';
import '../../domain/entities/indices_stock_entity.dart';
import '../../domain/usecases/indices_usecases.dart';
import 'indices_event.dart';
import 'indices_state.dart';

/// BLoC Indices — gère la logique métier du tableau des indices BVMT
///
/// Cycle complet (comme IndexChartBloc) :
/// 1. Lecture du cache GetStorage (affichage immédiat si disponible)
/// 2. Fetch des données fraîches via Use Cases
/// 3. Mise à jour du cache GetStorage
class IndicesBloc extends Bloc<IndicesEvent, IndicesState> {
  final GetAllIndicesStocks getAllIndicesStocks;
  final SearchIndicesStocks searchIndicesStocks;
  final LocalStorageService localStorage;
  final IndicesMockDataSource _dataSource;

  Timer? _autoRefreshTimer;

  IndicesBloc({
    required this.getAllIndicesStocks,
    required this.searchIndicesStocks,
    required this.localStorage,
    required IndicesMockDataSource dataSource,
  })  : _dataSource = dataSource,
        super(const IndicesInitial()) {
    on<IndicesLoadRequested>(_onLoadRequested);
    on<IndicesRefreshRequested>(_onRefreshRequested);
    on<IndicesAutoRefreshTick>((event, emit) => _loadData(emit));
    on<IndicesSearchChanged>(_onSearchChanged);
    on<IndicesSortRequested>(_onSortRequested);
    on<IndicesIndexChanged>(_onIndexChanged);
    on<IndicesChartPeriodChanged>(_onChartPeriodChanged);
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(const IndicesAutoRefreshTick()),
    );
  }

  Future<void> _onLoadRequested(
    IndicesLoadRequested event,
    Emitter<IndicesState> emit,
  ) async {
    // ── 1. Vérifier le cache GetStorage ──
    final cached = _readCache();
    if (cached != null && cached.isNotEmpty) {
      final stats = _computeStats(cached);
      emit(IndicesLoaded(
        allStocks: cached,
        displayedStocks: cached,
        totalHausses: stats['hausses']!,
        totalBaisses: stats['baisses']!,
        totalInchangees: stats['inchangees']!,
        totalTransactions: stats['transactions']!,
        totalVolume: stats['volume']!,
        totalCapitaux: stats['capitaux']!,
      ));
    } else {
      emit(const IndicesLoading());
    }

    // ── 2. Fetch des données fraîches via Use Case ──
    await _loadData(emit);
    _startAutoRefresh();
  }

  Future<void> _onRefreshRequested(
    IndicesRefreshRequested event,
    Emitter<IndicesState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<IndicesState> emit) async {
    try {
      final selectedIdx = state is IndicesLoaded
          ? (state as IndicesLoaded).selectedIndex
          : 'TUNINDEX';

      final stocks = await getAllIndicesStocks();
      final summary = await _dataSource.getIndexSummary(selectedIdx);
      final chartPoints = await _dataSource.getIndexChartData(selectedIdx);

      // ── 3. Sauvegarder en cache GetStorage ──
      _writeCache(stocks);
      final stats = _computeStats(stocks);
      emit(IndicesLoaded(
        allStocks: stocks,
        displayedStocks: stocks,
        totalHausses: stats['hausses']!,
        totalBaisses: stats['baisses']!,
        totalInchangees: stats['inchangees']!,
        totalTransactions: stats['transactions']!,
        totalVolume: stats['volume']!,
        totalCapitaux: stats['capitaux']!,
        selectedIndex: selectedIdx,
        availableIndices: _dataSource.getAvailableIndices(),
        indexSummary: summary,
        chartPoints: chartPoints,
      ));
    } catch (e) {
      emit(IndicesError('Erreur lors du chargement: $e'));
    }
  }

  void _onSearchChanged(
    IndicesSearchChanged event,
    Emitter<IndicesState> emit,
  ) {
    if (state is! IndicesLoaded) return;
    final current = state as IndicesLoaded;
    final query = event.query.toUpperCase();

    final filtered = query.isEmpty
        ? current.allStocks
        : current.allStocks
            .where((s) => s.name.toUpperCase().contains(query))
            .toList();

    emit(current.copyWith(
      displayedStocks: _applySorting(filtered, current.sortColumn, current.sortAscending),
      searchQuery: event.query,
    ));
  }

  void _onSortRequested(
    IndicesSortRequested event,
    Emitter<IndicesState> emit,
  ) {
    if (state is! IndicesLoaded) return;
    final current = state as IndicesLoaded;

    // Toggle direction if same column
    final ascending = current.sortColumn == event.column
        ? !current.sortAscending
        : true;

    final sorted = _applySorting(current.displayedStocks, event.column, ascending);

    emit(current.copyWith(
      displayedStocks: sorted,
      sortColumn: event.column,
      sortAscending: ascending,
    ));
  }

  Future<void> _onIndexChanged(
    IndicesIndexChanged event,
    Emitter<IndicesState> emit,
  ) async {
    if (state is! IndicesLoaded) return;
    final current = state as IndicesLoaded;

    try {
      final summary = await _dataSource.getIndexSummary(event.indexName);
      final chartPoints = await _dataSource.getIndexChartData(event.indexName);
      final stocks = await _dataSource.getIndexComposition(event.indexName);
      final stats = _computeStats(stocks);

      emit(current.copyWith(
        selectedIndex: event.indexName,
        indexSummary: summary,
        chartPoints: chartPoints,
        allStocks: stocks,
        displayedStocks: stocks,
        totalHausses: stats['hausses'],
        totalBaisses: stats['baisses'],
        totalInchangees: stats['inchangees'],
        totalTransactions: stats['transactions'],
        totalVolume: stats['volume'],
        totalCapitaux: stats['capitaux'],
      ));
    } catch (e) {
      emit(IndicesError('Erreur: $e'));
    }
  }

  void _onChartPeriodChanged(
    IndicesChartPeriodChanged event,
    Emitter<IndicesState> emit,
  ) {
    if (state is! IndicesLoaded) return;
    final current = state as IndicesLoaded;
    emit(current.copyWith(chartPeriod: event.period));
  }

  List<IndicesStockEntity> _applySorting(
    List<IndicesStockEntity> stocks,
    IndicesSortColumn column,
    bool ascending,
  ) {
    final sorted = List<IndicesStockEntity>.from(stocks);
    sorted.sort((a, b) {
      int result;
      switch (column) {
        case IndicesSortColumn.name:
          result = a.name.compareTo(b.name);
          break;
        case IndicesSortColumn.openPrice:
          result = (a.openPrice ?? 0).compareTo(b.openPrice ?? 0);
          break;
        case IndicesSortColumn.closePrice:
          result = a.closePrice.compareTo(b.closePrice);
          break;
        case IndicesSortColumn.changePercent:
          result = a.changePercent.compareTo(b.changePercent);
          break;
        case IndicesSortColumn.transactions:
          result = (a.transactions ?? 0).compareTo(b.transactions ?? 0);
          break;
        case IndicesSortColumn.volume:
          result = (a.volume ?? 0).compareTo(b.volume ?? 0);
          break;
        case IndicesSortColumn.capitaux:
          result = (a.capitaux ?? 0).compareTo(b.capitaux ?? 0);
          break;
      }
      return ascending ? result : -result;
    });
    return sorted;
  }

  Map<String, int> _computeStats(List<IndicesStockEntity> stocks) {
    int hausses = 0;
    int baisses = 0;
    int inchangees = 0;
    int totalTx = 0;
    int totalVol = 0;
    int totalCap = 0;

    for (final s in stocks) {
      if (s.isPositive) {
        hausses++;
      } else if (s.isNegative) {
        baisses++;
      } else {
        inchangees++;
      }
      totalTx += s.transactions ?? 0;
      totalVol += s.volume ?? 0;
      totalCap += s.capitaux ?? 0;
    }

    return {
      'hausses': hausses,
      'baisses': baisses,
      'inchangees': inchangees,
      'transactions': totalTx,
      'volume': totalVol,
      'capitaux': totalCap,
    };
  }

  // ═══════════════════════════════════════════
  // ── CACHE GetStorage ──
  // ═══════════════════════════════════════════

  static const _cacheKey = 'indices_stocks_data';
  static const _cacheTimestampKey = 'indices_stocks_ts';
  static const _cacheDuration = Duration(minutes: 30);

  /// Écrit la liste des stocks en cache via GetStorage
  void _writeCache(List<IndicesStockEntity> stocks) {
    final jsonList = stocks.map((s) => {
      'name': s.name,
      'openPrice': s.openPrice,
      'closePrice': s.closePrice,
      'changePercent': s.changePercent,
      'transactions': s.transactions,
      'volume': s.volume,
      'capitaux': s.capitaux,
    }).toList();
    localStorage.writeRaw(_cacheKey, jsonEncode(jsonList));
    localStorage.writeRaw(
      _cacheTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Lit les stocks depuis le cache GetStorage (null si expiré ou absent)
  List<IndicesStockEntity>? _readCache() {
    final raw = localStorage.readRaw<String>(_cacheKey);
    final ts = localStorage.readRaw<int>(_cacheTimestampKey);

    if (raw == null || ts == null) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(ts);
    if (DateTime.now().difference(cachedAt) > _cacheDuration) {
      localStorage.removeRaw(_cacheKey);
      localStorage.removeRaw(_cacheTimestampKey);
      return null;
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => IndicesStockEntity(
        name: item['name'] as String,
        openPrice: item['openPrice'] != null
            ? (item['openPrice'] as num).toDouble()
            : null,
        closePrice: (item['closePrice'] as num).toDouble(),
        changePercent: (item['changePercent'] as num).toDouble(),
        transactions: item['transactions'] as int?,
        volume: item['volume'] as int?,
        capitaux: item['capitaux'] as int?,
      )).toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    return super.close();
  }
}
