import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 统一阴影常量
class AppShadows {
  AppShadows._();

  // ── 卡片阴影 ──
  static final card = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.08),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  // ── 浮动元素阴影 ──
  static final floating = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ── 底部导航栏阴影 ──
  static final navBar = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];

  // ── 添加按钮阴影 ──
  static const addButton = [
    BoxShadow(
      color: Color(0x66FFB800),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // ── Logo 阴影 ──
  static final logo = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.35),
      blurRadius: 48,
      offset: const Offset(0, 16),
    ),
  ];

  // ── 卡片金色阴影 ──
  static final cardAccent = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.10),
      blurRadius: 24,
      offset: const Offset(0, 6),
    ),
  ];

  // ── 自定义阴影（带颜色） ──
  static List<BoxShadow> colored({
    required Color color,
    double blurRadius = 12,
    Offset offset = const Offset(0, 4),
    double alpha = 0.3,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }
}