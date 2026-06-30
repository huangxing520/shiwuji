import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/providers/profile_provider.dart';

/// 2×2 数据概览网格
class DataStatsSection extends ConsumerWidget {
  const DataStatsSection({super.key});

  static const _entries = [
    _StatEntry(
      icon: Icons.inventory_2_outlined,
      label: '物品总数',
      unit: '件',
      color: AppColors.primary,
      delay: 0,
    ),
    _StatEntry(
      icon: Icons.account_balance_wallet_outlined,
      label: '总价值',
      unit: '元',
      color: AppColors.warning,
      delay: 80,
    ),
    _StatEntry(
      icon: Icons.home_outlined,
      label: '收纳位置',
      unit: '个',
      color: AppColors.success,
      delay: 160,
    ),
    _StatEntry(
      icon: Icons.grid_view_outlined,
      label: '分类数量',
      unit: '个',
      color: AppColors.info,
      delay: 240,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);

    return stats.when(
      skipLoadingOnReload: true,
      skipError: true,
      loading: () => _buildSkeleton(),
      error: (_, __) => _buildSkeleton(),
      data: (data) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.65,
          children: [
            _buildCell(_entries[0], data['itemCount'] ?? 0),
            _buildCell(_entries[1], data['totalValue'] ?? 0),
            _buildCell(_entries[2], data['roomCount'] ?? 0),
            _buildCell(_entries[3], data['categoryCount'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(_StatEntry entry, num value) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: const Cubic(0.34, 1.56, 0.64, 1),
      builder: (context, t, child) {
        return Transform.scale(
          scale: 0.85 + 0.15 * t,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: entry.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(entry.icon, size: 22, color: entry.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatValue(entry, value),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
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

  String _formatValue(_StatEntry entry, num value) {
    if (entry.unit == '元') {
      if (value >= 10000) {
        return '${(value / 10000).toStringAsFixed(1)}万';
      }
      return value.toStringAsFixed(0);
    }
    return value.toString();
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.65,
        children: List.generate(
          4,
          (i) => Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatEntry {
  final IconData icon;
  final String label;
  final String unit;
  final Color color;
  final int delay;

  const _StatEntry({
    required this.icon,
    required this.label,
    required this.unit,
    required this.color,
    required this.delay,
  });
}
