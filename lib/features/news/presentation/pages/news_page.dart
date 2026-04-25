import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/services/pdf_download_service.dart';
import '../../domain/entities/news_entity.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';

/// Page Actualités — Design premium cohérent avec le reste de l'app BVMT
class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          if (state is NewsLoading || state is NewsInitial) {
            return _buildLoading();
          }
          if (state is NewsError) {
            return _buildError(context, state.message);
          }
          if (state is NewsLoaded) {
            return _buildLoaded(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  LOADING — Shimmer skeleton
  // ═══════════════════════════════════════════
  Widget _buildLoading() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 60,
          floating: true,
          pinned: true,
          backgroundColor: AppColors.primaryBlue,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppColors.headerGradient),
            ),
          ),
          title: const Text(
            'Publications',
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: const Color(0xFFE8EAF0),
            highlightColor: const Color(0xFFF5F6FA),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingMD),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(
                      4,
                      (_) => Container(
                        height: 32,
                        width: 72,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    5,
                    (_) => Container(
                      height: 96,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  //  ERROR
  // ═══════════════════════════════════════════
  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Publications'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.bearRed.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_off_rounded, color: AppColors.bearRed, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Impossible de charger',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => context.read<NewsBloc>().add(const NewsLoadRequested()),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMD)),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Réessayer', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  LOADED — Main content
  // ═══════════════════════════════════════════
  Widget _buildLoaded(BuildContext context, NewsLoaded state) {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: AppColors.primaryBlue,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        context.read<NewsBloc>().add(const NewsRefreshRequested());
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            expandedHeight: 60,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.headerGradient),
              ),
            ),
            title: const Text(
              'Publications',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            actions: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.allNews.length}',
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Hero Card ──
          if (state.filteredNews.isNotEmpty)
            SliverToBoxAdapter(
              child: _FeaturedHeroCard(article: state.filteredNews.first),
            ),

          // ── Category Chips ──
          SliverToBoxAdapter(
            child: _CategoryFilterBar(
              categories: state.categories,
              selected: state.selectedCategory,
            ),
          ),

          // ── Section Label ──
          if (state.filteredNews.length > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppDimens.paddingMD, 4, AppDimens.paddingMD, 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Toutes les publications',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${state.filteredNews.length - 1} résultats',
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Empty ──
          if (state.filteredNews.isEmpty)
            SliverFillRemaining(child: _buildEmpty()),

          // ── Publications List ──
          if (state.filteredNews.length > 1)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMD),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final i = index + 1;
                    if (i >= state.filteredNews.length) return null;
                    return _PublicationCard(article: state.filteredNews[i]);
                  },
                  childCount: state.filteredNews.length - 1,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded, color: AppColors.primaryBlue, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune publication',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Changez de catégorie ou actualisez',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  HERO CARD — Gradient premium card
