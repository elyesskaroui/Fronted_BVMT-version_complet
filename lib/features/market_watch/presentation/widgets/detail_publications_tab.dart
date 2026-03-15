import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/instrument_detail_models.dart';

// ==========================================================================
// DetailPublicationsTab — Publications premium 10/10
// Animated cards, left accent, date badge, rich layout
// ==========================================================================
class DetailPublicationsTab extends StatelessWidget {
  final List<StockPublication> publications;

  const DetailPublicationsTab({super.key, required this.publications});

  @override
  Widget build(BuildContext context) {
    if (publications.isEmpty) {
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
                Icons.newspaper_rounded,
                size: 28,
                color: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune publication disponible',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: publications.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          key: ValueKey(index),
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + index * 80),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(20 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: _buildCard(publications[index], index),
        );
      },
    );
  }

  Widget _buildCard(StockPublication pub, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.accentOrange,
                      AppColors.accentOrange.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accentOrange
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.accentOrange
                                        .withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 11,
                                      color: AppColors.accentOrange
                                          .withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      pub.date,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.accentOrange,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Index badge
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AppColors.scaffoldBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary
                                          .withValues(alpha: 0.5),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Titre
                          Text(
                            pub.titre,
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.deepNavy,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          if (pub.description != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              pub.description!,
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 6),
                          // Read more with arrow
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Lire plus',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primaryBlue
                                      .withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.5,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: AppColors.primaryBlue
                                    .withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
