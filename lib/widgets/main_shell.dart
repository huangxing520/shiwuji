import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/widgets/bottom_nav_bar.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3ED),
      body: navigationShell,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Widget _buildBottomNav() {
  //   final tabs = [
  //     (icon: Icons.home_outlined, label: '首页',selectedIcon: Icons.home_outlined),
  //     (icon: Icons.calendar_today_outlined, label: '物品',selectedIcon: Icons.inventory_2_outlined),
  //     (icon: Icons.person_outlined, label: '收纳',selectedIcon:Icons.storage_outlined),
  //     (icon: Icons.add_outlined, label: '我的',selectedIcon: Icons.person_outlined),
  //   ];

  //   return Container(
  //     height: 80,
  //     padding: const EdgeInsets.only(bottom: 8),
  //     decoration: const BoxDecoration(
  //       color: Color(0xFFFAF7F0),
  //       border: Border(top: BorderSide(color: Color(0xFFE8E4DC), width: 1)),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: List.generate(tabs.length, (index) {
  //         final isActive = navigationShell.currentIndex == index;
  //         return _BottomNavItem(
  //           icon: isActive ? tabs[index].selectedIcon : tabs[index].icon,
  //           label: tabs[index].label,
  //           isActive: isActive,
  //           onTap: () {
  //             navigationShell.goBranch(
  //               index,
  //               initialLocation: index == navigationShell.currentIndex,
  //             );
  //           },
  //         );
  //       }),
  //     ),
  //   );
  // }

  Widget _buildBottomNavBar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
          BottomNavBar(
            currentTab: TabType.values[navigationShell.currentIndex],
            onTabChanged: (tab) {
              navigationShell.goBranch(
                tab.index,
                initialLocation: tab.index == navigationShell.currentIndex,
              );
            },
          ),
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  navigationShell.goBranch(3, initialLocation: true);
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.warning],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppColors.cardBg, width: 3),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 26),
                ),
              ),
            ),
          ),
        ],
      
    );
  }
}

