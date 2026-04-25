import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

// Core Services
import '../services/local_storage_service.dart';

// Home
import '../../features/home/data/datasources/home_mock_datasource.dart';
import '../../features/home/data/datasources/market_summary_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/home_usecases.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

// Home — Market Summary (nouvelle page d'accueil)
import '../../features/home/data/datasources/market_summary_mock_datasource.dart';
import '../../features/home/data/repositories/market_summary_repository_impl.dart';
import '../../features/home/domain/repositories/market_summary_repository.dart';
import '../../features/home/domain/usecases/market_summary_usecases.dart';
import '../../features/home/presentation/bloc/market_summary_bloc.dart';

// Home — Index Chart (popup courbe intraday)
import '../../features/home/presentation/bloc/index_chart_bloc.dart';

// Market
import '../../features/market/data/datasources/market_mock_datasource.dart';
import '../../features/market/data/datasources/market_remote_datasource.dart';
import '../../features/market/data/repositories/market_repository_impl.dart';
import '../../features/market/domain/repositories/market_repository.dart';
import '../../features/market/domain/usecases/market_usecases.dart';
import '../../features/market/presentation/bloc/market_bloc.dart';

// Portfolio
import '../../features/portfolio/data/datasources/portfolio_mock_datasource.dart';
import '../../features/portfolio/data/repositories/portfolio_repository_impl.dart';
import '../../features/portfolio/domain/repositories/portfolio_repository.dart';
import '../../features/portfolio/domain/usecases/portfolio_usecases.dart';
import '../../features/portfolio/presentation/bloc/portfolio_bloc.dart';

// Stock Detail
import '../../features/stock_detail/presentation/bloc/stock_detail_bloc.dart';

// Auth
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// News
import '../../features/news/data/datasources/news_mock_datasource.dart';
import '../../features/news/data/datasources/news_remote_datasource.dart';
import '../../features/news/presentation/bloc/news_bloc.dart';
import 'package:dio/dio.dart';

// Notifications
import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';

// Market Watch
import '../../features/market_watch/data/datasources/market_watch_mock_datasource.dart';
import '../../features/market_watch/data/datasources/market_watch_remote_datasource.dart';
import '../../features/market_watch/data/repositories/market_watch_repository_impl.dart';
import '../../features/market_watch/domain/repositories/market_watch_repository.dart';
import '../../features/market_watch/domain/usecases/market_watch_usecases.dart';
import '../../features/market_watch/presentation/bloc/market_watch_bloc.dart';

// Market Watch — Instruments
import '../../features/market_watch/data/datasources/instrument_mock_datasource.dart';
import '../../features/market_watch/data/datasources/instrument_remote_datasource.dart';
import '../../features/market_watch/data/repositories/instrument_repository_impl.dart';
import '../../features/market_watch/domain/repositories/instrument_repository.dart';
import '../../features/market_watch/domain/usecases/instrument_usecases.dart';
import '../../features/market_watch/presentation/bloc/instrument_bloc.dart';

// Market Watch — Historique
import '../../features/market_watch/data/datasources/historique_mock_datasource.dart';
import '../../features/market_watch/data/repositories/historique_repository_impl.dart';
import '../../features/market_watch/domain/repositories/historique_repository.dart';
import '../../features/market_watch/domain/usecases/historique_usecases.dart';
import '../../features/market_watch/presentation/bloc/historique_bloc.dart';

// Indices
import '../../features/indices/data/datasources/indices_mock_datasource.dart';
import '../../features/indices/data/datasources/indices_remote_datasource.dart';
import '../../features/indices/data/repositories/indices_repository_impl.dart';
import '../../features/indices/domain/repositories/indices_repository.dart';
import '../../features/indices/domain/usecases/indices_usecases.dart';
import '../../features/indices/presentation/bloc/indices_bloc.dart';

final sl = GetIt.instance;

