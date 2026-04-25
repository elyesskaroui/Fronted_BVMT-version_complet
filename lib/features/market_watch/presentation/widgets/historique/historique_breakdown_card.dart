import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../domain/entities/historique_entity.dart';

/// V4 Statistiques Vectorielles — Animated donut chart center piece,
/// radial segment drawing, hover-style legend tiles, premium layout
class HistoriqueBreakdownCard extends StatefulWidget {
  final HistoriqueSessionEntity session;

  const HistoriqueBreakdownCard({super.key, required this.session});

  @override
  State<HistoriqueBreakdownCard> createState() =>
      _HistoriqueBreakdownCardState();
}

class _HistoriqueBreakdownCardState extends State<HistoriqueBreakdownCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(350.ms, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final total = s.nbHausses + s.nbBaisses + s.nbInchangees;
    if (total == 0) return const SizedBox.shrink();

    final segments = [
      _Segment(
        label: 'Hausses',
        count: s.nbHausses,
        fraction: s.nbHausses / total,
        color: AppColors.bullGreen,
        gradient: const [Color(0xFF27AE60), Color(0xFF2ECC71)],
        icon: Icons.trending_up_rounded,
      ),
      _Segment(
        label: 'Baisses',
        count: s.nbBaisses,
        fraction: s.nbBaisses / total,
        color: AppColors.bearRed,
        gradient: const [Color(0xFFE74C3C), Color(0xFFEF5350)],
        icon: Icons.trending_down_rounded,
      ),
      _Segment(
        label: 'Inchangées',
        count: s.nbInchangees,
        fraction: s.nbInchangees / total,
        color: AppColors.warningYellow,
        gradient: const [Color(0xFFF39C12), Color(0xFFFFB74D)],
        icon: Icons.trending_flat_rounded,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.07),
              blurRadius: 28,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ══════════════════════════════════════
            // ── HEADER ──
            // ══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryBlue.withValues(alpha: 0.12),
                          AppColors.primaryBlue.withValues(alpha: 0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.donut_small_rounded,
                      size: 18,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistiques Vectorielles',
                          style: AppTypography.titleLarge.copyWith(
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Répartition du marché',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Total badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      '$total titres',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ══════════════════════════════════════
            // ── DONUT CHART + CENTER LABEL ──
            // ══════════════════════════════════════
            SizedBox(
              height: 150,
              child: Row(
                children: [
                  // Donut
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: SizedBox(
                        width: 130,
                        height: 130,
                        child: _AnimatedBuilder(
                          listenable: _anim,
                          builder: (context, _) => CustomPaint(
                            painter: _DonutPainter(
                              segments: segments,
                              progress: _anim.value,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$total',
                                    style: AppTypography.h2.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 26,
                                      color: AppColors.textPrimary,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    'titres',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Mini legend
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: segments.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final seg = entry.value;
                          return _MiniLegendItem(
                            segment: seg,
                            delay: idx,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 400.ms),

            // Subtle divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primaryBlue.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ══════════════════════════════════════
            // ── DETAIL TILES ──
            // ══════════════════════════════════════
            ...segments.asMap().entries.map((entry) {
              final idx = entry.key;
              final seg = entry.value;
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, idx < 2 ? 10 : 16),
                child: _DetailTile(segment: seg, animation: _anim),
              )
                  .animate()
                  .fadeIn(delay: (250 + idx * 100).ms, duration: 350.ms)
                  .slideY(
                      begin: 0.04,
                      end: 0,
                      delay: (250 + idx * 100).ms,
                      duration: 350.ms);
            }),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Data model
// ──────────────────────────────────────────────
class _Segment {
  final String label;
  final int count;
  final double fraction;
  final Color color;
  final List<Color> gradient;
  final IconData icon;

  const _Segment({
    required this.label,
    required this.count,
    required this.fraction,
    required this.color,
    required this.gradient,
    required this.icon,
  });
}

// ──────────────────────────────────────────────
// Donut chart CustomPainter
// ──────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final List<_Segment> segments;
  final double progress;

  _DonutPainter({required this.segments, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 18.0;
    const gap = 0.04; // radians gap between segments

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFF0F1F5)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Draw segments
    double startAngle = -math.pi / 2;
    for (final seg in segments) {
      final sweep = 2 * math.pi * seg.fraction * progress - gap;
      if (sweep <= 0) {
        startAngle += 2 * math.pi * seg.fraction * progress;
        continue;
      }

      final rect = Rect.fromCircle(center: center, radius: radius);

      // Gradient shader for each arc
      final gradient = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweep,
        colors: seg.gradient,
      );

      final paint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..shader = gradient.createShader(rect);

      canvas.drawArc(rect, startAngle, sweep, false, paint);

      // Glow effect
      final glowPaint = Paint()
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = seg.color.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(rect, startAngle, sweep, false, glowPaint);

      startAngle += 2 * math.pi * seg.fraction * progress;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress;
}

// ──────────────────────────────────────────────
// Mini legend next to the donut
// ──────────────────────────────────────────────
class _MiniLegendItem extends StatelessWidget {
  final _Segment segment;
  final int delay;

  const _MiniLegendItem({required this.segment, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: segment.gradient,
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: segment.color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              segment.label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${(segment.fraction * 100).toStringAsFixed(0)}%',
            style: AppTypography.labelMedium.copyWith(
              color: segment.color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (400 + delay * 120).ms, duration: 300.ms)
        .slideX(begin: 0.08, end: 0, delay: (400 + delay * 120).ms, duration: 300.ms);
  }
}

// ──────────────────────────────────────────────
// Detail tile — expanded stat row with gradient progress bar
// ──────────────────────────────────────────────
class _DetailTile extends StatelessWidget {
  final _Segment segment;
  final Animation<double> animation;

  const _DetailTile({required this.segment, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: segment.color.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: segment.color.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          // Left accent + icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  segment.color.withValues(alpha: 0.15),
                  segment.color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(segment.icon, size: 18, color: segment.color),
          ),
          const SizedBox(width: 12),
          // Label + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      segment.label,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: segment.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${(segment.fraction * 100).toStringAsFixed(0)}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: segment.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${segment.count}',
                      style: AppTypography.titleMedium.copyWith(
                        color: segment.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Animated gradient progress bar
                _AnimatedBuilder(
                  listenable: animation,
                  builder: (context, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 5,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: segment.color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: segment.fraction * animation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: segment.gradient,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: segment.color.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }
}

/// Reusable AnimatedBuilder for listenable-driven rebuilds
class _AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const _AnimatedBuilder({
    required Animation super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => builder(context, null);
}
