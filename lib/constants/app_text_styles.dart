import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 统一文本样式常量
class AppTextStyles {
  AppTextStyles._();

  // ── 标题样式 ──
  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const titleMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const overlayTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  // ── 正文样式 ──
  static const bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // ── 标签样式 ──
  static const labelLarge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const labelMedium = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  static const labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  // ── 特殊样式 ──
  static const priceText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const subtitleText = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const sectionTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const seeAllText = TextStyle(
    fontSize: 13,
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
  );

  // ── Splash 专用 ──
  static const splashTitle = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: 6,
  );

  static const splashSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 3,
  );

  // ── 按钮 ──
  static const buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // ── 带颜色的变体 ──
  static TextStyle colored({
    required Color color,
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle tag({
    Color? color,
    double fontSize = 11,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color ?? AppColors.textSecondary,
    );
  }

  static TextStyle statCount({required Color color}) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: color,
    );
  }

  static TextStyle infoValue({bool isAccent = false}) {
    return TextStyle(
      fontSize: 14,
      color: isAccent ? AppColors.accentGold : AppColors.textPrimary,
      fontWeight: FontWeight.w700,
    );
  }

  // ── 首页专用 ──
  static const greetingText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const greetingSub = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const cardValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1,
  );

  static const cardValueUnit = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const cardLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle trendText({required Color color}) {
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static const pendingTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const pendingDesc = TextStyle(
    fontSize: 12,
    color: AppColors.textHint,
  );

  static const pendingCount = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
  );

  static const navLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  static const navLabelActive = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const actionLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const toastText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const itemName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const itemMeta = TextStyle(
    fontSize: 12,
    color: AppColors.textHint,
  );

  static TextStyle itemTag({required Color color}) {
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static const pullIndicatorText = TextStyle(
    fontSize: 13,
    color: AppColors.textHint,
  );
}