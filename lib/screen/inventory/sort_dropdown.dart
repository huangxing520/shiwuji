import 'package:flutter/material.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/constants/app_dimensions.dart';
import 'package:shi_wu_ji/models/enums/sort_type.dart';

const _sortFullLabels = {
  SortType.newest: '新增时间（最新优先）',
  SortType.oldest: '新增时间（最早优先）',
  SortType.priceHigh: '价格（高→低）',
  SortType.priceLow: '价格（低→高）',
  SortType.expiring: '到期时间（最近优先）',
};

/// Sort dropdown overlay widget.
class SortDropdown extends StatelessWidget {
  final SortType currentSort;
  final ValueChanged<SortType> onSortSelected;

  const SortDropdown({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pageMarginHorizontal,
        4,
        AppDimensions.pageMarginHorizontal,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius:
              BorderRadius.circular(AppDimensions.borderRadiusExtraLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.14),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: SortType.values.map((type) {
              final isActive = currentSort == type;
              return GestureDetector(
                onTap: () => onSortSelected(type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _sortFullLabels[type]!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? AppColors.accentGold
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (isActive)
                        const Icon(
                          Icons.check,
                          size: 18,
                          color: AppColors.accentGold,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
