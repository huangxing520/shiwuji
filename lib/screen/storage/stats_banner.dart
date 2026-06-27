import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 收纳统计横幅 — 显示房间/柜体/物品总数
class StorageStatsBanner extends StatelessWidget {
  final int roomCount;
  final int cabinetCount;
  final int itemCount;

  const StorageStatsBanner({
    super.key,
    required this.roomCount,
    required this.cabinetCount,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD460), Color(0xFFFFB800), Color(0xFFFF9E40)],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0x33FFB800),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 装饰圆
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: 30,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // 统计项
          Row(
            children: [
              _buildStatItem(roomCount, '房间'),
              _buildStatItem(cabinetCount, '柜体'),
              _buildStatItem(itemCount, '物品总数'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(int num, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$num',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xBFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}
