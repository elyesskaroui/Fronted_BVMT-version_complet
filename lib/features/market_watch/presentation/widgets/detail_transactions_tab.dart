import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/instrument_detail_models.dart';

// ==========================================================================
// DetailTransactionsTab — Onglet Transactions premium 10/10
// Animated rows, rich colors, badges, timeline feel
// ==========================================================================
class DetailTransactionsTab extends StatelessWidget {
  final List<StockTransaction> transactions;

  const DetailTransactionsTab({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Empty state for instruments with no transactions (Lignes Secondaires)
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 28,
                color: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune transaction disponible pour cet instrument',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── Summary bar ──
        _buildSummary(),
        // ── Header ──
        _buildHeader(),
        Container(
          height: 1.5,
          color: AppColors.accentOrange.withValues(alpha: 0.2),
        ),
        // ── Rows ──
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            physics: const BouncingScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                key: ValueKey(index),
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 250 + index * 40),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: _buildRow(transactions[index], index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    double totalCap = 0;
    int totalQty = 0;
    for (final tx in transactions) {
      totalCap += tx.capitauxEchanges;
      totalQty += tx.quantite;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _summaryChip(
              '${transactions.length}', 'Transactions', AppColors.accentOrange),
          const SizedBox(width: 12),
          Container(
              width: 1,
              height: 24,
              color: AppColors.divider.withValues(alpha: 0.3)),
          const SizedBox(width: 12),
          _summaryChip('$totalQty', 'Titres', AppColors.primaryBlue),
          const SizedBox(width: 12),
          Container(
              width: 1,
              height: 24,
              color: AppColors.divider.withValues(alpha: 0.3)),
          const SizedBox(width: 12),
          Expanded(
            child: _summaryChip(
                _fmtLarge(totalCap), 'Capitaux', AppColors.bullGreen),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.scaffoldBackground,
      child: Row(
        children: [
          _hCell('Heure', flex: 2),
          _hCell('Qté', flex: 1),
          _hCell('Prix', flex: 2),
          _hCell('Capitaux', flex: 2),
          _hCell('Type', flex: 2),
        ],
      ),
    );
  }

  Widget _hCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.6),
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildRow(StockTransaction tx, int index) {
    final isEven = index % 2 == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEven
            ? AppColors.cardBackground
            : AppColors.scaffoldBackground.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Heure with clock icon
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 10,
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 3),
                Text(
                  tx.heure,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Quantité (red accent)
          Expanded(
            flex: 1,
            child: Text(
              '${tx.quantite}',
              textAlign: TextAlign.center,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.bearRed,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          // Prix
          Expanded(
            flex: 2,
            child: Text(
              tx.prix.toStringAsFixed(3),
              textAlign: TextAlign.center,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          // Capitaux
          Expanded(
            flex: 2,
            child: Text(
              _fmtLarge(tx.capitauxEchanges),
              textAlign: TextAlign.center,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          // Type badge
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tx.typeTransaction == 'COC'
                      ? AppColors.primaryBlue.withValues(alpha: 0.08)
                      : AppColors.accentOrange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: tx.typeTransaction == 'COC'
                        ? AppColors.primaryBlue.withValues(alpha: 0.15)
                        : AppColors.accentOrange.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  tx.typeTransaction,
                  style: AppTypography.labelSmall.copyWith(
                    color: tx.typeTransaction == 'COC'
                        ? AppColors.primaryBlue
                        : AppColors.accentOrange,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtLarge(double v) {
    if (v == 0) return '—';
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v >= 10000 ? 0 : 1)}K';
    return v.toStringAsFixed(0);
  }
}
