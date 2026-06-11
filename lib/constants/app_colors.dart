/// 统一颜色常量
///
/// 应用主色调：
/// - 金色 (#FFB800) 作为主色
/// - 暖白 (#FFF8E7 / #FFE9B0) 作为背景
/// - 深棕 (#3D2B1F) 作为文字主色
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── 主色 ──
  static const int _primaryInt = 0xFFFFB800;
  static const int _bgInt = 0xFFFFF8E7;
  static const int _textInt = 0xFF3D2B1F;

  // ── 品牌色 ──
  static const primary = Color(_primaryInt);
  static const primaryLight = Color(0xFFFFE9B0);
  static const primaryDark = Color(0xFFE5A500);
  static const accentGold = Color(0xFFE5A500);
  static const primaryMid = Color(0xFFFFD460);
  static const primaryDeep = Color(0xFFFF9E40);

  // ── 背景色 ──
  static const background = Color(_bgInt);
  static const backgroundLight = Color(0xFFFFE9B0);
  static const cardBg = Colors.white;

  // ── 文字色 ──
  static const textPrimary = Color(_textInt);
  static const textSecondary = Color(0xFF8B7355);
  static const textHint = Color(0xFFB8A48E);

  // ── 装饰色 ──
  static const border = Color(0xFFF0E4D0);
  static const divider = Color(0xFFF0E4D0);

  // ── 语义色 ──
  static const success = Color(0xFF6BCB77);
  static const successLight = Color(0xFFD4F5D9);
  static const warning = Color(0xFFFF8C42);
  static const warningLight = Color(0xFFFFD4B8);
  static const danger = Color(0xFFFF6B6B);
  static const dangerLight = Color(0xFFFFD4D4);
  static const info = Color(0xFF5B9BFF);
  static const infoLight = Color(0xFFD4E8FF);
  static const purple = Color(0xFF9B7BFF);
  static const purpleLight = Color(0xFFE4DAFF);
  static const teal = Color(0xFF4ECDC4);
  static const statusUsing = Color(0xFF3A9E4A);
  static const statusUsingBg = Color(0xFFD4F5D9);
  static const selectedBg = Color(0xFFD4E8FF);
  static const accentLight = Color(0xFFFFE066);

  // ── 额外背景色 ──
  static const accentLightBg = Color(0xFFFFF3CC);
  static const shimmerGold = Color(0xFFFFB800);
  static const shimmerOrange = Color(0xFFFF8C42);
  static const shimmerRed = Color(0xFFFF6B6B);
  static const shimmerGreen = Color(0xFF6BCB77);

  // ── 渐变起始色（快捷操作） ──
  static const gradientGold = Color(0xFFFFD460);
  static const gradientOrange = Color(0xFFFF9E6C);
  static const gradientOrangeEnd = Color(0xFFFF7A30);
  static const gradientGreen = Color(0xFF7EE08A);
  static const gradientGreenEnd = Color(0xFF4BC25A);
  static const gradientBlue = Color(0xFF8AB4FF);
  static const gradientBlueEnd = Color(0xFF5588EE);

  // ── 标签色 ──
  static const tagNew = Color(0xFF3A9E4A);
  static const tagNewBg = Color(0xFFD4F5D9);
  static const tagUrgent = Color(0xFFFF6B6B);
  static const tagNormal = Color(0xFF5B9BFF);

  // ── 阴影色（带透明度） ──
  static const shadowPrimary = Color(0x1FFFB800);
  static const shadowDark = Color(0x0D3D2B1F);
  static const shadowCard = Color(0x1AFFB800);
}