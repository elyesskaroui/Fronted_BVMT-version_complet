import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/instrument_entity.dart';
import 'instrument_detail_sheet.dart';

// ==========================================================================
// InstrumentStockTable — Card-based premium mobile design
// Professional stock list with expandable details
// ==========================================================================
class InstrumentStockTable extends StatefulWidget {
  final List<InstrumentEntity> instruments;
  final String sortColumn;
  final bool sortAscending;
  final void Function(String column, bool ascending) onSort;

  const InstrumentStockTable({
    super.key,
    required this.instruments,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  State<InstrumentStockTable> createState() => _InstrumentStockTableState();
}

class _InstrumentStockTableState extends State<InstrumentStockTable> {
  int? _expandedIndex;

  static const _sortOptions = <_SortOption>[
    _SortOption('mnemo', 'A-Z', Icons.sort_by_alpha_rounded),
    _SortOption('variation', 'Var %', Icons.trending_up_rounded),
    _SortOption('dernier', 'Prix', Icons.attach_money_rounded),
    _SortOption('capitaux', 'Cap.', Icons.bar_chart_rounded),
    _SortOption('quantite', 'Vol.', Icons.show_chart_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Sort Chips ──
        _buildSortBar(),
        const SizedBox(height: 6),
        // ── Card List ──
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            physics: const BouncingScrollPhysics(),
            itemCount: widget.instruments.length,
            itemBuilder: (context, index) {
              final instrument = widget.instruments[index];
              final isExpanded = _expandedIndex == index;
              return _InstrumentCard(
                instrument: instrument,
                isExpanded: isExpanded,
                onTap: () {
                  setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // ── Sort Chip Bar ──
  // ═══════════════════════════════════════════
  Widget _buildSortBar() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _sortOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final opt = _sortOptions[index];
          final isActive = widget.sortColumn == opt.key;
          return GestureDetector(
            onTap: () {
              if (isActive) {
                widget.onSort(opt.key, !widget.sortAscending);
              } else {
                widget.onSort(opt.key, true);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.accentOrange.withValues(alpha: 0.12)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.accentOrange
                      : AppColors.divider,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    opt.icon,
                    size: 14,
                    color: isActive
                        ? AppColors.accentOrange
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    opt.label,
                    style: AppTypography.labelSmall.copyWith(
                      color: isActive
                          ? AppColors.accentOrange
                          : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 11.5,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 3),
                    Icon(
                      widget.sortAscending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 12,
                      color: AppColors.accentOrange,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================================================
// ── Instrument Card ──
// Expandable card with main info + detailed breakdown
// ==========================================================================
class _InstrumentCard extends StatelessWidget {
  final InstrumentEntity instrument;
  final bool isExpanded;
  final VoidCallback onTap;

  const _InstrumentCard({
    required this.instrument,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? AppColors.accentOrange.withValues(alpha: 0.35)
                : AppColors.divider.withValues(alpha: 0.5),
            width: isExpanded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isExpanded
                  ? AppColors.accentOrange.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isExpanded ? 12 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Main Row ──
            _buildMainRow(),
            // ── Expanded Details ──
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedContent(context),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // ── Main Row (always visible) ──
  // ═══════════════════════════════════════
  Widget _buildMainRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          // Left: Symbol + Name + Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Mnémo
                    Text(
                      instrument.mnemo,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status badge
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  instrument.valeur,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right: Price + Variation
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(instrument.dernier),
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              _buildVariationBadge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isOpen = instrument.statut == 'Open';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isOpen
            ? AppColors.bullGreen.withValues(alpha: 0.1)
            : AppColors.bearRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
            size: 10,
            color: isOpen ? AppColors.bullGreen : AppColors.bearRed,
          ),
          const SizedBox(width: 3),
          Text(
            instrument.statut,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isOpen ? AppColors.bullGreen : AppColors.bearRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationBadge() {
    final isPos = instrument.isPositive;
    final isNeg = instrument.isNegative;
    final color = isPos
        ? AppColors.bullGreen
        : isNeg
            ? AppColors.bearRed
            : AppColors.textSecondary;
    final bgColor = isPos
        ? AppColors.bullGreen.withValues(alpha: 0.1)
        : isNeg
            ? AppColors.bearRed.withValues(alpha: 0.1)
            : AppColors.textSecondary.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPos
                ? Icons.trending_up_rounded
                : isNeg
                    ? Icons.trending_down_rounded
                    : Icons.trending_flat_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            '${instrument.variation >= 0 ? '+' : ''}${instrument.variation.toStringAsFixed(2)}%',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // ── Expanded Content ──
  // ═══════════════════════════════════════
  Widget _buildExpandedContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        children: [
          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 12),
            color: AppColors.divider.withValues(alpha: 0.5),
          ),
          // Achat / Vente boxes
          _buildAchatVenteRow(),
          const SizedBox(height: 12),
          // Details grid
          _buildDetailsGrid(),
          const SizedBox(height: 10),
          // Seuils row
          _buildSeuilRow(),
          const SizedBox(height: 8),
          // Blocs row (only if data exists)
          if (instrument.capitBlocs != null ||
              instrument.qteBlocs != null ||
              instrument.nbTransBlocs != null)
            _buildBlocsRow(),
          if (instrument.capitBlocs != null ||
              instrument.qteBlocs != null ||
              instrument.nbTransBlocs != null)
            const SizedBox(height: 12),
          if (instrument.capitBlocs == null &&
              instrument.qteBlocs == null &&
              instrument.nbTransBlocs == null)
            const SizedBox(height: 12),
          // Voir détail button
          _buildDetailButton(context),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // ── Achat / Vente Boxes ──
  // ═══════════════════════════════════════
  Widget _buildAchatVenteRow() {
    return Row(
      children: [
        // Achat (Buy)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.bullGreen.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.bullGreen.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 12,
                      color: AppColors.bullGreen.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'ACHAT',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.bullGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 9.5,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(instrument.achat),
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.bullGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Qté: ${_formatInt(instrument.qteAchat)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.bullGreen.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Vente (Sell)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.bearRed.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.bearRed.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 12,
                      color: AppColors.bearRed.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'VENTE',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.bearRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 9.5,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(instrument.vente),
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.bearRed,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Qté: ${_formatInt(instrument.qteVente)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.bearRed.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // ── Details Grid (2 columns) ──
  // ═══════════════════════════════════════
  Widget _buildDetailsGrid() {
    final details = [
      _DetailItem('Cours Réf.', _formatPrice(instrument.coursRef)),
      _DetailItem('Ouverture', _formatPrice(instrument.ouverture)),
      _DetailItem('Plus Haut', _formatPrice(instrument.plusHaut)),
      _DetailItem('Plus Bas', _formatPrice(instrument.plusBas)),
      _DetailItem('Capitaux', _formatLargeNumber(instrument.capitaux)),
      _DetailItem('Quantité', _formatInt(instrument.quantite)),
      _DetailItem('Nb Trans.', '${instrument.nbTransactions}'),
      _DetailItem('Dernier', _formatPrice(instrument.dernier)),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < details.length; i += 2) {
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 < details.length ? 1 : 0),
          child: Row(
            children: [
              _buildDetailCell(details[i], i),
              if (i + 1 < details.length) _buildDetailCell(details[i + 1], i + 1),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }

  Widget _buildDetailCell(_DetailItem item, int index) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.3),
              width: 0.5,
            ),
            right: index.isEven
                ? BorderSide(
                    color: AppColors.divider.withValues(alpha: 0.3),
                    width: 0.5,
                  )
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              item.value,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // ── Seuils (Thresholds) Row ──
  // ═══════════════════════════════════════
  Widget _buildSeuilRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            size: 14,
            color: AppColors.primaryBlue.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 6),
          Text(
            'Seuils',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
          ),
          const Spacer(),
          // Seuil Bas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.bearRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_downward_rounded,
                  size: 10,
                  color: AppColors.bearRed.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 2),
                Text(
                  _formatPrice(instrument.seuilBas),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.bearRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Seuil Haut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.bullGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_upward_rounded,
                  size: 10,
                  color: AppColors.bullGreen.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 2),
                Text(
                  _formatPrice(instrument.seuilHaut),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.bullGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // ── Blocs Row ──
  // ═══════════════════════════════════════
  Widget _buildBlocsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.accentOrange.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.layers_outlined,
            size: 14,
            color: AppColors.accentOrange.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 6),
          Text(
            'Blocs',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.accentOrange,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
          ),
          const Spacer(),
          // Capit. Blocs
          _buildBlocBadge(
            'Cap.',
            instrument.capitBlocs != null
                ? _formatLargeNumber(instrument.capitBlocs!)
                : '—',
          ),
          const SizedBox(width: 6),
          // Qté Blocs
          _buildBlocBadge(
            'Qté',
            instrument.qteBlocs != null
                ? _formatInt(instrument.qteBlocs!)
                : '—',
          ),
          const SizedBox(width: 6),
          // Nb Trans. Blocs
          _buildBlocBadge(
            'Trans.',
            instrument.nbTransBlocs != null
                ? '${instrument.nbTransBlocs}'
                : '—',
          ),
        ],
      ),
    );
  }

  Widget _buildBlocBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.accentOrange.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              fontSize: 9,
            ),
          ),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.accentOrange,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // ── Voir Détail Button ──
  // ═══════════════════════════════════════
  Widget _buildDetailButton(BuildContext context) {
    return GestureDetector(
      onTap: () => InstrumentDetailSheet.show(context, instrument),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlue.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.visibility_outlined,
              size: 15,
              color: AppColors.textOnPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              'Voir détail',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: AppColors.textOnPrimary,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // ── Formatters ──
  // ═══════════════════════════════════════
  String _formatPrice(double price) {
    if (price == 0) return '—';
    return price.toStringAsFixed(3);
  }

  String _formatInt(int value) {
    if (value == 0) return '—';
    final str = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  String _formatLargeNumber(double value) {
    if (value == 0) return '—';
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}

// ==========================================================================
// ── Helper Classes ──
// ==========================================================================
class _SortOption {
  final String key;
  final String label;
  final IconData icon;
  const _SortOption(this.key, this.label, this.icon);
}

class _DetailItem {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);
}