// ═══════════════════════════════════════════════════════
class _FeaturedHeroCard extends StatelessWidget {
  final NewsEntity article;
  const _FeaturedHeroCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimens.paddingMD),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlueLight, AppColors.primaryBlue, AppColors.deepNavy],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -25,
              left: -15,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentOrange.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges row
                  Row(
                    children: [
                      // Orange badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accentOrange, AppColors.accentOrangeLight],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentOrange.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, size: 11, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'DERNIÈRE PUBLICATION',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Date badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 11, color: Colors.white.withValues(alpha: 0.7)),
                            const SizedBox(width: 4),
                            Text(
                              article.formattedDate,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(article.category),
                          size: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.category,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bottom bar
                  Row(
                    children: [
                      Icon(Icons.business_rounded, size: 13, color: Colors.white.withValues(alpha: 0.45)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          article.source,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (article.hasPdf)
                        GestureDetector(
                          onTap: () => PdfDownloadService.downloadAndOpen(article.pdfUrl!, context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentOrange.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.picture_as_pdf_rounded, size: 15, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Télécharger PDF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _getCategoryIcon(String category) {
    final lc = category.toLowerCase();
    if (lc.contains('ordinaire') || lc.contains('assemblée') || lc.contains('spéciale') || lc.contains('extraordinaire')) return Icons.groups_rounded;
    if (lc.contains('financier') || lc.contains('annuel') || lc.contains('consolidé') || lc.contains('individuel') || lc.contains('intermédiaire')) return Icons.description_rounded;
    if (lc.contains('communiqué') || lc.contains('presse')) return Icons.campaign_rounded;
    if (lc.contains('indicateur') || lc.contains('trimestriel')) return Icons.show_chart_rounded;
    if (lc.contains('rapport')) return Icons.analytics_rounded;
    return Icons.article_rounded;
  }
}

// ═══════════════════════════════════════════════════════
//  CATEGORY FILTER BAR
// ═══════════════════════════════════════════════════════
class _CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String selected;
  const _CategoryFilterBar({required this.categories, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMD, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = cat == selected;
          final info = _catInfo(cat);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<NewsBloc>().add(NewsCategoryChanged(cat));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryBlue : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primaryBlue : AppColors.divider,
                    width: isActive ? 1.5 : 1,
                  ),
                  boxShadow: isActive
                      ? [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
                      : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (info.icon != null) ...[
                      Icon(info.icon, size: 13, color: isActive ? Colors.white : AppColors.textSecondary),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      info.label,
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.textPrimary,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _CatInfo _catInfo(String cat) {
    final lc = cat.toLowerCase();
    if (cat == 'Tout') return _CatInfo('Tout', Icons.grid_view_rounded);
    if (lc.contains('ordinaire')) return _CatInfo('AGO', Icons.groups_rounded);
    if (lc.contains('extraordinaire')) return _CatInfo('AGE', Icons.groups_rounded);
    if (lc.contains('spéciale')) return _CatInfo('AGS', Icons.groups_rounded);
    if (lc.contains('individuel')) return _CatInfo('États Indiv.', Icons.description_rounded);
    if (lc.contains('consolidé')) return _CatInfo('États Cons.', Icons.description_rounded);
    if (lc.contains('intermédiaire')) return _CatInfo('Semi-annuel', Icons.description_rounded);
    if (lc.contains('communiqué') || lc.contains('presse')) return _CatInfo('Communiqué', Icons.campaign_rounded);
    if (lc.contains('indicateur') || lc.contains('trimestriel')) return _CatInfo('Indicateurs', Icons.show_chart_rounded);
    if (lc.contains('rapport')) return _CatInfo('Rapports', Icons.analytics_rounded);
    if (lc.contains('déclaration') || lc.contains('opération')) return _CatInfo('Déclarations', Icons.gavel_rounded);
    return _CatInfo(cat.length > 15 ? '${cat.substring(0, 13)}…' : cat, null);
  }
}

class _CatInfo {
  final String label;
  final IconData? icon;
  _CatInfo(this.label, this.icon);
}

// ═══════════════════════════════════════════════════════
//  PUBLICATION CARD — White card, clean, consistent
// ═══════════════════════════════════════════════════════
class _PublicationCard extends StatelessWidget {
  final NewsEntity article;
  const _PublicationCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(article.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusMD),
          onTap: article.hasPdf ? () => PdfDownloadService.downloadAndOpen(article.pdfUrl!, context) : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Category Icon ──
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_categoryIcon(article.category), size: 22, color: catColor),
                ),
                const SizedBox(width: 12),

                // ── Content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date + Category
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              article.formattedDate,
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              article.category,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Summary
                      Text(
                        article.summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 8),

                      // Source + PDF
                      Row(
                        children: [
                          const Icon(Icons.business_rounded, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              article.source,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (article.hasPdf)
                            GestureDetector(
                              onTap: () => PdfDownloadService.downloadAndOpen(article.pdfUrl!, context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accentOrange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.picture_as_pdf_rounded, size: 12, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text('Télécharger PDF', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                const Padding(
                  padding: EdgeInsets.only(top: 10, left: 4),
                  child: Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _categoryColor(String category) {
    final lc = category.toLowerCase();
    if (lc.contains('ordinaire') || lc.contains('assemblée') || lc.contains('spéciale') || lc.contains('extraordinaire')) return AppColors.bullGreen;
    if (lc.contains('financier') || lc.contains('annuel') || lc.contains('consolidé') || lc.contains('individuel') || lc.contains('intermédiaire')) return AppColors.primaryBlue;
    if (lc.contains('communiqué') || lc.contains('presse')) return AppColors.accentOrange;
    if (lc.contains('indicateur') || lc.contains('trimestriel')) return AppColors.warningYellow;
    if (lc.contains('rapport')) return const Color(0xFF8E44AD);
    return AppColors.textSecondary;
  }

  static IconData _categoryIcon(String category) {
    final lc = category.toLowerCase();
    if (lc.contains('ordinaire') || lc.contains('assemblée') || lc.contains('spéciale') || lc.contains('extraordinaire')) return Icons.groups_rounded;
    if (lc.contains('financier') || lc.contains('annuel') || lc.contains('consolidé') || lc.contains('individuel') || lc.contains('intermédiaire')) return Icons.description_rounded;
    if (lc.contains('communiqué') || lc.contains('presse')) return Icons.campaign_rounded;
    if (lc.contains('indicateur') || lc.contains('trimestriel')) return Icons.show_chart_rounded;
    if (lc.contains('rapport')) return Icons.analytics_rounded;
    if (lc.contains('candidature') || lc.contains('appel')) return Icons.person_search_rounded;
    if (lc.contains('déclaration') || lc.contains('opération')) return Icons.gavel_rounded;
    return Icons.article_rounded;
  }
}
