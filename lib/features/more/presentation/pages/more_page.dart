import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// Page Plus — Paramètres, profil, informations
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.headerGradient),
              ),
            ),
            title: const Text(
              'Plus',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),

          // ── Profil ──
          SliverToBoxAdapter(
            child: _buildProfileCard(),
          ),

          // ── Sections ──
          SliverToBoxAdapter(
            child: _buildSection('Général', [
              _MenuItem(icon: Icons.language, title: 'Langue', subtitle: 'Français'),
              _MenuItem(icon: Icons.dark_mode_outlined, title: 'Thème', subtitle: 'Clair'),
              _MenuItem(icon: Icons.notifications_outlined, title: 'Notifications', subtitle: 'Activées'),
            ]),
          ),

          SliverToBoxAdapter(
            child: _buildSection('Marché', [
              _MenuItem(
                icon: Icons.newspaper,
                title: 'Actualités & Publications',
                subtitle: 'Dernières publications BVMT',
                onTap: () => context.push('/news'),
              ),
              _MenuItem(icon: Icons.currency_exchange, title: 'Devise', subtitle: 'TND'),
              _MenuItem(icon: Icons.access_time, title: 'Horaires BVMT', subtitle: 'Lun-Ven, 09:00-14:10'),
              _MenuItem(icon: Icons.info_outline, title: 'Guide BVMT', subtitle: 'Apprendre la bourse'),
            ]),
          ),

          SliverToBoxAdapter(
            child: _buildSection('Sécurité', [
              _MenuItem(icon: Icons.fingerprint, title: 'Biométrie', subtitle: 'Désactivée'),
              _MenuItem(icon: Icons.lock_outline, title: 'Changer le mot de passe'),
              _MenuItem(icon: Icons.shield_outlined, title: 'Confidentialité'),
            ]),
          ),

          SliverToBoxAdapter(
            child: _buildSection('Aide', [
              _MenuItem(icon: Icons.help_outline, title: 'FAQ'),
              _MenuItem(icon: Icons.support_agent, title: 'Contacter le support'),
              _MenuItem(icon: Icons.description_outlined, title: 'Conditions d\'utilisation'),
              _MenuItem(icon: Icons.policy_outlined, title: 'Politique de confidentialité'),
            ]),
          ),

          // ── Bouton déconnexion ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingMD),
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                            context.go('/login');
                          },
                          child: const Text('Déconnecter',
                              style: TextStyle(color: AppColors.bearRed)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout, color: AppColors.bearRed),
                label: const Text('Se déconnecter',
                    style: TextStyle(color: AppColors.bearRed, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.bearRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                  ),
                ),
              ),
            ),
          ),

          // ── Version ──
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 120),
              child: Center(
                child: Text(
                  'BVMT v1.0.0',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final storage = sl<LocalStorageService>();
    final displayName = storage.userName ?? 'Utilisateur';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Container(
      margin: const EdgeInsets.all(AppDimens.paddingMD),
      padding: const EdgeInsets.all(AppDimens.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryBlue,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'krouielyess@email.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<_MenuItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingSM),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppDimens.radiusMD),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == items.length - 1;
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item.icon, color: AppColors.primaryBlue, size: 20),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: item.subtitle != null
                          ? Text(item.subtitle!,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
                          : null,
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      onTap: item.onTap ?? () {},
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 60,
                        color: AppColors.divider.withValues(alpha: 0.5),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppDimens.paddingSM),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _MenuItem({required this.icon, required this.title, this.subtitle, this.onTap});
}
