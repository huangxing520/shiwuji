import 'package:flutter/material.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/widgets/data_card.dart';

class DataCardsSection extends StatelessWidget {
  final int itemCount;
  final int totalValue;
  final int pendingCount;
  final int idleCount;
  final int weeklyNewCount;
  final double monthlyGrowth;

  const DataCardsSection({
    super.key,
    required this.itemCount,
    required this.totalValue,
    required this.pendingCount,
    required this.idleCount,
    required this.weeklyNewCount,
    required this.monthlyGrowth,
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
        childAspectRatio: 0.8,
        children: [
          DataCard(
            icon: Icons.inventory,
            target: itemCount,
            unit: '件',
            label: '物品总数',
            trendLabel: '$weeklyNewCount 本周新增',
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
            trendLabel: '${_formatCurrency(monthlyGrowth.toInt())} 本月增长',
            trendUp: monthlyGrowth > 0,
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
            label: '过保物品',
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

  /// 格式化金额为千分位字符串，与 drift 系统数值展示格式一致。
  /// 例如：3280 → '3,280'，0 → '0'。
  static String _formatCurrency(int value) {
    if (value == 0) return '0';
    final chars = value.abs().toString().split('');
    final buf = StringBuffer();
    if (value < 0) buf.write('-');
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && (chars.length - i) % 3 == 0) buf.write(',');
      buf.write(chars[i]);
    }
    return buf.toString();
  }
}
