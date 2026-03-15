import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/instrument_entity.dart';

// ==========================================================================
// DetailSummaryTab — Résumé premium 10/10
// Animated rows, gradient accents, icons, rich formatting
// ==========================================================================
class DetailSummaryTab extends StatelessWidget {
  final InstrumentEntity instrument;

  const DetailSummaryTab({super.key, required this.instrument});

  @override
  Widget build(BuildContext context) {
    final isBond =
        instrument.market == InstrumentMarket.lignesSecondaires ||
        instrument.market == InstrumentMarket.obligations ||
        instrument.market == InstrumentMarket.marcheHorsCote;

    final rows = <_SR>[
      _SR('Dernier Cours', _fmt(instrument.dernier), Icons.paid_outlined, null),
      _SR("Cours d'ouverture", _fmt(instrument.ouverture),
          Icons.lock_open_outlined, null),
      _SR('Cours de Référence', _fmt(instrument.coursRef),
          Icons.bookmark_outline_rounded, null),
      _SR('Plus Haut', _fmt(instrument.plusHaut),
          Icons.arrow_upward_rounded, AppColors.bullGreen),
      _SR('Plus Bas', _fmt(instrument.plusBas),
          Icons.arrow_downward_rounded, AppColors.bearRed),
      _SR('Capitaux échangés', _fmtLarge(instrument.capitaux),
          Icons.account_balance_outlined, null),
      _SR('Quantité', _fmtInt(instrument.quantite),
          Icons.inventory_2_outlined, null),
      _SR('Nombre de transactions', '${instrument.nbTransactions}',
          Icons.swap_horiz_rounded, null),
      if (!isBond) ...[
        _SR('Seuil Haut', _fmt(instrument.seuilHaut),
            Icons.vertical_align_top_rounded, AppColors.bullGreen),
        _SR('Seuil Bas', _fmt(instrument.seuilBas),
            Icons.vertical_align_bottom_rounded, AppColors.bearRed),
        _SR('Capit. Blocs',
            instrument.capitBlocs != null ? _fmtLarge(instrument.capitBlocs!) : '—',
            Icons.layers_outlined, AppColors.accentOrange),
        _SR('Qté Blocs',
            instrument.qteBlocs != null ? _fmtInt(instrument.qteBlocs!) : '—',
            Icons.inventory_outlined, AppColors.accentOrange),
        _SR('Nb. Trans. Blocs',
            instrument.nbTransBlocs != null ? '${instrument.nbTransBlocs}' : '—',
            Icons.swap_calls_rounded, AppColors.accentOrange),
      ],
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: rows.length + 1, // +1 for header card
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeaderCard();
        final row = rows[index - 1];
        final i = index - 1;
        return TweenAnimationBuilder<double>(
          key: ValueKey(i),
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + i * 60),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _buildRow(row, i),
        );
      },
    );
  }

  Widget _buildHeaderCard() {
    final isBond =
        instrument.market == InstrumentMarket.lignesSecondaires ||
        instrument.market == InstrumentMarket.obligations ||
        instrument.market == InstrumentMarket.marcheHorsCote;
    final hasPrice = instrument.dernier != 0;
    final isPos = instrument.isPositive;
    final color = isPos ? AppColors.bullGreen : AppColors.bearRed;
    final diff = instrument.dernier - instrument.coursRef;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Price block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBond ? 'Cours de Référence' : 'Prix actuel',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isBond
                      ? (instrument.coursRef != 0
                          ? '${instrument.coursRef.toStringAsFixed(3)} TND'
                          : '-')
                      : '${instrument.dernier.toStringAsFixed(3)} TND',
                  style: AppTypography.stockPrice.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          // Change block (hidden for bonds with no data)
          if (!isBond || hasPrice)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPos
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${instrument.variation >= 0 ? '+' : ''}${instrument.variation.toStringAsFixed(2)}%',
                        style: AppTypography.changePercentSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(3)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRow(_SR row, int index) {
    final isEven = index % 2 == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: isEven ? AppColors.cardBackground : AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: (row.valueColor ?? AppColors.primaryBlue)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              row.icon,
              size: 14,
              color: (row.valueColor ?? AppColors.primaryBlue)
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 12),
          // Label
          Expanded(
            child: Text(
              row.label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          // Value
          Text(
            row.value,
            style: AppTypography.titleSmall.copyWith(
              color: row.valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) => v == 0 ? '—' : v.toStringAsFixed(3);

  String _fmtInt(int v) {
    if (v == 0) return '—';
    final str = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  String _fmtLarge(double v) {
    if (v == 0) return '—';
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)} M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)} K';
    return v.toStringAsFixed(0);
  }
}

class _SR {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  const _SR(this.label, this.value, this.icon, this.valueColor);
}
