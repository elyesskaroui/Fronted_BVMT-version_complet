import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/datasources/instrument_detail_mock_datasource.dart';
import '../../data/datasources/instrument_publication_remote_datasource.dart';
import '../../domain/entities/instrument_detail_models.dart';
import '../../domain/entities/instrument_entity.dart';
import 'detail_chart_tab.dart';
import 'detail_order_book_tab.dart';
import 'detail_publications_tab.dart';
import 'detail_summary_tab.dart';
import 'detail_transactions_tab.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

// ==========================================================================
// InstrumentDetailSheet — BottomSheet modal premium 10/10
// Gradient header, backdrop blur, haptic, sparkline, pull-to-refresh
// ==========================================================================
class InstrumentDetailSheet extends StatefulWidget {
  final InstrumentEntity instrument;

  const InstrumentDetailSheet({super.key, required this.instrument});

  /// Ouvre le BottomSheet avec backdrop blur
  static Future<void> show(
      BuildContext context, InstrumentEntity instrument) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 400),
      ),
      builder: (_) => InstrumentDetailSheet(instrument: instrument),
    );
  }

  @override
  State<InstrumentDetailSheet> createState() => _InstrumentDetailSheetState();
}

class _InstrumentDetailSheetState extends State<InstrumentDetailSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFadeIn;
  final _dataSource = InstrumentDetailMockDataSource();
  final _publicationRemote = InstrumentPublicationRemoteDataSource(
    dio: GetIt.instance<Dio>(),
  );

  // Data loaded per tab
  OrderBook? _orderBook;
  List<StockTransaction>? _transactions;
  List<StockPublication>? _publications;
  List<double>? _chartData;

  /// Whether this instrument is a bond (Lignes Secondaires or Obligations)
  bool get _isBondMarket =>
      widget.instrument.market == InstrumentMarket.lignesSecondaires ||
      widget.instrument.market == InstrumentMarket.obligations;

  bool get _isObligations =>
      widget.instrument.market == InstrumentMarket.obligations;

  bool get _isLignesSecondaires =>
      widget.instrument.market == InstrumentMarket.lignesSecondaires;

  bool get _isHorsCote =>
      widget.instrument.market == InstrumentMarket.marcheHorsCote;

  int get _tabCount => _isObligations ? 3 : (_isLignesSecondaires ? 4 : 5);

  List<IconData> get _tabIcons => _isObligations
      ? const [
          Icons.dashboard_rounded,
          Icons.menu_book_rounded,
          Icons.receipt_long_rounded,
        ]
      : _isLignesSecondaires
      ? const [
          Icons.dashboard_rounded,
          Icons.menu_book_rounded,
          Icons.receipt_long_rounded,
          Icons.newspaper_rounded,
        ]
      : const [
          Icons.dashboard_rounded,
          Icons.menu_book_rounded,
          Icons.show_chart_rounded,
          Icons.receipt_long_rounded,
          Icons.newspaper_rounded,
        ];

  List<String> get _tabLabels => _isObligations
      ? const ['Résumé', 'Carnet d\'ordres', 'Transactions']
      : _isLignesSecondaires
      ? const ['Résumé', 'Carnet d\'ordres', 'Transactions', 'Publications']
      : const ['Résumé', 'Carnet', 'Graphique', 'Transactions', 'Publications'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _tabController.addListener(_onTabChanged);

    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFadeIn = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeOutCubic,
    );
    _headerAnimCtrl.forward();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    HapticFeedback.selectionClick();
    _loadTabData(_tabController.index);
  }

  Future<void> _loadTabData(int index) async {
    if (_isObligations) {
      // 3 tabs: Résumé(0), Carnet(1), Transactions(2)
      switch (index) {
        case 1:
          if (_orderBook != null) return;
          final data = await _dataSource.getOrderBook(widget.instrument);
          if (mounted) setState(() => _orderBook = data);
          break;
        case 2:
          if (_transactions != null) return;
          final data = await _dataSource.getTransactions(widget.instrument);
          if (mounted) setState(() => _transactions = data);
          break;
      }
    } else if (_isLignesSecondaires) {
      // 4 tabs: Résumé(0), Carnet(1), Transactions(2), Publications(3)
      switch (index) {
        case 1:
          if (_orderBook != null) return;
          final data = await _dataSource.getOrderBook(widget.instrument);
          if (mounted) setState(() => _orderBook = data);
          break;
        case 2:
          if (_transactions != null) return;
          final data = await _dataSource.getTransactions(widget.instrument);
          if (mounted) setState(() => _transactions = data);
          break;
        case 3:
          if (_publications != null) return;
          final data = await _publicationRemote.getPublications(widget.instrument);
          if (mounted) setState(() => _publications = data);
          break;
      }
    } else {
      // 5 tabs: Résumé(0), Carnet(1), Graphique(2), Transactions(3), Publications(4)
      switch (index) {
        case 1:
          if (_orderBook != null) return;
          final data = await _dataSource.getOrderBook(widget.instrument);
          if (mounted) setState(() => _orderBook = data);
          break;
        case 2:
          if (_chartData != null) return;
          final data = await _dataSource.getChartData(widget.instrument);
          if (mounted) setState(() => _chartData = data);
          break;
        case 3:
          if (_transactions != null) return;
          final data = await _dataSource.getTransactions(widget.instrument);
          if (mounted) setState(() => _transactions = data);
          break;
        case 4:
          if (_publications != null) return;
          final data = await _publicationRemote.getPublications(widget.instrument);
          if (mounted) setState(() => _publications = data);
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _headerAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          height: screenHeight * 0.9,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepNavy.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Drag Handle ──
              _buildDragHandle(),
              // ── Premium Header ──
              FadeTransition(
                opacity: _headerFadeIn,
                child: _buildPremiumHeader(),
              ),
              // ── TabBar ──
              _buildTabBar(),
              // ── Tab Content ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: _isObligations
                      ? [
                          DetailSummaryTab(instrument: widget.instrument),
                          _orderBook != null
                              ? DetailOrderBookTab(orderBook: _orderBook!)
                              : _buildTabLoading(),
                          _transactions != null
                              ? DetailTransactionsTab(
                                  transactions: _transactions!)
                              : _buildTabLoading(),
                        ]
                      : _isLignesSecondaires
                      ? [
                          DetailSummaryTab(instrument: widget.instrument),
                          _orderBook != null
                              ? DetailOrderBookTab(orderBook: _orderBook!)
                              : _buildTabLoading(),
                          _transactions != null
                              ? DetailTransactionsTab(
                                  transactions: _transactions!)
                              : _buildTabLoading(),
                          _publications != null
                              ? DetailPublicationsTab(
                                  publications: _publications!)
                              : _buildTabLoading(),
                        ]
                      : [
                          DetailSummaryTab(instrument: widget.instrument),
                          _orderBook != null
                              ? DetailOrderBookTab(orderBook: _orderBook!)
                              : _buildTabLoading(),
                          _chartData != null
                              ? DetailChartTab(
                                  instrument: widget.instrument,
                                  chartData: _chartData!,
                                )
                              : _buildTabLoading(),
                          _transactions != null
                              ? DetailTransactionsTab(
                                  transactions: _transactions!)
                              : _buildTabLoading(),
                          _publications != null
                              ? DetailPublicationsTab(
                                  publications: _publications!)
                              : _buildTabLoading(),
                        ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // ── Drag Handle ──
  // ═══════════════════════════════════════
  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 2),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // ── Premium Gradient Header ──
  // ═══════════════════════════════════════
  Widget _buildPremiumHeader() {
    final inst = widget.instrument;
    final isPos = inst.isPositive;
    final varColor = isPos ? AppColors.bullGreen : AppColors.bearRed;
    final isBond = _isBondMarket;
    final isHorsCote = _isHorsCote;
    final showBondHeader = isBond || isHorsCote;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.deepNavy,
            AppColors.primaryBlue,
            AppColors.primaryBlueDark,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Name + Mnémo + Close
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mnemo badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white15,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  inst.mnemo,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: inst.statut == 'Open'
                      ? AppColors.bullGreen.withValues(alpha: 0.2)
                      : AppColors.bearRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      inst.statut == 'Open'
                          ? Icons.lock_open_rounded
                          : Icons.lock_rounded,
                      size: 10,
                      color: inst.statut == 'Open'
                          ? AppColors.bullGreen
                          : AppColors.bearRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      inst.statut,
                      style: AppTypography.labelSmall.copyWith(
                        color: inst.statut == 'Open'
                            ? AppColors.bullGreen
                            : AppColors.bearRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Close button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.white15,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Company name
          Text(
            inst.valeur,
            style: AppTypography.onPrimaryBody.copyWith(
              color: AppColors.white80,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          // Row 2: Price + Variation + Mini sparkline (or bond-style for bonds/hors cote)
          if (showBondHeader) ..._buildBondPriceRow(inst, isHorsCote) else ..._buildStockPriceRow(inst, varColor, isPos),
          const SizedBox(height: 10),
          // Quick stats row
          if (!showBondHeader) _buildQuickStats(),
        ],
      ),
    );
  }

  /// Bond / Hors Cote price row — Dernier Cours / Var as "-" + badge
  List<Widget> _buildBondPriceRow(InstrumentEntity inst, bool isHorsCote) {
    return [
      Row(
        children: [
          // Dernier Cours box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white10,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.white15, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dernier Cours',
                      style: AppTypography.onPrimaryMuted.copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inst.dernier != 0 ? inst.dernier.toStringAsFixed(3) : '-',
                      style: AppTypography.indexValue.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Var',
                      style: AppTypography.onPrimaryMuted.copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inst.variation != 0
                          ? '${inst.variation >= 0 ? '+' : ''}${inst.variation.toStringAsFixed(2)}%'
                          : '-',
                      style: AppTypography.onPrimaryBody.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Badge: VOIR PROFIL for Hors Cote, PROFIL INDISPONIBLE for bonds
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white10,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.white15, width: 1),
            ),
            child: Text(
              isHorsCote ? 'VOIR PROFIL DE LA SOCIÉTÉ' : 'PROFIL INDISPONIBLE',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  /// Stock price row — normal Dernier Cours + Variation + Sparkline
  List<Widget> _buildStockPriceRow(
      InstrumentEntity inst, Color varColor, bool isPos) {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dernier Cours',
                style: AppTypography.onPrimaryMuted.copyWith(
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                inst.dernier.toStringAsFixed(3),
                style: AppTypography.indexValue.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Variation badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: varColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPos
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 16,
                  color: varColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${inst.variation >= 0 ? '+' : ''}${inst.variation.toStringAsFixed(2)}%',
                  style: AppTypography.changePercent.copyWith(
                    color: varColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Mini sparkline placeholder
          _buildMiniSparkline(varColor),
        ],
      ),
    ];
  }

  /// Mini sparkline visuel (pure custom paint)
  Widget _buildMiniSparkline(Color color) {
    return SizedBox(
      width: 60,
      height: 30,
      child: CustomPaint(
        painter: _SparklinePainter(
          color: color,
          variation: widget.instrument.variation,
        ),
      ),
    );
  }

  /// Quick stats (Ouv, Haut, Bas, Vol)
  Widget _buildQuickStats() {
    final inst = widget.instrument;
    final stats = [
      _QStat('Ouv.', inst.ouverture.toStringAsFixed(2)),
      _QStat('Haut', inst.plusHaut.toStringAsFixed(2)),
      _QStat('Bas', inst.plusBas.toStringAsFixed(2)),
      _QStat('Vol.', _fmtVol(inst.quantite)),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Column(
              children: [
                Text(
                  s.label,
                  style: AppTypography.onPrimaryMuted.copyWith(fontSize: 9.5),
                ),
                const SizedBox(height: 2),
                Text(
                  s.value,
                  style: AppTypography.onPrimaryBody.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _fmtVol(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return '$v';
  }

  // ═══════════════════════════════════════
  // ── Premium TabBar with icons ──
  // ═══════════════════════════════════════
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.textSecondary.withValues(alpha: 0.6),
        labelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        indicatorColor: AppColors.primaryBlue,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(
          AppColors.primaryBlue.withValues(alpha: 0.04),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        tabs: List.generate(_tabLabels.length, (i) {
          return Tab(
            height: 42,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_tabIcons[i], size: 14),
                const SizedBox(width: 5),
                Text(_tabLabels[i]),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════
  // ── Premium Shimmer Loading ──
  // ═══════════════════════════════════════
  Widget _buildTabLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.divider.withValues(alpha: 0.2),
      highlightColor: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fake header
            Container(
              height: 20,
              width: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            // Fake rows
            ...List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 10,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// ── Mini Sparkline Painter ──
// ==========================================================================
class _SparklinePainter extends CustomPainter {
  final Color color;
  final double variation;

  _SparklinePainter({required this.color, required this.variation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Generate mini points based on variation seed
    final rng = variation.abs() * 1000;
    final points = <Offset>[];
    final steps = 10;
    for (var i = 0; i <= steps; i++) {
      final x = (size.width / steps) * i;
      final noise = ((rng + i * 37) % 17) / 17;
      final trend = variation >= 0 ? (i / steps) * 0.4 : -(i / steps) * 0.4;
      final y = size.height * (0.3 + noise * 0.4 - trend);
      points.add(Offset(x, y.clamp(2, size.height - 2)));
    }

    // Draw path
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      path.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(path, paint);

    // Gradient fill below
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // End dot
    canvas.drawCircle(
      points.last,
      2.5,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Helpers ──
class _QStat {
  final String label;
  final String value;
  const _QStat(this.label, this.value);
}
