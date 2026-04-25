import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';

import '../../../news/data/datasources/news_mock_datasource.dart';
import '../../../news/domain/entities/news_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_header.dart';
import '../widgets/home_ticker_strip.dart';
import '../widgets/home_indices_row.dart';
import '../widgets/home_favorites_list.dart';
import '../widgets/home_top_movers.dart';

/// Page d'accueil — Dashboard principal BVMT
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return _buildLoading();
        }
        if (state is HomeLoaded) {
          return _buildLoaded(context, state);
        }
        if (state is HomeError) {
          return _buildError(context, state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, HomeLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () async {
          context.read<HomeBloc>().add(const HomeRefreshRequested());
        },
        child: CustomScrollView(
          slivers: [
            // ── Header gradient bleu avec portefeuille ──
            SliverToBoxAdapter(
              child: Semantics(
                label: 'Résumé portefeuille',
                child: HomeHeader(
                  userName: state.userName,
                  portfolio: state.portfolio,
                  isMarketOpen: state.isMarketOpen,
                ),
              ),
            ),

            // ── Ticker défilant ──
            SliverToBoxAdapter(
              child: HomeTickerStrip(stocks: state.tickerData),
            ),

            // ── Indices TUNINDEX / TUNINDEX20 ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppDimens.paddingMD),
                child: HomeIndicesRow(indices: state.indices),
              ),
            ),

            // ── Top Movers ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppDimens.paddingSM),
                child: HomeTopMovers(movers: state.topMovers),
              ),
            ),

            // ── Section Favoris ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppDimens.paddingSM),
                child: HomeFavoritesList(stocks: state.favoriteStocks),
              ),
            ),

            // ── Dernières Actualités ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppDimens.paddingSM),
                child: _HomeNewsPreview(),
              ),
            ),

            // Espace en bas pour le bottom nav
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.bearRed,
                size: 64,
              ),
              const SizedBox(height: AppDimens.paddingMD),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppDimens.paddingLG),
              ElevatedButton(
                onPressed: () {
                  context.read<HomeBloc>().add(const HomeLoadRequested());
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ── Aperçu des dernières actualités sur le dashboard ──
class _HomeNewsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Afficher les 3 dernières news
    final newsList = NewsMockDataSource().buildData().take(3).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMD),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dernières Actualités',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Could navigate to a dedicated news page
                },
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...newsList.map((article) => _NewsPreviewTile(article: article)),
      ],
    );
  }
}

class _NewsPreviewTile extends StatelessWidget {
  final NewsEntity article;
  const _NewsPreviewTile({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMD,
        vertical: 3,
      ),
      padding: const EdgeInsets.all(AppDimens.paddingSM + 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusSM),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // ── Icône catégorie ──
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _iconFor(article.category),
              size: 18,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 10),

          // ── Contenu ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      article.source,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryBlue.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      article.timeAgo,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (article.relatedSymbol != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.push('/stock/${article.relatedSymbol}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            article.relatedSymbol!,
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'marché':
        return Icons.show_chart;
      case 'entreprise':
        return Icons.business;
      case 'analyse':
        return Icons.analytics;
      case 'économie':
        return Icons.account_balance;
      default:
        return Icons.article;
    }
  }
}
