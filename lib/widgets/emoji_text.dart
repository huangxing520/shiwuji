import 'package:flutter/material.dart';

/// 使用 Noto Color Emoji 字体渲染 emoji 的统一组件。
///
/// Noto Color Emoji 是 Google 开源的彩色 emoji 字体（CBDT 位图格式），
/// 覆盖完整 Unicode Emoji 17.0，所有码点都有彩色字形，从根本上解决
/// 系统字体裁剪导致的「矩形叉标」问题，并提供统一的 Google 风格视觉。
///
/// 项目中所有 emoji 显示点都应使用此组件，替代裸 `Text(emoji, ...)`，
/// 确保跨平台（Android/iOS/Windows/macOS/Linux/Web）一致的渲染效果。
///
/// 使用方式：
/// ```dart
/// EmojiText(emoji: '🧹', fontSize: 24)
/// EmojiText(emoji: item.emoji, fontSize: 48, color: Colors.black)
/// ```
///
/// 注意：
/// - 当前使用 NotoColorEmoji-Regular（CBDT 彩色位图版）
/// - 字体来源：https://github.com/googlefonts/noto-emoji
class EmojiText extends StatelessWidget {
  /// 要渲染的 emoji 字符（支持单字符、ZWJ 序列、带 VS16 等）
  final String emoji;

  /// 字号，默认 24
  final double fontSize;

  /// 文字颜色（黑白字体下生效，默认 null 使用主题前景色）
  final Color? color;

  /// 文字对齐方式
  final TextAlign? textAlign;

  /// 文字方向
  final TextDirection? textDirection;

  /// 是否软换行
  final bool softWrap;

  /// 溢出处理
  final TextOverflow? overflow;

  /// 额外的 TextStyle（会与 fontFamily 合并，fontFamily 优先级最高）
  final TextStyle? style;

  const EmojiText({
    super.key,
    required this.emoji,
    this.fontSize = 24,
    this.color,
    this.textAlign,
    this.textDirection,
    this.softWrap = true,
    this.overflow,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: (style ?? const TextStyle()).copyWith(
        fontFamily: 'NotoColorEmoji',
        fontSize: fontSize,
        color: color,
      ),
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
    );
  }
}
