import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../news/data/datasources/news_remote_datasource.dart';
import '../../domain/usecases/market_summary_usecases.dart';
import 'market_summary_event.dart';
import 'market_summary_state.dart';

/// BLoC — Résumé du marché (page d'accueil BVMT)
class MarketSummaryBloc
    extends Bloc<MarketSummaryEvent, MarketSummaryState> {
  final GetMarketSummary getMarketSummary;
  final GetTunindexIntraday getTunindexIntraday;
  final GetTunindex20Intraday getTunindex20Intraday;
  final GetTopCapitaux getTopCapitaux;
  final GetTopQuantite getTopQuantite;
  final GetTopTransactions getTopTransactions;
  final GetTopHausses getTopHausses;
  final GetTopBaisses getTopBaisses;
  final NewsRemoteDataSource newsDataSource;

  Timer? _autoRefreshTimer;

  MarketSummaryBloc({
    required this.getMarketSummary,
    required this.getTunindexIntraday,
    required this.getTunindex20Intraday,
    required this.getTopCapitaux,
    required this.getTopQuantite,
    required this.getTopTransactions,
    required this.getTopHausses,
    required this.getTopBaisses,
    required this.newsDataSource,
  }) : super(const MarketSummaryInitial()) {
    on<MarketSummaryLoadRequested>(_onLoadRequested);
    on<MarketSummaryRefreshRequested>(_onRefreshRequested);
    on<MarketSummaryAutoRefreshTick>((event, emit) => _loadData(emit));
    on<MarketSummaryPageChanged>(_onPageChanged);
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(const MarketSummaryAutoRefreshTick()),
    );
  }

  Future<void> _onLoadRequested(
    MarketSummaryLoadRequested event,
    Emitter<MarketSummaryState> emit,
  ) async {
    emit(const MarketSummaryLoading());
    await _loadData(emit);
    _startAutoRefresh();
  }

  Future<void> _onRefreshRequested(
    MarketSummaryRefreshRequested event,
    Emitter<MarketSummaryState> emit,
  ) async {
    await _loadData(emit);
  }

  void _onPageChanged(
    MarketSummaryPageChanged event,
    Emitter<MarketSummaryState> emit,
  ) {
    if (state is MarketSummaryLoaded) {
      emit((state as MarketSummaryLoaded).copyWith(currentPage: event.page));
    }
  }

  Future<void> _loadData(Emitter<MarketSummaryState> emit) async {
    try {
      final results = await Future.wait([
        getMarketSummary(),         // 0
        getTunindexIntraday(),      // 1
        getTunindex20Intraday(),    // 2
        getTopCapitaux(),           // 3
        getTopQuantite(),           // 4
        getTopTransactions(),       // 5
        getTopHausses(),            // 6
        getTopBaisses(),            // 7
      ]);

      final latestNews = await newsDataSource.getAllNews(limit: 5);

      emit(MarketSummaryLoaded(
        summary: results[0] as dynamic,
        tunindexIntraday: results[1] as dynamic,
        tunindex20Intraday: results[2] as dynamic,
        topCapitaux: results[3] as dynamic,
        topQuantite: results[4] as dynamic,
        topTransactions: results[5] as dynamic,
        topHausses: results[6] as dynamic,
        topBaisses: results[7] as dynamic,
        latestNews: latestNews,
      ));
    } catch (e) {
      emit(MarketSummaryError(
        'Impossible de charger le résumé du marché: ${e.toString()}',
      ));
    }
  }

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    return super.close();
  }
}
