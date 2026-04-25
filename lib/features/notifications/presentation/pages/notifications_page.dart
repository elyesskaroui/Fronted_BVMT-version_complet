import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ROOT PAGE
// ─────────────────────────────────────────────────────────────────────────────
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        if (state is NotificationsLoading || state is NotificationsInitial) {
          return const _ShimmerView();
        }
        if (state is NotificationsLoaded) {
          return _LoadedView(state: state);
        }
        if (state is NotificationsError) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context
                .read<NotificationsBloc>()
                .add(const NotificationsLoadRequested()),
          );
        }
        return const _ShimmerView();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER LOADING
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
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A6BCC),
                      Color(0xFF0D4FA8),
                      Color(0xFF0A3D82),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => const _ShimmerCard(),
                childCount: 7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
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
                  Row(
                    children: [
                      Container(width: 100, height: 13, color: Colors.white),
                      const Spacer(),
                      Container(width: 50, height: 11, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                      width: double.infinity, height: 11, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(width: 200, height: 11, color: Colors.white),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                          width: 70,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          )),
                      const SizedBox(width: 8),
                      Container(
                          width: 50,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          )),
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
                      AppColors.bearRed.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_off_rounded,
                    color: AppColors.bearRed, size: 44),
              ),
              const SizedBox(height: 24),
              const Text(
                'Connexion impossible',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Réessayer',
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
class _LoadedView extends StatefulWidget {
  final NotificationsLoaded state;
  const _LoadedView({required this.state});

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {
  String _activeFilter = 'Toutes';
  String _searchQuery = '';
  bool _searchOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<String> get _categories {
    final cats = widget.state.notifications
        .map((n) => n.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['Toutes', 'Non lues', ...cats];
  }

  List<NotificationEntity> get _filtered {
    var list = widget.state.notifications;
    if (_activeFilter == 'Non lues') {
      list = list.where((n) => !n.isRead).toList();
    } else if (_activeFilter != 'Toutes') {
      list = list.where((n) => n.category == _activeFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((n) =>
              n.publicationTitle.toLowerCase().contains(q) ||
              n.company.toLowerCase().contains(q) ||
              n.category.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  Map<String, List<NotificationEntity>> _grouped(
      List<NotificationEntity> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final Map<String, List<NotificationEntity>> groups = {};
    for (final n in items) {
      final d =
          DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      String section;
      if (!d.isBefore(today)) {
        section = "Aujourd'hui";
      } else if (!d.isBefore(yesterday)) {
        section = 'Hier';
      } else if (!d.isBefore(weekAgo)) {
        section = 'Cette semaine';
      } else {
        section = 'Plus ancien';
      }
      groups.putIfAbsent(section, () => []).add(n);
    }
    return groups;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = widget.state.unreadCount;
    final total = widget.state.total;
    final items = _filtered;
    final groups = _grouped(items);
    final sectionOrder = [
      "Aujourd'hui",
      'Hier',
      'Cette semaine',
      'Plus ancien'
    ];
    final activeSections =
        sectionOrder.where((s) => groups.containsKey(s)).toList();

    final List<Widget> contentSlivers = [];
    if (items.isEmpty) {
      contentSlivers.add(
        SliverFillRemaining(
          child: _EmptyState(
            isFiltered:
                _activeFilter != 'Toutes' || _searchQuery.isNotEmpty,
            onRefresh: () => context
                .read<NotificationsBloc>()
                .add(const NotificationsLoadRequested()),
          ),
        ),
      );
    } else {
      for (final section in activeSections) {
        final sectionItems = groups[section]!;
        contentSlivers.add(SliverToBoxAdapter(
          child: _SectionHeader(
              title: section, count: sectionItems.length),
        ));
        contentSlivers.add(SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final notif = sectionItems[index];
                return _NotificationCard(
                  notification: notif,
                  onTap: () {
                    if (!notif.isRead) {
                      context
                          .read<NotificationsBloc>()
                          .add(NotificationMarkRead(notif.id));
                    }
                  },
                );
              },
              childCount: sectionItems.length,
            ),
          ),
        ));
      }
      contentSlivers
          .add(const SliverToBoxAdapter(child: SizedBox(height: 110)));
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        backgroundColor: Colors.white,
        strokeWidth: 2.5,
        onRefresh: () async {
          context
              .read<NotificationsBloc>()
              .add(const NotificationsLoadRequested());
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: CustomScrollView(
          slivers: [
            // ── AppBar ──
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              snap: false,
              elevation: 0,
              backgroundColor: AppColors.primaryBlue,
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _searchOpen = !_searchOpen;
                      if (!_searchOpen) {
                        _searchQuery = '';
                        _searchCtrl.clear();
                      } else {
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () => _searchFocus.requestFocus(),
                        );
                      }
                    });
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _searchOpen
                          ? Icons.close_rounded
                          : Icons.search_rounded,
                      key: ValueKey(_searchOpen),
                      color: Colors.white,
                    ),
                  ),
                ),
                if (unread > 0)
                  IconButton(
                    onPressed: () => context
                        .read<NotificationsBloc>()
                        .add(const NotificationsMarkAllRead()),
                    tooltip: 'Tout marquer lu',
                    icon: const Icon(Icons.done_all_rounded,
                        color: Colors.white),
                  ),
                const SizedBox(width: 4),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A6BCC),
                        Color(0xFF0D4FA8),
                        Color(0xFF0A3D82),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 80, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.white15,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.notifications_rounded,
                                    color: Colors.white,
                                    size: 22),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Notifications',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      unread > 0
                                          ? '$unread non lue${unread > 1 ? 's' : ''} · $total au total'
                                          : 'Tout à jour · $total notifications',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.7),
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _StatBadge(
                                icon: Icons.inbox_rounded,
                                label: '$total',
                                sublabel: 'Total',
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              _StatBadge(
                                icon: Icons.mark_email_unread_rounded,
                                label: '$unread',
                                sublabel: 'Non lues',
                                color: unread > 0
                                    ? AppColors.warningYellow
                                    : Colors.white,
                              ),
                              const SizedBox(width: 8),
                              _StatBadge(
                                icon: Icons.picture_as_pdf_rounded,
                                label:
                                    '${widget.state.notifications.where((n) => n.pdfUrl.isNotEmpty).length}',
                                sublabel: 'PDF',
                                color: AppColors.bullGreen,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              title: Row(
                children: [
                  const Text('Notifications',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18)),
                  if (unread > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.bearRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$unread',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),

            // ── Search bar ──
            if (_searchOpen)
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.primaryBlue,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: 'Rechercher une notification…',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                ),
              ),

            // ── Category filter chips ──
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final isSelected = _activeFilter == cat;
                    Color chipColor = AppColors.primaryBlue;
                    if (cat == 'Non lues') chipColor = AppColors.bearRed;
                    return _FilterChip(
                      label: cat,
                      selected: isSelected,
                      activeColor: chipColor,
                      onTap: () =>
                          setState(() => _activeFilter = cat),
                    );
                  },
                ),
              ),
            ),

            // ── Divider ──
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Divider(color: AppColors.divider, height: 1),
              ),
            ),

            // ── Content ──
            ...contentSlivers,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  const _StatBadge({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.1)),
              Text(sublabel,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                      height: 1.1)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER CHIP
