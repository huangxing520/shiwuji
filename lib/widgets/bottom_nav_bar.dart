import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum TabType { home, inventory, stats, me }

class BottomNavBar extends StatelessWidget {
  final TabType currentTab;
  final ValueChanged<TabType> onTabChanged;

  const BottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, Icons.home_outlined, '首页', TabType.home),
          _buildNavItem(
            Icons.inventory,
            Icons.inventory_outlined,
            '物品库',
            TabType.inventory,
          ),
          const SizedBox(width: 52),
          _buildNavItem(
            Icons.bar_chart,
            Icons.bar_chart_outlined,
            '数据统计',
            TabType.stats,
          ),
          _buildNavItem(Icons.person, Icons.person_outlined, '个人中心', TabType.me),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    TabType tab,
  ) {
    final isActive = currentTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(tab),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 顶部指示线
            Container(
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              isActive ? activeIcon : inactiveIcon,
              size: 24,
              color: isActive ? AppColors.accentGold : AppColors.textHint,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? AppColors.accentGold : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}