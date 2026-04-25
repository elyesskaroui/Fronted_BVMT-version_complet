import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/market_summary_state.dart';
import 'global_summary_slide.dart';
import 'index_chart_slide.dart';
import 'top_stocks_table_slide.dart';

/// Carrousel 8 slides — PageView avec navigation tabs premium + dots
/// Design : onglets scrollables avec icônes, transitions fluides,
/// indicateur animé avec effet glow
class MarketSummaryPageView extends StatefulWidget {
  final MarketSummaryLoaded state;
  final ValueChanged<int> onPageChanged;

  const MarketSummaryPageView({
    super.key,
    required this.state,
    required this.onPageChanged,
  });

  @override
  State<MarketSummaryPageView> createState() => _MarketSummaryPageViewState();
}

class _MarketSummaryPageViewState extends State<MarketSummaryPageView> {
  late final PageController _ctrl;
  int _current = 0;

  static const _tabs = [
    _TabInfo('Global', Icons.dashboard_rounded),
    _TabInfo('TUNINDEX', Icons.show_chart_rounded),
    _TabInfo('TUNINDEX20', Icons.ssid_chart_rounded),
    _TabInfo('Capitaux', Icons.account_balance_wallet_rounded),
    _TabInfo('Quantité', Icons.inventory_2_rounded),
    _TabInfo('Transactions', Icons.swap_horiz_rounded),
    _TabInfo('Hausses', Icons.trending_up_rounded),
    _TabInfo('Baisses', Icons.trending_down_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _current = widget.state.currentPage;
    _ctrl = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _ctrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tab navigation ──
        _buildTabBar(),
        const SizedBox(height: 8),

        // ── PageView ──
        Expanded(
          child: PageView(
            controller: _ctrl,
            onPageChanged: (i) {
              setState(() => _current = i);
              widget.onPageChanged(i);
            },
            children: _buildPages(),
          ),
        ),

        // ── Dots indicator ──
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: _buildDotsIndicator(),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (_, i) {
          final selected = i == _current;
          final tab = _tabs[i];
          final color = _tabColor(i);

          return GestureDetector(
            
            onTap: () => _goTo(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: selected
                    ? null
                    : Border.all(
                        color: AppColors.divider.withValues(alpha: 0.5),
                      ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
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
                    tab.icon,
                    size: 13,
                    color: selected
                        ? Colors.white
                        : AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    tab.label,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _tabs.length,
        (i) {
          final selected = i == _current;
          final color = _tabColor(i);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            width: selected ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: selected ? color : AppColors.divider,
              borderRadius: BorderRadius.circular(3),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          );
        },
      ),
    );
  }

  Color _tabColor(int index) {
    switch (index) {
      case 0:
        return AppColors.primaryBlue;
      case 1:
        return AppColors.primaryBlue;
      case 2:
        return AppColors.accentOrange;
      case 3:
        return AppColors.accentOrange;
      case 4:
        return const Color(0xFF8B5CF6);
      case 5:
        return AppColors.primaryBlue;
      case 6:
        return AppColors.bullGreen;
      case 7:
        return AppColors.bearRed;
      default:
        return AppColors.primaryBlue;
    }
  }

  List<Widget> _buildPages() {
    final s = widget.state;
    return [
      // 0: Global
      GlobalSummarySlide(summary: s.summary),
      // 1: TUNINDEX chart
      IndexChartSlide(
        index: s.summary.tunindex,
        intradayData: s.tunindexIntraday,
        lineColor: AppColors.primaryBlue,
      ),
      // 2: TUNINDEX20 chart
      IndexChartSlide(
        index: s.summary.tunindex20,
        intradayData: s.tunindex20Intraday,
        lineColor: AppColors.accentOrange,
      ),
      // 3: Top Capitaux
      TopStocksTableSlide(
        type: TopStockType.capitaux,
        entries: s.topCapitaux,
      ),
      // 4: Top Quantité
      TopStocksTableSlide(
        type: TopStockType.quantite,
        entries: s.topQuantite,
      ),
      // 5: Top Transactions
      TopStocksTableSlide(
        type: TopStockType.transactions,
        entries: s.topTransactions,
      ),
      // 6: Top Hausses
      TopStocksTableSlide(
        type: TopStockType.hausses,
        entries: s.topHausses,
      ),
      // 7: Top Baisses
      TopStocksTableSlide(
        type: TopStockType.baisses,
        entries: s.topBaisses,
      ),
    ];
  }
}

/// Tab info holder
class _TabInfo {
  final String label;
  final IconData icon;
  const _TabInfo(this.label, this.icon);
}
