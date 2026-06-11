import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 渐变背景容器 — 用于每个页面的 Scaffold body 外层
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [AppColors.background, AppColors.backgroundLight],
        ),
      ),
      child: child,
    );
  }
}