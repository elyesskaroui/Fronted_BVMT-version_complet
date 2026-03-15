import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../home/domain/entities/market_summary_entity.dart';
import '../../../indices/domain/entities/indices_stock_entity.dart';
import '../../../indices/presentation/bloc/indices_bloc.dart';
import '../../../indices/presentation/bloc/indices_event.dart';
import '../../../indices/presentation/bloc/indices_state.dart';
import '../bloc/instrument_bloc.dart';
import '../bloc/instrument_event.dart';
import '../bloc/instrument_state.dart';
import '../bloc/market_watch_bloc.dart';
import '../bloc/market_watch_event.dart';
import '../bloc/market_watch_state.dart';
import '../widgets/mw_index_chart_card.dart';
import '../widgets/mw_indices_full_content.dart';
import '../widgets/mw_instruments_content.dart';
import '../widgets/mw_market_summary_banner.dart';
import '../widgets/mw_top_stocks_card.dart';

/// Page Market Watch — Écran plein écran avec données de marché détaillées
/// Design premium, optimisé mobile, avec search, animations, timestamp
class MarketWatchPage extends StatefulWidget {
  const MarketWatchPage({super.key});

  @override
  State<MarketWatchPage> createState() => _MarketWatchPageState();
}

class _MarketWatchPageState extends State<MarketWatchPage>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  int _bottomTopTabIndex = 0; // Capitaux / Quantité / Transactions

  // Expansion states for "Voir plus"
  final Map<String, bool> _expandedSections = {};

  // Search
  bool _isSearchOpen = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  // Timestamp ticker
  Timer? _timestampTimer;
  String _timeAgoText = '';

  // IndicesBloc (créé localement pour le sous-onglet Indices)
  late final IndicesBloc _indicesBloc;

  // InstrumentBloc (créé localement pour le sous-onglet Instruments)
  late final InstrumentBloc _instrumentBloc;

  @override
  void initState() {
    super.initState();
    _indicesBloc = sl<IndicesBloc>();
    _instrumentBloc = sl<InstrumentBloc>();
    _mainTabController = TabController(length: 2, vsync: this);
    _mainTabController.addListener(() {
      if (!_mainTabController.indexIsChanging) {
        context.read<MarketWatchBloc>().add(
              MarketWatchMainTabChanged(_mainTabController.index),
            );
      }
    });
    // Tick the "il y a Xs" label every second
    _timestampTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _timestampTimer?.cancel();
    _indicesBloc.close();
    _instrumentBloc.close();
    super.dispose();
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 5) return 'à l\'instant';
    if (diff.inSeconds < 60) return 'il y a ${diff.inSeconds}s';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}min';
    return 'il y a ${diff.inHours}h';
  }

  List<TopStockEntry> _filterEntries(
      List<TopStockEntry> entries, String query) {
    if (query.isEmpty) return entries;
    final q = query.toUpperCase();
    return entries.where((e) => e.symbol.toUpperCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<IndicesBloc>.value(value: _indicesBloc),
        BlocProvider<InstrumentBloc>.value(value: _instrumentBloc),
      ],
      child: BlocBuilder<MarketWatchBloc, MarketWatchState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          child: _buildForState(context, state),
        );
        },
      ),
    );
  }

  Widget _buildForState(BuildContext context, MarketWatchState state) {
    if (state is MarketWatchLoading || state is MarketWatchInitial) {
      return _buildLoading(key: const ValueKey('mw_loading'));
    }
    if (state is MarketWatchLoaded) {
      return _buildLoaded(context, state, key: const ValueKey('mw_loaded'));
    }
    if (state is MarketWatchError) {
      return _buildError(context, state.message,
          key: const ValueKey('mw_error'));
    }
    return const SizedBox.shrink();
  }

  // ═══════════════════════════════════════════
  // ── LOADING ──
  // ═══════════════════════════════════════════
  Widget _buildLoading({Key? key}) {
    return Scaffold(
      key: key,
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          _buildGradientAppBar(null),
          SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: const Color(0xFFE8EAF0),
              highlightColor: const Color(0xFFF5F6FA),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(
                        4,
                        (_) => Expanded(
                          child: Container(
                            height: 36,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 260,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 260,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── LOADED ──
  // ═══════════════════════════════════════════
  Widget _buildLoaded(BuildContext context, MarketWatchLoaded state,
      {Key? key}) {
    final hPadding = ResponsiveLayout.horizontalPadding(context);
    _timeAgoText = _formatTimeAgo(state.lastUpdatedAt);

    return Scaffold(
      key: key,
      backgroundColor: AppColors.scaffoldBackground,
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: AppColors.primaryBlue,
        onRefresh: () async {
          context
              .read<MarketWatchBloc>()
              .add(const MarketWatchRefreshRequested());
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Gradient AppBar with search
            _buildGradientAppBar(state),

            // Search bar (animated expand)
            if (_isSearchOpen)
              SliverToBoxAdapter(child: _buildSearchBar()),

            // Market Summary Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: MwMarketSummaryBanner(summary: state.summary),
              ),
            ),

            // Timestamp
            SliverToBoxAdapter(
              child: _buildTimestamp(state),
            ),

            // Main tab bar (Live / Historique)
            SliverToBoxAdapter(
              child: _buildMainTabBar(),
            ),

            // Sub tab bar (Résumé du Marché / Tout / Marché / Indices)
            SliverToBoxAdapter(
              child: _buildSubTabs(state),
            ),

            // Contenu selon le sous-onglet sélectionné
            ..._buildContentForSubTab(state, hPadding),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── TIMESTAMP ──
  // ═══════════════════════════════════════════
  Widget _buildTimestamp(MarketWatchLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            'Mise à jour $_timeAgoText',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 6,
            height: 6,
            child: state.summary.isSessionOpen
                ? _PulseDot(color: AppColors.bullGreen)
                : Container(
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── SEARCH BAR ──
  // ═══════════════════════════════════════════
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (q) {
          context.read<MarketWatchBloc>().add(MarketWatchSearchChanged(q));
        },
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher une valeur (ex: BIAT, SFBT...)',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    context
                        .read<MarketWatchBloc>()
                        .add(const MarketWatchSearchChanged(''));
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── GRADIENT SLIVER APP BAR ──
  // ═══════════════════════════════════════════
  SliverAppBar _buildGradientAppBar(MarketWatchLoaded? state) {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: AppColors.primaryBlue,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 60,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: Colors.white,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A6BCC),
                Color(0xFF0D4FA8),
                Color(0xFF1B2A4A),
              ],
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.candlestick_chart_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Market Watch',
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      actions: [
        // Search toggle
        IconButton(
          onPressed: () {
            setState(() {
              _isSearchOpen = !_isSearchOpen;
              if (_isSearchOpen) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  _searchFocusNode.requestFocus();
                });
              } else {
                _searchController.clear();
                context
                    .read<MarketWatchBloc>()
                    .add(const MarketWatchSearchChanged(''));
              }
            });
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
              key: ValueKey(_isSearchOpen),
              size: 20,
            ),
          ),
          color: Colors.white.withValues(alpha: 0.9),
        ),
        // Refresh
        IconButton(
          onPressed: () {
            context
                .read<MarketWatchBloc>()
                .add(const MarketWatchRefreshRequested());
          },
          icon: const Icon(Icons.refresh_rounded, size: 20),
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // ── MAIN TAB BAR (Live / Historique) ──
  // ═══════════════════════════════════════════
  Widget _buildMainTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _mainTabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A6BCC), Color(0xFF0D4FA8)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(3),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: const [
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt_rounded, size: 16),
                SizedBox(width: 6),
                Text('Live Market Watch'),
              ],
            ),
          ),
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 16),
                SizedBox(width: 6),
                Text('Historique'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── SUB TABS (Résumé du Marché / Instruments / Indices) ──
  // ═══════════════════════════════════════════
  Widget _buildSubTabs(MarketWatchLoaded state) {
    const tabs = ['Résumé du Marché', 'Instruments', 'Indices'];
    const icons = [
      Icons.dashboard_rounded,
      Icons.list_alt_rounded,
      Icons.timeline_rounded,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((e) {
            final selected = state.subTabIndex == e.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  context
                      .read<MarketWatchBloc>()
                      .add(MarketWatchSubTabChanged(e.key));
                  // Lazy-load indices data when Indices tab selected
                  if (e.key == 2) {
                    if (_indicesBloc.state is IndicesInitial) {
                      _indicesBloc.add(const IndicesLoadRequested());
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.divider,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icons[e.key],
                        size: 13,
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        e.value,
                        style: AppTypography.labelMedium.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── CONTENT BUILDER ──
  // ═══════════════════════════════════════════
  List<Widget> _buildContentForSubTab(
      MarketWatchLoaded state, double hPadding) {
    switch (state.subTabIndex) {
      case 0:
        return _buildResumeSummary(state, hPadding);
      case 1:
        // Instruments tab — full content with sub-tabs + table
        if (_instrumentBloc.state is InstrumentInitial) {
          _instrumentBloc.add(const InstrumentLoadRequested());
        }
        return [
          SliverFillRemaining(
            hasScrollBody: true,
            child: MwInstrumentsContent(hPadding: hPadding),
          ),
        ];
      case 2:
        // Lazy-load on first build (e.g. deep link)
        if (_indicesBloc.state is IndicesInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _indicesBloc.add(const IndicesLoadRequested());
            }
          });
        }
        return _buildIndicesContent(state, hPadding);
      default:
        return _buildResumeSummary(state, hPadding);
    }
  }

  // ═══════════════════════════════════════════
  // ── SUB-TAB 0: RÉSUMÉ ──
  // ═══════════════════════════════════════════
  List<Widget> _buildResumeSummary(
      MarketWatchLoaded state, double hPadding) {
    final query = state.searchQuery;

    return [
      // ── Section Indices ──
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPadding, 8, hPadding, 0),
          child: _buildSectionTitle('Indices', Icons.timeline_rounded),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPadding, 12, hPadding, 0),
          child: MwIndexChartCard(
            indexData: state.summary.tunindex,
            intradayData: state.tunindexIntraday,
            sessionDate: state.summary.sessionDate,
            isOpen: state.summary.isSessionOpen,
            selectedPeriod: state.chartPeriod,
            onPeriodChanged: (p) => context
                .read<MarketWatchBloc>()
                .add(MarketWatchChartPeriodChanged(p)),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPadding, 12, hPadding, 0),
          child: MwIndexChartCard(
            indexData: state.summary.tunindex20,
            intradayData: state.tunindex20Intraday,
            sessionDate: state.summary.sessionDate,
            isOpen: state.summary.isSessionOpen,
            selectedPeriod: state.chartPeriod,
            onPeriodChanged: (p) => context
                .read<MarketWatchBloc>()
                .add(MarketWatchChartPeriodChanged(p)),
          ),
        ),
      ),

      // ── Section Top Hausses ──
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPadding, 20, hPadding, 0),
          child: _buildSectionTitle('Top Hausses', Icons.trending_up_rounded),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPadding, 12, hPadding, 0),
          child: MwTopStocksCard(
            title: 'TOP HAUSSES',
            sessionDate: state.summary.sessionDate,
            isOpen: state.summary.isSessionOpen,
            entries: _filterEntries(state.topHausses, query),
            metricColumnHeader: 'CAPITAUX',
            expanded: _expandedSections['hausses'] ?? false,
            onToggleExpand: () => setState(() {
              _expandedSections['hausses'] =
                  !(_expandedSections['hausses'] ?? false);
            }),
          ),
        ),
      ),

      // ── Section Top Baisses ──
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPadding, 20, hPadding, 0),
          child: _buildSectionTitle('Top Baisses', Icons.trending_down_rounded),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPadding, 12, hPadding, 0),
          child: MwTopStocksCard(
            title: 'TOP BAISSES',
            sessionDate: state.summary.sessionDate,
            isOpen: state.summary.isSessionOpen,
            entries: _filterEntries(state.topBaisses, query),
            metricColumnHeader: 'CAPITAUX',
            expanded: _expandedSections['baisses'] ?? false,
            onToggleExpand: () => setState(() {
              _expandedSections['baisses'] =
                  !(_expandedSections['baisses'] ?? false);
            }),
          ),
        ),
      ),

      // ── Section Classements ──
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPadding, 20, hPadding, 0),
          child: _buildSectionTitle('Classements', Icons.leaderboard_rounded),
        ),
      ),
      SliverToBoxAdapter(
        child: _buildBottomTopTabs(state, hPadding),
      ),
    ];
  }

  // ═══════════════════════════════════════════
  // ── SUB-TAB 3: INDICES (selector + summary + chart + composition) ──
  // ═══════════════════════════════════════════
  List<Widget> _buildIndicesContent(
      MarketWatchLoaded state, double hPadding) {
    return [
      SliverToBoxAdapter(
        child: MwIndicesFullContent(
          hPadding: hPadding,
          indicesBloc: _indicesBloc,
        ),
      ),
    ];
  }

  // ═══════════════════════════════════════════
  // ── MARKET OVERVIEW CARD ──
  // ═══════════════════════════════════════════
  Widget _buildMarketOverviewCard(MarketSummaryEntity s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildOverviewItem(
                'Valeurs Actives',
                '${s.activeValues}/${s.totalValues}',
                Icons.circle,
                AppColors.primaryBlue,
              ),
              const SizedBox(width: 12),
              _buildOverviewItem(
                'En Hausse',
                '${s.nbHausses}',
                Icons.arrow_upward_rounded,
                AppColors.bullGreen,
              ),
              const SizedBox(width: 12),
              _buildOverviewItem(
                'En Baisse',
                '${s.nbBaisses}',
                Icons.arrow_downward_rounded,
                AppColors.bearRed,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 6,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: const Color(0xFFF0F1F5),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: s.nbHausses > 0 ? s.nbHausses : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bullGreen,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        bottomLeft: Radius.circular(3),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: s.nbBaisses > 0 ? s.nbBaisses : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bearRed,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(3),
                        bottomRight: Radius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hausse ${s.nbHausses}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.bullGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
              Text(
                'Baisse ${s.nbBaisses}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.bearRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── SECTION TITLE ──
  // ═══════════════════════════════════════════
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── BOTTOM TOP TABS (Capitaux / Quantité / Transactions) ──
  // ═══════════════════════════════════════════
  Widget _buildBottomTopTabs(MarketWatchLoaded state, double hPadding) {
    final tabs = ['Top Capitaux', 'Top Quantité', 'Top Transactions'];
    final headers = ['CAPITAUX', 'QUANTITÉ', 'NB TRANS.'];
    final query = state.searchQuery;
    final dataLists = [
      _filterEntries(state.topCapitaux, query),
      _filterEntries(state.topQuantite, query),
      _filterEntries(state.topTransactions, query),
    ];
    final expandKeys = ['capitaux', 'quantite', 'transactions'];

    return Padding(
      padding: EdgeInsets.fromLTRB(hPadding, 12, hPadding, 0),
      child: Column(
        children: [
          // Tab selector
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: tabs.asMap().entries.map((e) {
                final selected = _bottomTopTabIndex == e.key;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _bottomTopTabIndex = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF1A6BCC),
                                  Color(0xFF0D4FA8),
                                ],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryBlue
                                      .withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        e.value,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelSmall.copyWith(
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Contenu du tab
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: MwTopStocksCard(
              key: ValueKey('top_${expandKeys[_bottomTopTabIndex]}'),
              title: tabs[_bottomTopTabIndex].toUpperCase(),
              sessionDate: state.summary.sessionDate,
              isOpen: state.summary.isSessionOpen,
              entries: dataLists[_bottomTopTabIndex],
              metricColumnHeader: headers[_bottomTopTabIndex],
              expanded:
                  _expandedSections[expandKeys[_bottomTopTabIndex]] ?? false,
              onToggleExpand: () => setState(() {
                final key = expandKeys[_bottomTopTabIndex];
                _expandedSections[key] = !(_expandedSections[key] ?? false);
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── ERROR ──
  // ═══════════════════════════════════════════
  Widget _buildError(BuildContext context, String message, {Key? key}) {
    return Scaffold(
      key: key,
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          _buildGradientAppBar(null),
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.paddingXL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.bearRed.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_off_rounded,
                        color: AppColors.bearRed,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingLG),
                    Text(
                      'Connexion impossible',
                      style: AppTypography.h3
                          .copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppDimens.paddingSM),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimens.paddingXL),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<MarketWatchBloc>()
                              .add(const MarketWatchLoadRequested());
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusMD),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// ── INDICES STOCK CARD (expandable) ──
// ═══════════════════════════════════════════
class _MwIndicesCard extends StatefulWidget {
  final IndicesStockEntity stock;
  final int index;

  const _MwIndicesCard({required this.stock, required this.index});

  @override
  State<_MwIndicesCard> createState() => _MwIndicesCardState();
}

class _MwIndicesCardState extends State<_MwIndicesCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _expandController.forward() : _expandController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stock = widget.stock;
    final changeColor = stock.isPositive
        ? AppColors.bullGreen
        : stock.isNegative
            ? AppColors.bearRed
            : AppColors.textSecondary;
    final changeBg = stock.isPositive
        ? AppColors.bullGreen10
        : stock.isNegative
            ? AppColors.bearRed10
            : AppColors.black04;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleExpand,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isExpanded
                    ? AppColors.primaryBlue.withValues(alpha: 0.2)
                    : AppColors.divider.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: _isExpanded
                      ? AppColors.primaryBlue.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: _isExpanded ? 12 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Main row (always visible) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Row(
                    children: [
                      // Name + Close price
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stock.name,
                              style: AppTypography.titleSmall.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  stock.formattedClosePrice,
                                  style: AppTypography.stockPrice.copyWith(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'TND',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.5),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Variation badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: changeBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!stock.isNeutral)
                              Icon(
                                stock.isPositive
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 14,
                                color: changeColor,
                              ),
                            if (!stock.isNeutral) const SizedBox(width: 4),
                            Text(
                              stock.formattedChange,
                              style: AppTypography.changePercent.copyWith(
                                color: changeColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Expand arrow
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.4),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Expandable details ──
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Column(
                    children: [
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        color: AppColors.divider.withValues(alpha: 0.3),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _MwIndicesDetail(
                                    icon: Icons.login_rounded,
                                    label: 'Ouverture',
                                    value: stock.formattedOpenPrice,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _MwIndicesDetail(
                                    icon: Icons.logout_rounded,
                                    label: 'Clôture',
                                    value: stock.formattedClosePrice,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _MwIndicesDetail(
                                    icon: Icons.swap_horiz_rounded,
                                    label: 'Transactions',
                                    value: stock.formattedTransactions,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _MwIndicesDetail(
                                    icon: Icons.bar_chart_rounded,
                                    label: 'Volume',
                                    value: stock.formattedVolume,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _MwIndicesDetail(
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'Capitaux',
                              value: '${stock.formattedCapitaux} TND',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// ── INDICES DETAIL ITEM (inside expanded card) ──
// ═══════════════════════════════════════════
class _MwIndicesDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MwIndicesDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue08,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color:
                        AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.bodyMediumBold.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// ── PULSE DOT (reusable animated dot) ──
// ═══════════════════════════════════════════
class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _anim.value),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _anim.value * 0.5),
              blurRadius: 4 * _anim.value,
            ),
          ],
        ),
      ),
    );
  }
}