// ─────────────────────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? activeColor : AppColors.divider,
              width: 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: activeColor.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ]
              : [
                  const BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 4,
                      offset: Offset(0, 1))
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION CARD
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  String _extractCompany() {
    final title = notification.publicationTitle;
    final dashIdx = title.indexOf(' - ');
    if (dashIdx > 0) return title.substring(0, dashIdx).trim();
    final company = notification.company;
    if (company.toLowerCase().contains('societe') ||
        company.toLowerCase().contains('société') ||
        company.isEmpty) {
      return title.split(' ').take(3).join(' ');
    }
    return company;
  }

  String _extractTitle() {
    final title = notification.publicationTitle;
    final dashIdx = title.indexOf(' - ');
    if (dashIdx > 0) return title.substring(dashIdx + 3).trim();
    return title;
  }

  String _timeAgo() {
    final diff =
        DateTime.now().difference(notification.createdAt.toLocal());
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return '${diff.inDays}j';
    return DateFormat('dd MMM', 'fr')
        .format(notification.createdAt.toLocal());
  }

  Color _categoryColor() {
    final cat = notification.category.toLowerCase();
    if (cat.contains('financier') ||
        cat.contains('résultat') ||
        cat.contains('resultat')) {
      return AppColors.bullGreen;
    }
    if (cat.contains('spéciale') ||
        cat.contains('speciale') ||
        cat.contains('assemblée') ||
        cat.contains('assemblee')) {
      return const Color(0xFF8E44AD);
    }
    if (cat.contains('communiqué') ||
        cat.contains('communique') ||
        cat.contains('presse')) {
      return AppColors.accentOrange;
    }
    if (cat.contains('trimestriel') ||
        cat.contains('activité') ||
        cat.contains('activite')) {
      return const Color(0xFF2980B9);
    }
    return AppColors.primaryBlue;
  }

  String _avatarText() {
    final c = _extractCompany();
    return c.isNotEmpty ? c[0].toUpperCase() : 'B';
  }

  Color _avatarColor() {
    const colors = [
      AppColors.primaryBlue,
      AppColors.bullGreen,
      Color(0xFF8E44AD),
      AppColors.accentOrange,
      Color(0xFF2980B9),
      Color(0xFFE67E22),
      Color(0xFF16A085),
      AppColors.bearRed,
    ];
    final c = _extractCompany();
    final idx = c.isNotEmpty ? c.codeUnitAt(0) % colors.length : 0;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final catColor = _categoryColor();
    final avatarColor = _avatarColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFF0F5FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? AppColors.primaryBlue.withValues(alpha: 0.25)
                : AppColors.divider,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? AppColors.primaryBlue.withValues(alpha: 0.07)
                  : const Color(0x08000000),
              blurRadius: isUnread ? 16 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                if (isUnread)
                  Container(width: 4, color: AppColors.primaryBlue),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        isUnread ? 12 : 16, 14, 14, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    avatarColor,
                                    avatarColor.withValues(alpha: 0.75),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        avatarColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _avatarText(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            if (isUnread)
                              Positioned(
                                top: -3,
                                right: -3,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFFF0F5FF),
                                        width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _extractCompany(),
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: isUnread
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        fontSize: 14,
                                        letterSpacing: -0.1,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _timeAgo(),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _extractTitle(),
                                style: TextStyle(
                                  color: isUnread
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: isUnread
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (notification.category.isNotEmpty)
                                    _Badge(
                                      label: notification.category,
                                      color: catColor,
                                    ),
                                  _Badge(
                                    label:
                                        '${notification.totalPublications} pub${notification.totalPublications > 1 ? 's' : ''}',
                                    color: AppColors.textSecondary,
                                    outlined: true,
                                  ),
                                  if (notification.pdfUrl.isNotEmpty)
                                    _Badge(
                                      label: 'PDF',
                                      icon: Icons.picture_as_pdf_rounded,
                                      color: AppColors.bullGreen,
                                    ),
                                ],
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
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool outlined;

  const _Badge({
    required this.label,
    required this.color,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border:
            outlined ? Border.all(color: AppColors.divider, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: outlined ? AppColors.textSecondary : color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: outlined ? AppColors.textSecondary : color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback onRefresh;
  const _EmptyState({required this.isFiltered, required this.onRefresh});

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
                    AppColors.primaryBlue.withValues(alpha: 0.12),
                    AppColors.primaryBlue.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered
                    ? Icons.filter_list_off_rounded
                    : Icons.notifications_off_outlined,
                color: AppColors.primaryBlue,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFiltered ? 'Aucun résultat' : 'Aucune notification',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isFiltered
                  ? 'Essayez un autre filtre ou effacez la recherche.'
                  : "Les nouvelles publications BVMT apparaîtront ici dès qu'elles sont disponibles.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Actualiser',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(
                    color: AppColors.primaryBlue, width: 1.5),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
