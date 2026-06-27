import 'package:flutter/material.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/widgets/data_card.dart';

class DataCardsSection extends StatelessWidget {
  final int itemCount;
  final int totalValue;
  final int pendingCount;
  final int idleCount;

  const DataCardsSection({
    super.key,
    required this.itemCount,
    required this.totalValue,
    required this.pendingCount,
    required this.idleCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          DataCard(
            icon: Icons.inventory,
            target: itemCount,
            unit: '件',
            label: '物品总数',
            trendLabel: '12 本周新增',
            trendUp: true,
            color: AppColors.accentGold,
            decoColor: AppColors.shimmerGold,
            iconBgColor: AppColors.accentLightBg,
            iconColor: AppColors.accentGold,
            delayMs: 100,
          ),
          DataCard(
            icon: Icons.trending_up,
            target: totalValue,
            unit: '元',
            label: '总资产价值',
            trendLabel: '3,280 本月',
            trendUp: true,
            color: AppColors.warning,
            decoColor: AppColors.shimmerOrange,
            iconBgColor: AppColors.warning.withValues(alpha: 0.15),
            iconColor: AppColors.warning,
            delayMs: 200,
          ),
          DataCard(
            icon: Icons.timer,
            target: pendingCount,
            unit: '件',
            label: '即将到期',
            trendLabel: '3天内到期',
            trendUp: false,
            color: AppColors.danger,
            decoColor: AppColors.shimmerRed,
            iconBgColor: AppColors.danger.withValues(alpha: 0.15),
            iconColor: AppColors.danger,
            delayMs: 300,
          ),
          DataCard(
            icon: Icons.archive,
            target: idleCount,
            unit: '件',
            label: '闲置物品',
            trendLabel: '建议处理',
            trendUp: false,
            color: AppColors.success,
            decoColor: AppColors.shimmerGreen,
            iconBgColor: AppColors.success.withValues(alpha: 0.15),
            iconColor: AppColors.success,
            delayMs: 400,
          ),
        ],
      ),
    );
  }
}
