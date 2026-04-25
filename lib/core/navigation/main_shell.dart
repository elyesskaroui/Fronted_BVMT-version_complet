import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../di/injection.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_event.dart';
import '../../features/notifications/presentation/bloc/notifications_state.dart';

/// Shell principal — Floating Bottom Navigation Bar BVMT
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/market')) return 1;
    if (location.startsWith('/portfolio')) return 2;
    if (location.startsWith('/alerts')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _currentIndex(context);

    return BlocProvider(
      create: (_) => sl<NotificationsBloc>()
        ..add(const NotificationsLoadRequested()),
      child: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, notifState) {
          final unread = notifState is NotificationsLoaded
              ? notifState.unreadCount
              : 0;

          return Scaffold(
            body: child,
            extendBody: true,
            bottomNavigationBar: _BvmtBottomBar(
              selectedIndex: selectedIndex,
              unreadBadge: unread,
              onTap: (index) {
                HapticFeedback.lightImpact();
                switch (index) {
                  case 0: context.go('/home');
                  case 1: context.go('/market');
                  case 2: context.go('/portfolio');
                  case 3: context.go('/alerts');
                  case 4: context.go('/more');
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  Floating Bottom Bar — BVMT branded
// ══════════════════════════════════════════════════════

class _BvmtBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int unreadBadge;

  const _BvmtBottomBar({
    required this.selectedIndex,
    required this.onTap,
    this.unreadBadge = 0,
  });

  static const _items = <_NavItemData>[
    _NavItemData(Icons.home_outlined, Icons.home_rounded, 'Accueil'),
    _NavItemData(Icons.candlestick_chart_outlined, Icons.candlestick_chart_rounded, 'Marché'),
    _NavItemData(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Portefeuille'),
    _NavItemData(Icons.notifications_outlined, Icons.notifications_rounded, 'Alertes'),
    _NavItemData(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Plus'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.deepNavy,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.30),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // ── Sliding orange indicator at top ──
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  top: 0,
                  left: _indicatorLeft(context),
                  child: Container(
                    width: _itemWidth(context) * 0.45,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentOrange.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Nav items ──
                Row(
                  children: List.generate(_items.length, (i) {
                    return Expanded(
                      child: _NavItem(
                        data: _items[i],
                        isActive: selectedIndex == i,
                        badgeCount: i == 3 ? unreadBadge : 0,
                        onTap: () => onTap(i),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _itemWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth - 28) / _items.length; // 28 = padding 14*2
  }

  double _indicatorLeft(BuildContext context) {
    final w = _itemWidth(context);
    return (w * selectedIndex) + (w * 0.275);
  }
}

// ──────────────────────────────────────
// Data class
// ──────────────────────────────────────
class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData(this.icon, this.activeIcon, this.label);
}

// ──────────────────────────────────────
// Single Nav Item
// ──────────────────────────────────────
class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.data,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 2),

            // ── Icon ──
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: isActive ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) {
                final icon = Icon(
                  isActive ? data.activeIcon : data.icon,
                  color: Color.lerp(
                    AppColors.navBarInactive,
                    AppColors.accentOrange,
                    t,
                  ),
                  size: 23 + (2 * t),
                );

                if (badgeCount > 0) {
                  return Transform.translate(
                    offset: Offset(0, -2 * t),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        icon,
                        Positioned(
                          top: -4,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            constraints: const BoxConstraints(
                                minWidth: 16, minHeight: 16),
                            decoration: const BoxDecoration(
                              color: AppColors.bearRed,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              badgeCount > 99 ? '99+' : '$badgeCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Transform.translate(
                  offset: Offset(0, -2 * t),
                  child: icon,
                );
              },
            ),

            const SizedBox(height: 4),

            // ── Label ──
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: isActive
                    ? AppColors.textOnPrimary
                    : AppColors.navBarInactive,
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: isActive ? 0.2 : 0,
              ),
              child: Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