/// Initialise toutes les dépendances de l'application
Future<void> initDependencies() async {
  // Évite les erreurs de double-registration lors du hot restart
  if (sl.isRegistered<LocalStorageService>()) return;

  // ═══════════════════════════════════════════
  // ── CORE SERVICES ──
  // ═══════════════════════════════════════════
  final localStorage = LocalStorageService();
  await localStorage.init();
  sl.registerSingleton<LocalStorageService>(localStorage);

  // ═══════════════════════════════════════════
  // ── HOME ──
  // ═══════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton(() => HomeMockDataSource());

  // Repositories
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(dataSource: sl()),
  );

  // Use Cases
  sl.registerFactory(() => GetPortfolioSummary(sl()));
  sl.registerFactory(() => GetFavoriteStocks(sl()));
  sl.registerFactory(() => GetTopMovers(sl()));
  sl.registerFactory(() => GetTickerData(sl()));
  sl.registerFactory(() => CheckMarketStatus(sl()));

  // BLoC
  sl.registerFactory(() => HomeBloc(
        getPortfolioSummary: sl(),
        getFavoriteStocks: sl(),
        getTopMovers: sl(),
        getTickerData: sl(),
        checkMarketStatus: sl(),
      ));

  // ═══════════════════════════════════════════
  // ── HOME — MARKET SUMMARY (nouvelle page d'accueil) ──
  // ═══════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<MarketSummaryMockDataSource>(() => MarketSummaryRemoteDataSource(dio: sl<Dio>()));

  // Repositories
  sl.registerLazySingleton<MarketSummaryRepository>(
    () => MarketSummaryRepositoryImpl(dataSource: sl()),
  );

  // Use Cases
  sl.registerFactory(() => GetMarketSummary(sl()));
  sl.registerFactory(() => GetTunindexIntraday(sl()));
  sl.registerFactory(() => GetTunindex20Intraday(sl()));
  sl.registerFactory(() => GetTopCapitaux(sl()));
  sl.registerFactory(() => GetTopQuantite(sl()));
  sl.registerFactory(() => GetTopTransactions(sl()));
  sl.registerFactory(() => GetTopHausses(sl()));
  sl.registerFactory(() => GetTopBaisses(sl()));

  // BLoC
  sl.registerFactory(() => MarketSummaryBloc(
        getMarketSummary: sl(),
        getTunindexIntraday: sl(),
        getTunindex20Intraday: sl(),
        getTopCapitaux: sl(),
        getTopQuantite: sl(),
        getTopTransactions: sl(),
        getTopHausses: sl(),
        getTopBaisses: sl(),
        newsDataSource: sl<NewsRemoteDataSource>(),
      ));

  // BLoC — Index Chart (popup courbe intraday + cache GetStorage)
  sl.registerFactory(() => IndexChartBloc(
        getTunindexIntraday: sl(),
        getTunindex20Intraday: sl(),
        localStorage: sl<LocalStorageService>(),
      ));

  // ═══════════════════════════════════════════
  // ── MARKET ──
  // ═══════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<MarketMockDataSource>(() => MarketRemoteDataSource(dio: sl<Dio>()));

  // Repositories
  sl.registerLazySingleton<MarketRepository>(
    () => MarketRepositoryImpl(dataSource: sl()),
  );

  // Use Cases
  sl.registerFactory(() => GetAllStocks(sl()));
  sl.registerFactory(() => SearchStocks(sl()));
  sl.registerFactory(() => GetMarketIndices(sl()));
  sl.registerFactory(() => GetTopGainers(sl()));
  sl.registerFactory(() => GetTopLosers(sl()));
  sl.registerFactory(() => GetMostActive(sl()));

  // BLoC
  sl.registerFactory(() => MarketBloc(
        getAllStocks: sl(),
        getMarketIndices: sl(),
        searchStocks: sl(),
        getTopGainers: sl(),
        getTopLosers: sl(),
        getMostActive: sl(),
      ));

  // ═══════════════════════════════════════════
  // ── PORTFOLIO ──
  // ═══════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton(() => PortfolioMockDataSource());

  // Repositories
  sl.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(dataSource: sl()),
  );

  // Use Cases
  sl.registerFactory(() => GetPortfolioDetail(sl()));
  sl.registerFactory(() => GetPositions(sl()));
  sl.registerFactory(() => GetTransactions(sl()));

  // BLoC
  sl.registerFactory(() => PortfolioBloc(
        getPortfolioDetail: sl(),
        getPositions: sl(),
        getTransactions: sl(),
      ));

  // ═══════════════════════════════════════════
  // ── STOCK DETAIL ──
  // ═══════════════════════════════════════════

  sl.registerFactory(() => StockDetailBloc(dataSource: sl<MarketMockDataSource>()));

  // ═══════════════════════════════════════════
  // ── AUTH ──
  // ═══════════════════════════════════════════

  sl.registerFactory(() => AuthBloc());

  // ═══════════════════════════════════════════
  // ── NEWS ──
  // ═══════════════════════════════════════════

  // Dio pour le backend BVMT
  // adb reverse tcp:3000 tcp:3000 redirige localhost:3000 du téléphone vers le PC
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
    dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      responseHeader: false,
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => debugPrint('[DIO] $obj'),
    ));
    return dio;
  });

  // Mock DataSource (gardé pour compatibilité MarketSummaryBloc)
  sl.registerLazySingleton(() => NewsMockDataSource());

  // Remote DataSource (données réelles BVMT)
  sl.registerLazySingleton(() => NewsRemoteDataSource(dio: sl<Dio>()));

  // BLoC — utilise le remote datasource
  sl.registerFactory(() => NewsBloc(dataSource: sl<NewsRemoteDataSource>()));

  // ═══════════════════════════════════════════
  // ── MARKET WATCH ──
  // ═══════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<MarketWatchMockDataSource>(() => MarketWatchRemoteDataSource(dio: sl<Dio>()));

  // Repositories
  sl.registerLazySingleton<MarketWatchRepository>(
    () => MarketWatchRepositoryImpl(dataSource: sl()),
  );

  // Use Cases
  sl.registerFactory(() => GetMarketWatchSummary(sl()));
  sl.registerFactory(() => GetMWTunindexIntraday(sl()));
  sl.registerFactory(() => GetMWTunindex20Intraday(sl()));
  sl.registerFactory(() => GetMWTopHausses(sl()));
  sl.registerFactory(() => GetMWTopBaisses(sl()));
  sl.registerFactory(() => GetMWTopCapitaux(sl()));
  sl.registerFactory(() => GetMWTopQuantite(sl()));
  sl.registerFactory(() => GetMWTopTransactions(sl()));

  // BLoC
  sl.registerFactory(() => MarketWatchBloc(
        getMarketWatchSummary: sl(),
        getMWTunindexIntraday: sl(),
        getMWTunindex20Intraday: sl(),
        getMWTopHausses: sl(),
        getMWTopBaisses: sl(),
        getMWTopCapitaux: sl(),
        getMWTopQuantite: sl(),
        getMWTopTransactions: sl(),
      ));

  // ═══════════════════════════════════════════
  // ── MARKET WATCH — INSTRUMENTS ──
  // ═══════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<InstrumentMockDataSource>(() => InstrumentRemoteDataSource(dio: sl<Dio>()));

  // Repositories
  sl.registerLazySingleton<InstrumentRepository>(
    () => InstrumentRepositoryImpl(dataSource: sl()),
  );

  // Use Cases
  sl.registerFactory(() => GetInstrumentsByMarket(sl()));
  sl.registerFactory(() => SearchInstruments(sl()));

  // BLoC
  sl.registerFactory(() => InstrumentBloc(
        getInstrumentsByMarket: sl(),
        searchInstruments: sl(),
        localStorage: sl<LocalStorageService>(),
      ));

  // ═══════════════════════════════════════════
  // ── MARKET WATCH — HISTORIQUE ──
  // ═══════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton(() => HistoriqueMockDataSource());

  // Repositories
  sl.registerLazySingleton<HistoriqueRepository>(
    () => HistoriqueRepositoryImpl(dataSource: sl()),
  );

  // Use Cases
  sl.registerFactory(() => GetHistoriqueSessions(sl()));
  sl.registerFactory(() => GetHistoriqueChartData(sl()));
  sl.registerFactory(() => GetSectorBreakdown(sl()));

  // BLoC
  sl.registerFactory(() => HistoriqueBloc(
        getHistoriqueSessions: sl(),
        getHistoriqueChartData: sl(),
        getSectorBreakdown: sl(),
      ));

  // ═══════════════════════════════════════════
  // ── INDICES ──
  // ═══════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<IndicesMockDataSource>(() => IndicesRemoteDataSource(dio: sl<Dio>()));

  // Repositories
  sl.registerLazySingleton<IndicesRepository>(
    () => IndicesRepositoryImpl(dataSource: sl()),
  );

  // Use Cases
  sl.registerFactory(() => GetAllIndicesStocks(sl()));
  sl.registerFactory(() => SearchIndicesStocks(sl()));

  // BLoC
  sl.registerFactory(() => IndicesBloc(
        getAllIndicesStocks: sl(),
        searchIndicesStocks: sl(),
        localStorage: sl<LocalStorageService>(),
        dataSource: sl(),
      ));

  // ═══════════════════════════════════════════
  // ── NOTIFICATIONS ──
  // ═══════════════════════════════════════════

  sl.registerLazySingleton(
      () => NotificationsRemoteDataSource(dio: sl<Dio>()));

  sl.registerFactory(
      () => NotificationsBloc(dataSource: sl<NotificationsRemoteDataSource>()));
}
