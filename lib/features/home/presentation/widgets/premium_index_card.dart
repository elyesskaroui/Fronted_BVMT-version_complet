import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/market_summary_entity.dart';


class PremiumIndexCard extends StatefulWidget {
  final IndexData index;
  final VoidCallback? onTap;

  const PremiumIndexCard({super.key, required this.index, this.onTap});

  @override
  State<PremiumIndexCard> createState() => _PremiumIndexCardState();
}

class _PremiumIndexCardState extends State<PremiumIndexCard>
    with TickerProviderStateMixin {
  late final AnimationController _borderController;
  late final AnimationController _shimmerController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _borderController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleController.forward();

  void _onTapUp(TapUpDetails _) {
    _scaleController.reverse();
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  void _onTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    final index = widget.index;
    final positive = index.changePercent >= 0;
    // Accessible colors: teal-green for positive, orange-red for negative
    final statusColor =
        positive ? const Color(0xFF00BFA5) : const Color(0xFFFF6D00);
    final arrowIcon = positive
        ? Icons.arrow_drop_up_rounded
        : Icons.arrow_drop_down_rounded;

    return Tooltip(
      message: 'Voir l\'évolution du ${index.name}',
      preferBelow: false,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _borderController,
            _shimmerController,
            _pulseAnimation,
            _scaleAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: CustomPaint(
                painter: _CardBorderPainter(
                  progress: _borderController.value,
                  pulseValue: _pulseAnimation.value,
                ),
                child: child,
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // ── 1) Unified dark card background ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B2A4A), Color(0xFF0F1E36)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFF0F1E36).withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top row: Name badge + chevron ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              index.name,
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Main value ──
                      Text(
                        index.formattedValue,
                        style: AppTypography.indexValue.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Daily change pill — with ▲/▼ icon ──
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        constraints: const BoxConstraints(minHeight: 28),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(arrowIcon, size: 20, color: statusColor),
                            const SizedBox(width: 2),
                            Text(
                              index.formattedChange,
                              style:
                                  AppTypography.changePercentSmall.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Annual change ──
                      Row(
                        children: [
                          Text(
                            'Ann. ',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                          Icon(
                            index.yearChangePercent >= 0
                                ? Icons.north_east_rounded
                                : Icons.south_east_rounded,
                            size: 12,
                            color: index.yearChangePercent >= 0
                                ? const Color(0xFF00BFA5)
                                : const Color(0xFFFF6D00),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            index.formattedYearChange,
                            style: AppTypography.labelMedium.copyWith(
                              color: index.yearChangePercent >= 0
                                  ? const Color(0xFF00BFA5)
                                  : const Color(0xFFFF6D00),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── 2) Diagonal shimmer sweep ──
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, _) {
                        final progress = _shimmerController.value;
                        final alignX = -1.5 + progress * 3.0;
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              begin: Alignment(alignX, -0.3),
                              end: Alignment(alignX + 1.0, 0.3),
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.04),
                                Colors.white.withValues(alpha: 0.08),
                                Colors.white.withValues(alpha: 0.04),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                            ),
                          ),
                        );
                      },
                    ),
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

/// ── Animated border painter with rotating gradient + pulse glow ──
class _CardBorderPainter extends CustomPainter {
  final double progress;
  final double pulseValue;

  _CardBorderPainter({required this.progress, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1),
      const Radius.circular(18),
    );

    final angle = progress * 2 * math.pi;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = SweepGradient(
        startAngle: angle,
        endAngle: angle + 2 * math.pi,
        colors: [
          Colors.white.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.25 + pulseValue * 0.15),
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.30 + pulseValue * 0.15),
          Colors.white.withValues(alpha: 0.05),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        tileMode: TileMode.clamp,
      ).createShader(rect);

    canvas.drawRRect(rrect, borderPaint);

    final glowOpacity = 0.04 + pulseValue * 0.06;
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..color = const Color(0xFF0D4FA8).withValues(alpha: glowOpacity);

    canvas.drawRRect(rrect, glowPaint);
  }

  @override
  bool shouldRepaint(_CardBorderPainter old) => true;
}
