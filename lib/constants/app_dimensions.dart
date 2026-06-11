import 'package:flutter/material.dart';

/// 统一尺寸常量
class AppDimensions {
  AppDimensions._();

  // ── 页面边距 ──
  static const double pageMarginHorizontal = 20;
  static const double pageMarginVertical = 12;

  // ── 卡片内边距 ──
  static const double cardPadding = 14;
  static const double cardPaddingLarge = 16;

  // ── 圆角 ──
  static const double borderRadiusSmall = 8;
  static const double borderRadiusMedium = 12;
  static const double borderRadiusLarge = 16;
  static const double borderRadiusExtraLarge = 18;
  static const double borderRadiusXLarge = 24;

  // ── 间距 ──
  static const double spacingExtraSmall = 4;
  static const double spacingSmall = 8;
  static const double spacingMedium = 12;
  static const double spacingLarge = 16;
  static const double spacingExtraLarge = 20;
  static const double spacingXXLarge = 24;

  // ── 图标尺寸 ──
  static const double iconSizeSmall = 16;
  static const double iconSizeMedium = 24;
  static const double iconSizeLarge = 28;
  static const double iconSizeExtraLarge = 64;

  // ── 容器尺寸 ──
  static const double avatarSize = 44;
  static const double iconContainerSmall = 48;
  static const double iconContainerMedium = 52;
  static const double addButtonSize = 56;

  // ── 阴影 ──
  static const double shadowBlurSmall = 10;
  static const double shadowBlurMedium = 12;
  static const double shadowBlurLarge = 20;
  static const double shadowBlurExtraLarge = 48;

  // ── 常用 EdgeInsets ──
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pageMarginHorizontal,
  );

  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);
  static const EdgeInsets cardPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: cardPaddingLarge,
    vertical: cardPadding,
  );

  // ── 常用 BoxConstraints ──
  static const BoxConstraints iconConstraints = BoxConstraints(
    minWidth: iconContainerSmall,
    maxWidth: iconContainerSmall,
    minHeight: iconContainerSmall,
    maxHeight: iconContainerSmall,
  );
}