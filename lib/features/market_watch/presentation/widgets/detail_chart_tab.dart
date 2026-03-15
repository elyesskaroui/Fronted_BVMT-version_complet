import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/datasources/instrument_detail_mock_datasource.dart';
import '../../domain/entities/instrument_entity.dart';

// ==========================================================================
// DetailChartTab — Graphique premium 10/10
// Courbe animée au changement de période, gradient area, crosshair,
// volume bars, period selector, price range, stats grid
// ==========================================================================
class DetailChartTab extends StatefulWidget {
  final InstrumentEntity instrument;
  final List<double> chartData; // données initiales (1M)

  const DetailChartTab({
    super.key,
    required this.instrument,
    required this.chartData,
  });

  @override
  State<DetailChartTab> createState() => _DetailChartTabState();
}

class _DetailChartTabState extends State<DetailChartTab>
    with TickerProviderStateMixin {
  String _selectedPeriod = '1M';
  int? _touchedIndex;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _flashCtrl;
  final _dataSource = InstrumentDetailMockDataSource();

  /// Données actives affichées dans le graphique
  late List<double> _activeData;
  bool _isLoading = false;

  static const _periods = ['1J', '1S', '1M', '3M', '6M', '1A'];

  @override
  void initState() {
    super.initState();
    _activeData = List.of(widget.chartData);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeOutCubic,
    );
    _fadeCtrl.forward();

    // Flash animation — boucle infinie 2.5s
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  /// Change la période et recharge les données avec animation
  Future<void> _onPeriodChanged(String period) async {
    if (period == _selectedPeriod || _isLoading) return;
    HapticFeedback.selectionClick();

    setState(() {
      _selectedPeriod = period;
      _isLoading = true;
      _touchedIndex = null;
    });

    final newData =
        await _dataSource.getChartDataForPeriod(widget.instrument, period);

    if (!mounted) return;

    setState(() {
      _activeData = newData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.instrument.isPositive;
    final chartColor = isPositive ? AppColors.bullGreen : AppColors.bearRed;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Touched Price Info ──
          _buildTouchedInfo(chartColor),
          const SizedBox(height: 12),
          // ── Chart Container with curve animation ──
          FadeTransition(
            opacity: _fadeAnim,
            child: Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: chartColor.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  _buildAnimatedChart(chartColor),
                  // ── Flash lumineux sur la courbe ──
                  if (!_isLoading)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _flashCtrl,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _CurveFlashPainter(
                              data: _activeData,
                              progress: _flashCtrl.value,
                              color: chartColor,
                              leftPadding: 48,
                              topPadding: 16,
                              bottomPadding: 8,
                              rightPadding: 0,
                            ),
                          );
                        },
                      ),
                    ),
                  // Loading overlay
                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              AppColors.cardBackground.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(chartColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ── Period Selector ──
          _buildPeriodSelector(chartColor),
          const SizedBox(height: 14),
          // ── Period info label ──
          _buildPeriodInfoLabel(),
          const SizedBox(height: 14),
          // ── Volume Bars ──
          _buildVolumeBars(chartColor),
          const SizedBox(height: 16),
          // ── Price Range Bar ──
          _buildPriceRange(chartColor),
          const SizedBox(height: 16),
          // ── Stats Grid ──
          _buildStatsGrid(chartColor),
        ],
      ),
    );
  }

  Widget _buildTouchedInfo(Color color) {
    if (_touchedIndex == null || _touchedIndex! >= _activeData.length) {
      return const SizedBox(height: 24);
    }
    final price = _activeData[_touchedIndex!];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey('$_touchedIndex-$price'),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_rounded, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              '${price.toStringAsFixed(3)} TND',
              style: AppTypography.stockPrice.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Point ${_touchedIndex! + 1}/${_activeData.length}',
              style: AppTypography.labelSmall.copyWith(
                color: color.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chart avec animation de la courbe via fl_chart duration/curve
  Widget _buildAnimatedChart(Color color) {
    final data = _activeData;
    if (data.isEmpty) {
      return const Center(child: Text('Aucune donnée'));
    }

    final minY = data.reduce((a, b) => a < b ? a : b) * 0.998;
    final maxY = data.reduce((a, b) => a > b ? a : b) * 1.002;

    return LineChart(
      // ═══ ANIMATION DE LA COURBE ═══
      // fl_chart anime automatiquement la transition entre 2 LineChartData
      _buildChartData(data, color, minY, maxY),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  LineChartData _buildChartData(
      List<double> data, Color color, double minY, double maxY) {
    return LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.divider.withValues(alpha: 0.25),
          strokeWidth: 0.8,
          dashArray: [4, 4],
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            getTitlesWidget: (value, meta) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                value.toStringAsFixed(1),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontSize: 9,
                ),
              ),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: data
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value))
              .toList(),
          isCurved: true,
          curveSmoothness: 0.3,
          color: color,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              if (index == _touchedIndex) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: AppColors.cardBackground,
                  strokeWidth: 2.5,
                  strokeColor: color,
                );
              }
              if (index == data.length - 1) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: color,
                  strokeWidth: 0,
                );
              }
              return FlDotCirclePainter(
                  radius: 0, color: Colors.transparent);
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.25),
                color.withValues(alpha: 0.05),
                color.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchCallback: (event, response) {
          if (event is FlTapUpEvent ||
              event is FlPanEndEvent ||
              event is FlLongPressEnd) {
            setState(() => _touchedIndex = null);
            return;
          }
          final spots = response?.lineBarSpots;
          if (spots != null && spots.isNotEmpty) {
            final idx = spots.first.spotIndex;
            if (idx != _touchedIndex) {
              HapticFeedback.selectionClick();
              setState(() => _touchedIndex = idx);
            }
          }
        },
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 10,
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          getTooltipItems: (spots) {
            return spots
                .map((s) => LineTooltipItem(
                      s.y.toStringAsFixed(3),
                      TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ))
                .toList();
          },
        ),
        handleBuiltInTouches: true,
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: color.withValues(alpha: 0.3),
                strokeWidth: 1,
                dashArray: [4, 2],
              ),
              FlDotData(show: false),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildPeriodSelector(Color color) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: _periods.map((p) {
          final isActive = p == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onPeriodChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: AppTypography.labelSmall.copyWith(
                      color: isActive
                          ? AppColors.textOnPrimary
                          : AppColors.textSecondary,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    child: Text(p),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Label informatif sous le sélecteur
  Widget _buildPeriodInfoLabel() {
    final labels = {
      '1J': "Aujourd'hui — Évolution heure par heure",
      '1S': '7 derniers jours — Évolution quotidienne',
      '1M': '30 derniers jours — Évolution quotidienne',
      '3M': '3 derniers mois — Évolution bi-quotidienne',
      '6M': '6 derniers mois — Évolution hebdomadaire',
      '1A': '12 derniers mois — Évolution hebdomadaire',
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Row(
        key: ValueKey(_selectedPeriod),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 4),
          Text(
            labels[_selectedPeriod] ?? '',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Volume bars synchronisées avec les données actives
  Widget _buildVolumeBars(Color color) {
    final data = _activeData;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey('vol-$_selectedPeriod'),
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(data.length, (i) {
            final prev = i > 0 ? data[i - 1] : data[i];
            final isUp = data[i] >= prev;
            final barHeight =
                ((data[i] % 10) / 10 * 30 + 4).clamp(4.0, 34.0);
            final isTouch = i == _touchedIndex;

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 0.5),
                height: barHeight,
                decoration: BoxDecoration(
                  color: isTouch
                      ? color
                      : (isUp
                          ? AppColors.bullGreen.withValues(alpha: 0.3)
                          : AppColors.bearRed.withValues(alpha: 0.3)),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Price range (seuil bas ← current ← seuil haut)
  Widget _buildPriceRange(Color color) {
    final inst = widget.instrument;
    final low = inst.plusBas;
    final high = inst.plusHaut;
    final current = inst.dernier;
    final range = high - low;
    final pct = range > 0 ? ((current - low) / range).clamp(0.0, 1.0) : 0.5;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Fourchette du jour",
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                '${low.toStringAsFixed(3)} — ${high.toStringAsFixed(3)}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background track
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.bearRed.withValues(alpha: 0.2),
                          AppColors.warningYellow.withValues(alpha: 0.2),
                          AppColors.bullGreen.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Current position indicator
                  Positioned(
                    left: (pct * trackWidth).clamp(7, trackWidth - 7),
                    child: Container(
                      width: 14,
                      height: 14,
                      transform: Matrix4.translationValues(-7, -4, 0),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.cardBackground, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                low.toStringAsFixed(3),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.bearRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
              Text(
                high.toStringAsFixed(3),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.bullGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Color color) {
    final inst = widget.instrument;
    final stats = [
      _StatCard('Plus Haut', inst.plusHaut.toStringAsFixed(3),
          Icons.arrow_upward_rounded, AppColors.bullGreen),
      _StatCard('Plus Bas', inst.plusBas.toStringAsFixed(3),
          Icons.arrow_downward_rounded, AppColors.bearRed),
      _StatCard(
          'Variation',
          '${inst.variation >= 0 ? '+' : ''}${inst.variation.toStringAsFixed(2)}%',
          inst.isPositive
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded,
          color),
      _StatCard('Capitaux', _fmtLarge(inst.capitaux),
          Icons.account_balance_rounded, AppColors.primaryBlue),
    ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: s.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(s.icon, size: 14, color: s.color),
                ),
                const SizedBox(height: 6),
                Text(
                  s.value,
                  style: AppTypography.labelLarge.copyWith(
                    color: s.color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _fmtLarge(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class _StatCard {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);
}

// ==========================================================================
// _CurveFlashPainter — Dessine un flash lumineux qui se déplace le long
// de la courbe. Le point lumineux glisse de gauche à droite en boucle.
// ==========================================================================
class _CurveFlashPainter extends CustomPainter {
  final List<double> data;
  final double progress; // 0.0 → 1.0
  final Color color;
  final double leftPadding;
  final double topPadding;
  final double bottomPadding;
  final double rightPadding;

  _CurveFlashPainter({
    required this.data,
    required this.progress,
    required this.color,
    this.leftPadding = 48,
    this.topPadding = 16,
    this.bottomPadding = 8,
    this.rightPadding = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    final minY = data.reduce(math.min) * 0.998;
    final maxY = data.reduce(math.max) * 1.002;
    final rangeY = maxY - minY;
    if (rangeY <= 0) return;

    // Construire les points de la courbe (miroir de fl_chart)
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = leftPadding + (i / (data.length - 1)) * chartWidth;
      final y = topPadding + (1 - (data[i] - minY) / rangeY) * chartHeight;
      points.add(Offset(x, y));
    }

    // Calculer la position du flash le long de la courbe
    // Utiliser le path length pour un mouvement régulier
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    // Courbe lissée via cubic bezier (comme fl_chart curveSmoothness 0.3)
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];

      final smoothness = 0.3;
      final cp1x = p1.dx + (p2.dx - p0.dx) * smoothness;
      final cp1y = p1.dy + (p2.dy - p0.dy) * smoothness;
      final cp2x = p2.dx - (p3.dx - p1.dx) * smoothness;
      final cp2y = p2.dy - (p3.dy - p1.dy) * smoothness;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // Mesurer le path et trouver la position du flash
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;

    final totalLength = pathMetrics.first.length;
    final flashPos = progress * totalLength;

    // Point principal du flash
    final tangent = pathMetrics.first.getTangentForOffset(flashPos);
    if (tangent == null) return;

    final flashPoint = tangent.position;

    // ── Dessiner le flash (glow + point brillant) ──

    // 1) Grand halo diffus
    final haloPaint = Paint()
      ..shader = ui.Gradient.radial(
        flashPoint,
        30,
        [
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 0.08),
          color.withValues(alpha: 0.0),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(flashPoint, 30, haloPaint);

    // 2) Halo moyen
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        flashPoint,
        14,
        [
          color.withValues(alpha: 0.5),
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0.0),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(flashPoint, 14, glowPaint);

    // 3) Point central blanc brillant
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(flashPoint, 3.5, corePaint);

    // 4) Point coloré au centre
    final centerPaint = Paint()..color = color;
    canvas.drawCircle(flashPoint, 2, centerPaint);

    // 5) Traînée derrière le flash (trail effect)
    final trailLength = totalLength * 0.12; // 12% du path
    final trailStart = (flashPos - trailLength).clamp(0.0, totalLength);
    final trailPath =
        pathMetrics.first.extractPath(trailStart, flashPos);

    final trailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        tangent.position,
        _getPointOnPath(pathMetrics.first, trailStart) ?? flashPoint,
        [
          color.withValues(alpha: 0.5),
          color.withValues(alpha: 0.0),
        ],
      );
    canvas.drawPath(trailPath, trailPaint);
  }

  Offset? _getPointOnPath(ui.PathMetric metric, double offset) {
    final t = metric.getTangentForOffset(offset);
    return t?.position;
  }

  @override
  bool shouldRepaint(covariant _CurveFlashPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.data != data ||
        oldDelegate.color != color;
  }
}
