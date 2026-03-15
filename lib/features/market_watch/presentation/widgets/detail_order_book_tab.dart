import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/instrument_detail_models.dart';

// ==========================================================================
// DetailOrderBookTab — Carnet d'ordres premium 10/10
// Barres de volume proportionnelles avec gradient, animation
// ==========================================================================
class DetailOrderBookTab extends StatefulWidget {
  final OrderBook orderBook;

  const DetailOrderBookTab({super.key, required this.orderBook});

  @override
  State<DetailOrderBookTab> createState() => _DetailOrderBookTabState();
}

class _DetailOrderBookTabState extends State<DetailOrderBookTab> {
  static const int _collapsedCount = 5;
  bool _expanded = false;

  OrderBook get orderBook => widget.orderBook;

  @override
  Widget build(BuildContext context) {
    // Empty state for instruments with no orders (Lignes Secondaires)
    if (orderBook.ordresAchat.isEmpty && orderBook.ordresVente.isEmpty) {
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
                Icons.menu_book_rounded,
                size: 28,
                color: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun ordre disponible pour cet instrument',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Total summary ──
          _buildTotalSummary(),
          const SizedBox(height: 12),
          // ── Headers ──
          _buildHeaders(),
          const SizedBox(height: 2),
          // ── Gradient separator ──
          Container(
            height: 2.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.bullGreen,
                  AppColors.bullGreen.withValues(alpha: 0.3),
                  AppColors.divider.withValues(alpha: 0.2),
                  AppColors.bearRed.withValues(alpha: 0.3),
                  AppColors.bearRed,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 2),
          // ── Sub Headers ──
          _buildSubHeaders(),
          // ── Data Rows ──
          ...List.generate(_displayRowCount, (i) => _buildRow(i)),
          // ── Voir tout button ──
          if (_canExpand) ...[
            const SizedBox(height: 8),
            Center(child: _buildVoirToutButton()),
          ],
          const SizedBox(height: 12),
          // ── Spread info ──
          _buildSpreadInfo(),
        ],
      ),
    );
  }

  int get _totalRowCount {
    return orderBook.ordresAchat.length > orderBook.ordresVente.length
        ? orderBook.ordresAchat.length
        : orderBook.ordresVente.length;
  }

  int get _displayRowCount {
    if (_expanded) return _totalRowCount;
    return _totalRowCount > _collapsedCount ? _collapsedCount : _totalRowCount;
  }

  bool get _canExpand => _totalRowCount > _collapsedCount;

  Widget _buildTotalSummary() {
    int totalAchat = 0, totalVente = 0;
    for (final o in orderBook.ordresAchat) {
      totalAchat += o.quantite;
    }
    for (final o in orderBook.ordresVente) {
      totalVente += o.quantite;
    }
    final total = totalAchat + totalVente;
    final achatPct = total > 0 ? totalAchat / total : 0.5;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem(
                'Demande totale',
                '$totalAchat',
                AppColors.bullGreen,
                Icons.arrow_downward_rounded,
              ),
              Container(
                width: 1,
                height: 30,
                color: AppColors.divider.withValues(alpha: 0.3),
              ),
              _summaryItem(
                'Offre totale',
                '$totalVente',
                AppColors.bearRed,
                Icons.arrow_upward_rounded,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Balance bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: (achatPct * 100).round(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.bullGreen,
                            AppColors.bullGreen.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: ((1 - achatPct) * 100).round(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.bearRed.withValues(alpha: 0.6),
                            AppColors.bearRed,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(achatPct * 100).toStringAsFixed(1)}%',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.bullGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
              Text(
                '${((1 - achatPct) * 100).toStringAsFixed(1)}%',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.bearRed,
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

  Widget _summaryItem(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 9.5,
                ),
              ),
              Text(
                value,
                style: AppTypography.labelLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaders() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.bullGreen.withValues(alpha: 0.08),
                    AppColors.bullGreen.withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  "ORDRES D'ACHAT",
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.bullGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.bearRed.withValues(alpha: 0.03),
                    AppColors.bearRed.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  'ORDRES DE VENTE',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.bearRed,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _subH('Nb', AppColors.bullGreen),
          _subH('Qté', AppColors.bullGreen),
          _subH('Prix', AppColors.bullGreen, flex: 2),
          _subH('Prix', AppColors.bearRed, flex: 2),
          _subH('Qté', AppColors.bearRed),
          _subH('Nb', AppColors.bearRed),
        ],
      ),
    );
  }

  Widget _subH(String text, Color color, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.labelSmall.copyWith(
          color: color.withValues(alpha: 0.5),
          fontWeight: FontWeight.w600,
          fontSize: 9.5,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildRow(int index) {
    final hasA = index < orderBook.ordresAchat.length;
    final hasV = index < orderBook.ordresVente.length;
    final achat = hasA ? orderBook.ordresAchat[index] : null;
    final vente = hasV ? orderBook.ordresVente[index] : null;
    final maxQ = orderBook.maxQuantite;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // ── Achat side ──
            Expanded(
              child: Stack(
                children: [
                  if (achat != null)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: achat.quantite / maxQ,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.bullGreen.withValues(alpha: 0.02),
                                  AppColors.bullGreen.withValues(alpha: 0.12),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        _dataCell(achat != null ? '${achat.nbrOrdres}' : '',
                            AppColors.textSecondary),
                        _dataCell(achat != null ? '${achat.quantite}' : '',
                            AppColors.textPrimary,
                            bold: true),
                        Expanded(
                          flex: 2,
                          child: Text(
                            achat?.prixDisplay ?? '',
                            textAlign: TextAlign.center,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.bullGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Separator
            Container(
              width: 1.5,
              color: AppColors.divider.withValues(alpha: 0.2),
            ),
            // ── Vente side ──
            Expanded(
              child: Stack(
                children: [
                  if (vente != null)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: vente.quantite / maxQ,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.bearRed.withValues(alpha: 0.12),
                                  AppColors.bearRed.withValues(alpha: 0.02),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            vente?.prixDisplay ?? '',
                            textAlign: TextAlign.center,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.bearRed,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        _dataCell(vente != null ? '${vente.quantite}' : '',
                            AppColors.textPrimary,
                            bold: true),
                        _dataCell(vente != null ? '${vente.nbrOrdres}' : '',
                            AppColors.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dataCell(String text, Color color, {bool bold = false}) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          fontSize: 11.5,
        ),
      ),
    );
  }

  Widget _buildVoirToutButton() {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 6),
            Text(
              _expanded ? 'Réduire' : 'Voir tout',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            if (!_expanded) ...[
              const SizedBox(width: 4),
              Text(
                '(${_totalRowCount})',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryBlue.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpreadInfo() {
    if (orderBook.ordresAchat.isEmpty || orderBook.ordresVente.isEmpty) {
      return const SizedBox.shrink();
    }
    final bestBid = orderBook.ordresAchat.first;
    final bestAsk = orderBook.ordresVente.first;
    // Skip spread if either is MO
    if (bestBid.isMO || bestAsk.isMO) return const SizedBox.shrink();
    final spread = bestAsk.prix - bestBid.prix;
    final spreadPct = bestBid.prix > 0 ? (spread / bestBid.prix * 100) : 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz_rounded,
            size: 16,
            color: AppColors.primaryBlue.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            'Spread: ',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          Text(
            '${spread.toStringAsFixed(3)} (${spreadPct.toStringAsFixed(2)}%)',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
