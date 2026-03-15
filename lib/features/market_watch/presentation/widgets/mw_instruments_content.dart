import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/instrument_entity.dart';
import '../bloc/instrument_bloc.dart';
import '../bloc/instrument_event.dart';
import '../bloc/instrument_state.dart';
import 'instrument_stock_table.dart';

// ==========================================================================
// MwInstrumentsContent — Contenu complet de l'onglet Instruments
// Design premium mobile (10/10 UI/UX)
// ==========================================================================
class MwInstrumentsContent extends StatefulWidget {
  final double hPadding;

  const MwInstrumentsContent({
    super.key,
    required this.hPadding,
  });

  @override
  State<MwInstrumentsContent> createState() => _MwInstrumentsContentState();
}

class _MwInstrumentsContentState extends State<MwInstrumentsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isSearchVisible = false;

  static const _tabs = [
    'Actions',
    'Lignes secondaires',
    'Obligations',
    'Marché hors cote',
  ];

  static const _markets = [
    InstrumentMarket.actions,
    InstrumentMarket.lignesSecondaires,
    InstrumentMarket.obligations,
    InstrumentMarket.marcheHorsCote,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final market = _markets[_tabController.index];
    context.read<InstrumentBloc>().add(InstrumentMarketChanged(market));
    // Reset search on tab change
    _searchController.clear();
    context.read<InstrumentBloc>().add(const InstrumentSearchChanged(''));
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tab Bar ──
        _buildTabBar(),

        // ── Search Bar ──
        _buildSearchBar(),

        // ── Table Content ──
        Expanded(
          child: BlocBuilder<InstrumentBloc, InstrumentState>(
            builder: (context, state) {
              if (state is InstrumentLoading || state is InstrumentInitial) {
                return _buildShimmer();
              }
              if (state is InstrumentError) {
                return _buildError(state.message);
              }
              if (state is InstrumentLoaded) {
                if (state.displayedInstruments.isEmpty) {
                  return _buildEmpty();
                }
                return InstrumentStockTable(
                  instruments: state.displayedInstruments,
                  sortColumn: state.sortColumn,
                  sortAscending: state.sortAscending,
                  onSort: (column, ascending) {
                    context.read<InstrumentBloc>().add(
                          InstrumentSortRequested(
                            column: column,
                            ascending: ascending,
                          ),
                        );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // ── TAB BAR (Style BVMT orange transparent) ──
  // ═══════════════════════════════════════════
  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(widget.hPadding, 8, widget.hPadding, 0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.accentOrange,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        indicator: const _OrangeTabIndicator(),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(
          AppColors.accentOrange.withValues(alpha: 0.08),
        ),
        splashBorderRadius: BorderRadius.circular(10),
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── SEARCH BAR ──
  // ═══════════════════════════════════════════
  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.fromLTRB(
        widget.hPadding,
        _isSearchVisible ? 12 : 8,
        widget.hPadding,
        4,
      ),
      child: Row(
        children: [
          // Search toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  context
                      .read<InstrumentBloc>()
                      .add(const InstrumentSearchChanged(''));
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isSearchVisible
                    ? AppColors.accentOrange.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isSearchVisible ? Icons.search_off_rounded : Icons.search_rounded,
                color: _isSearchVisible
                    ? AppColors.accentOrange
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),

          // Animated search field
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: _isSearchVisible
                  ? _buildSearchField()
                  : const SizedBox(key: ValueKey('hidden')),
            ),
          ),

          // Counter badge
          BlocBuilder<InstrumentBloc, InstrumentState>(
            builder: (context, state) {
              if (state is InstrumentLoaded) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.displayedInstruments.length}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      key: const ValueKey('search'),
      height: 36,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (q) =>
            context.read<InstrumentBloc>().add(InstrumentSearchChanged(q)),
        style: AppTypography.bodyMedium.copyWith(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          hintStyle: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 18, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    context
                        .read<InstrumentBloc>()
                        .add(const InstrumentSearchChanged(''));
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.textSecondary),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          isDense: true,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── SHIMMER LOADING ──
  // ═══════════════════════════════════════════
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EAF0),
      highlightColor: const Color(0xFFF5F6FA),
      child: Padding(
        padding: EdgeInsets.all(widget.hPadding),
        child: Column(
          children: List.generate(
            8,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── EMPTY STATE ──
  // ═══════════════════════════════════════════
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun instrument trouvé',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Essayez un autre terme de recherche',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── ERROR STATE ──
  // ═══════════════════════════════════════════
  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bearRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.bearRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTypography.labelMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => context
                  .read<InstrumentBloc>()
                  .add(const InstrumentRefreshRequested()),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Réessayer'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// Custom indicator: fond orange transparent + ligne soulignée orange
// ==========================================================================
class _OrangeTabIndicator extends Decoration {
  const _OrangeTabIndicator();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _OrangeTabPainter();
  }
}

class _OrangeTabPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size ?? Size.zero;
    final rect = offset & size;

    // Fond orange transparent avec coins arrondis
    final bgPaint = Paint()
      ..color = AppColors.accentOrange.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final bgRect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(bgRect, bgPaint);

    // Ligne soulignée orange en bas
    final linePaint = Paint()
      ..color = AppColors.accentOrange
      ..style = PaintingStyle.fill;
    final lineRect = Rect.fromLTWH(
      rect.left + 4,
      rect.bottom - 3,
      rect.width - 8,
      3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(lineRect, const Radius.circular(1.5)),
      linePaint,
    );
  }
}
