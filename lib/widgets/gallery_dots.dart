import 'package:flutter/material.dart';

/// 图片画廊圆点指示器
class GalleryDots extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const GalleryDots({
    super.key,
    required this.itemCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 14,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(itemCount, (index) {
          final isActive = index == currentIndex;
          return Container(
            width: isActive ? 20 : 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isActive ? 4 : 50),
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
            ),
          );
        }),
      ),
    );
  }
}