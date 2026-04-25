import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_event.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page_new.dart' as new_home;
import '../../features/market/presentation/pages/market_page.dart';
import '../../features/more/presentation/pages/more_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/portfolio/presentation/pages/portfolio_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/stock_detail/presentation/bloc/stock_detail_bloc.dart';
import '../../features/stock_detail/presentation/bloc/stock_detail_event.dart';
import '../../features/stock_detail/presentation/pages/stock_detail_page.dart';
import '../../features/market_watch/presentation/bloc/market_watch_bloc.dart';
import '../../features/market_watch/presentation/bloc/market_watch_event.dart';
import '../../features/market_watch/presentation/pages/market_watch_page.dart';
import '../../features/news/presentation/bloc/news_bloc.dart';
import '../../features/news/presentation/bloc/news_event.dart';
import '../../features/news/presentation/pages/news_page.dart';
import '../di/injection.dart';
import '../navigation/main_shell.dart';
import '../services/local_storage_service.dart';
import 'page_transitions.dart';

/// Configuration du routeur GoRouter
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // ── Splash ──
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashPage(
          onComplete: () {
            // TODO: Remettre la logique originale après test
            // final storage = sl<LocalStorageService>();
            // if (storage.isLoggedIn) {
            //   context.go('/home');
            // } else if (storage.hasSeenOnboarding) {
            //   context.go('/login');
            // } else {
            //   context.go('/onboarding');
            // }
            context.go('/onboarding'); // Force onboarding pour test
          },
        ),
      ),

      // ── Onboarding ──
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingPage(
          onComplete: () {
            sl<LocalStorageService>().setOnboardingSeen();
            context.go('/login');
          },
        ),
      ),

      // ── Auth ──
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => FadeScaleTransition(
          child: LoginPage(
            onRegisterTap: () => context.go('/register'),
            onForgotPasswordTap: () => context.go('/forgot-password'),
            onLoginSuccess: () => context.go('/home'),
          ),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => FadeScaleTransition(
          child: ForgotPasswordPage(
            onBackToLogin: () => context.go('/login'),
          ),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => FadeScaleTransition(
          child: RegisterPage(
            onLoginTap: () => context.go('/login'),
            onRegisterSuccess: () => context.go('/home'),
          ),
        ),
      ),

      // ── Actualités (plein écran) ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/news',
        pageBuilder: (context, state) => SlideUpTransition(
          child: BlocProvider(
            create: (_) => sl<NewsBloc>()
              ..add(const NewsLoadRequested()),
            child: const NewsPage(),
          ),
        ),
      ),

      // ── Market Watch (plein écran) ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/market-watch',
        pageBuilder: (context, state) => SlideUpTransition(
          child: BlocProvider(
            create: (_) => sl<MarketWatchBloc>()
              ..add(const MarketWatchLoadRequested()),
            child: const MarketWatchPage(),
          ),
        ),
      ),

      // ── Stock Detail (plein écran) ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/stock/:symbol',
        pageBuilder: (context, state) {
          final symbol = state.pathParameters['symbol'] ?? '';
          return SlideUpTransition(
            child: BlocProvider(
            create: (_) => sl<StockDetailBloc>()
              ..add(StockDetailLoadRequested(symbol)),
            child: StockDetailPage(symbol: symbol),
            ),
          );
        },
      ),

      // ── Shell (Bottom Nav) ──
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: new_home.HomePage(),
            ),
          ),
          GoRoute(
            path: '/market',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MarketPage(),
            ),
          ),
          GoRoute(
            path: '/portfolio',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PortfolioPage(),
            ),
          ),
          GoRoute(
            path: '/alerts',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => sl<NotificationsBloc>()
                  ..add(const NotificationsLoadRequested()),
                child: const NotificationsPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/more',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MorePage(),
            ),
          ),
        ],
      ),
    ],
  );
}
