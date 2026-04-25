import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../domain/entities/alert_entity.dart';
import '../bloc/alerts_bloc.dart';
import '../bloc/alerts_event.dart';
import '../bloc/alerts_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ROOT PAGE
// ─────────────────────────────────────────────────────────────────────────────
class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, state) {
        if (state is AlertsLoading || state is AlertsInitial) {
          return const _ShimmerView();
        }
        if (state is AlertsLoaded) {
          return _LoadedView(state: state);
        }
        if (state is AlertsError) {
          return _ErrorView(
            message: state.message,
            onRetry: () =>
                context.read<AlertsBloc>().add(const AlertsLoadRequested()),
          );
        }
        return const _ShimmerView();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerView extends StatelessWidget {
  const _ShimmerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _ShimmerCard(isWide: i % 3 != 2),
                childCount: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final bool isWide;
  const _ShimmerCard({this.isWide = true});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8ECF0),
      highlightColor: const Color(0xFFF5F7FA),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 80, height: 13, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(
                      width: isWide ? double.infinity : 140,
                      height: 11,
                      color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
                width: 44,
                height: 24,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.bearRed.withValues(alpha: 0.15),
                      AppColors.bearRed.withValues(alpha: 0.06),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: AppColors.bearRed, size: 44),
              ),
              const SizedBox(height: 24),
              const Text('Erreur',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reessayer',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADED VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _LoadedView extends StatelessWidget {
  final AlertsLoaded state;
  const _LoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    final alerts = state.alerts;
    final activeCount = alerts.where((a) => a.isActive).length;
    final aboveCount = alerts.where((a) => a.isAbove).length;
    final belowCount = alerts.where((a) => !a.isAbove).length;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAlertSheet(context),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle alerte',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            snap: false,
            elevation: 0,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient),
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.white15,
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                  Icons
                                      .notifications_active_rounded,
                                  color: Colors.white,
                                  size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Alertes Prix',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    alerts.isEmpty
                                        ? 'Aucune alerte configuree'
                                        : '$activeCount active${activeCount > 1 ? 's' : ''} · ${alerts.length} au total',
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (alerts.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _StatChip(
                                label: '$activeCount actives',
                                color: AppColors.bullGreen,
                                icon: Icons
                                    .check_circle_outline_rounded,
                              ),
                              const SizedBox(width: 8),
                              _StatChip(
                                label: '$aboveCount hausse',
                                color: AppColors.bullGreen,
                                icon: Icons.trending_up_rounded,
                              ),
                              const SizedBox(width: 8),
                              _StatChip(
                                label: '$belowCount baisse',
                                color: AppColors.bearRed,
                                icon: Icons.trending_down_rounded,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (alerts.isEmpty)
            const SliverFillRemaining(child: _EmptyState())
          else ...[
            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _AlertCard(
                    alert: alerts[index],
                    onToggle: () => context
                        .read<AlertsBloc>()
                        .add(AlertToggled(alerts[index].id)),
                    onDelete: () =>
                        _confirmDelete(context, alerts[index]),
                  ),
                  childCount: alerts.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: 110)),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AlertEntity alert) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.bearRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.bearRed, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'Supprimer l\'alerte ${alert.symbol} ?',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              '${alert.conditionText} ${alert.formattedPrice}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(
                          color: AppColors.divider),
                    ),
                    child: const Text('Annuler',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context
                          .read<AlertsBloc>()
                          .add(AlertDeleted(alert.id));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bearRed,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Supprimer',
                        style: TextStyle(
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CHIP
// ─────────────────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StatChip(
      {required this.label,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ALERT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final AlertEntity alert;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _AlertCard({
    required this.alert,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAbove = alert.isAbove;
    final color =
        isAbove ? AppColors.bullGreen : AppColors.bearRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.isActive
              ? color.withValues(alpha: 0.2)
              : AppColors.divider,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: alert.isActive
                ? color.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                color:
                    alert.isActive ? color : AppColors.divider,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(18, 14, 14, 14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(
                          alpha: alert.isActive ? 0.12 : 0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isAbove
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: alert.isActive
                          ? color
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2),
                              decoration: BoxDecoration(
                                gradient: alert.isActive
                                    ? const LinearGradient(
                                        colors: [
                                          AppColors
                                              .primaryBlueLight,
                                          AppColors.primaryBlue
                                        ],
                                      )
                                    : null,
                                color: alert.isActive
                                    ? null
                                    : AppColors
                                        .scaffoldBackground,
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: Text(
                                alert.symbol,
                                style: TextStyle(
                                  color: alert.isActive
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (!alert.isActive) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors
                                      .scaffoldBackground,
                                  borderRadius:
                                      BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AppColors.divider),
                                ),
                                child: const Text('Inactive',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors
                                            .textSecondary,
                                        fontWeight:
                                            FontWeight.w600)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (alert.companyName.isNotEmpty)
                          Text(
                            alert.companyName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              isAbove
                                  ? Icons.arrow_upward_rounded
                                  : Icons
                                      .arrow_downward_rounded,
                              size: 13,
                              color: color,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${alert.conditionText} ',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                            Text(
                              alert.formattedPrice,
                              style: TextStyle(
                                fontSize: 13,
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: alert.isActive,
                          onChanged: (_) => onToggle(),
                          activeColor: AppColors.bullGreen,
                          inactiveThumbColor:
                              AppColors.textSecondary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.bearRed
                                .withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.bearRed,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue
                        .withValues(alpha: 0.12),
                    AppColors.primaryBlue
                        .withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 48,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucune alerte configuree',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Creez des alertes de prix pour etre\nnotifie quand un titre atteint votre cible',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddAlertSheet(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Creer une alerte',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM SHEET — NOUVELLE ALERTE
// ─────────────────────────────────────────────────────────────────────────────
void _showAddAlertSheet(BuildContext context) {
  final symbolCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  String condition = 'above';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      return StatefulBuilder(
        builder: (stfCtx, setSheet) {
          return Container(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(stfCtx).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryBlueLight,
                              AppColors.primaryBlue
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                            Icons.add_alert_rounded,
                            color: Colors.white,
                            size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Nouvelle Alerte',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: symbolCtrl,
                    textCapitalization:
                        TextCapitalization.characters,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Symbole (ex: BIAT)',
                      hintText: 'BIAT, SFBT, TLNET...',
                      prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primaryBlue),
                      filled: true,
                      fillColor: AppColors.scaffoldBackground,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: priceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Prix cible',
                      hintText: '0.000',
                      prefixIcon: const Icon(
                          Icons.price_change_outlined,
                          color: AppColors.primaryBlue),
                      suffixText: 'TND',
                      suffixStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600),
                      filled: true,
                      fillColor: AppColors.scaffoldBackground,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Declencher quand le prix est...',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setSheet(
                              () => condition = 'above'),
                          child: AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            decoration: BoxDecoration(
                              color: condition == 'above'
                                  ? AppColors.bullGreen
                                      .withValues(alpha: 0.12)
                                  : AppColors.scaffoldBackground,
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color: condition == 'above'
                                    ? AppColors.bullGreen
                                    : AppColors.divider,
                                width: condition == 'above'
                                    ? 2
                                    : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                    Icons.trending_up_rounded,
                                    color: condition == 'above'
                                        ? AppColors.bullGreen
                                        : AppColors.textSecondary,
                                    size: 20),
                                const SizedBox(width: 6),
                                Text('Au-dessus',
                                    style: TextStyle(
                                      color:
                                          condition == 'above'
                                              ? AppColors.bullGreen
                                              : AppColors
                                                  .textSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setSheet(
                              () => condition = 'below'),
                          child: AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            decoration: BoxDecoration(
                              color: condition == 'below'
                                  ? AppColors.bearRed
                                      .withValues(alpha: 0.12)
                                  : AppColors.scaffoldBackground,
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color: condition == 'below'
                                    ? AppColors.bearRed
                                    : AppColors.divider,
                                width: condition == 'below'
                                    ? 2
                                    : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                    Icons.trending_down_rounded,
                                    color: condition == 'below'
                                        ? AppColors.bearRed
                                        : AppColors.textSecondary,
                                    size: 20),
                                const SizedBox(width: 6),
                                Text('En-dessous',
                                    style: TextStyle(
                                      color:
                                          condition == 'below'
                                              ? AppColors.bearRed
                                              : AppColors
                                                  .textSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final symbol = symbolCtrl.text
                            .trim()
                            .toUpperCase();
                        final price = double.tryParse(
                            priceCtrl.text
                                .trim()
                                .replaceAll(',', '.'));
                        if (symbol.isEmpty ||
                            price == null ||
                            price <= 0) {
                          ScaffoldMessenger.of(stfCtx)
                              .showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Veuillez remplir tous les champs correctement'),
                              behavior:
                                  SnackBarBehavior.floating,
                              backgroundColor:
                                  AppColors.bearRed,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          12)),
                            ),
                          );
                          return;
                        }
                        context
                            .read<AlertsBloc>()
                            .add(AlertCreated(
                              symbol: symbol,
                              targetPrice: price,
                              condition: condition,
                            ));
                        Navigator.pop(stfCtx);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 18),
                                const SizedBox(width: 10),
                                Text(
                                    'Alerte $symbol creee a ${price.toStringAsFixed(3)} TND'),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor:
                                AppColors.bullGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_alert_rounded,
                          size: 20),
                      label: const Text('Creer l\'alerte',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}