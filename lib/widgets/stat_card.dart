import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_shadows.dart';
import 'card_container.dart';

class StatCard extends StatelessWidget {
  final String count;
  final String? prefix;
  final String? unit;
  final String label;
  final String? trendText;
  final bool trendUp;
  final Color color;
  final Color lightColor;
  final IconData icon;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.count,
    this.prefix,
    this.unit,
    required this.label,
    this.trendText,
    this.trendUp = true,
    required this.color,
    required this.lightColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      borderRadius: 24,
      shadowColor: AppColors.primary,
      onTap: onTap,
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (prefix != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          prefix!,
                          style: AppTextStyles.cardValueUnit,
                        ),
                      ),
                    Flexible(
                      child: Text(
                        count,
                        style: AppTextStyles.cardValue,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unit != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          unit!,
                          style: AppTextStyles.cardValueUnit,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(label, style: AppTextStyles.cardLabel),
                if (trendText != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: trendUp
                          ? AppColors.successLight
                          : AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trendText!,
                      style: AppTextStyles.trendText(
                        color: trendUp ? AppColors.success : AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}