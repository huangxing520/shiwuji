import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import 'card_container.dart';
import 'emoji_text.dart';

/// 倒计时卡片状态：
/// - normal：正常有效（绿色）
/// - expiringSoon：即将到期 / 当天到期（橙色）
/// - expired：已过期（红色）
enum CountdownStatus { normal, expiringSoon, expired }

/// 倒计时卡片 — 保修 / 保质 倒计时
///
/// 数字为卡片焦点，[status] 决定数字颜色；桌面端鼠标悬停时轻微上抬，
/// 提供「可点击」的视觉暗示（触屏无 hover 自然不触发）。
class CountdownCard extends StatefulWidget {
  final String icon;
  final String label;
  final String value;
  final String date;
  final CountdownStatus status;
  final VoidCallback? onTap;

  const CountdownCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.date,
    this.status = CountdownStatus.normal,
    this.onTap,
  });

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  bool _hovering = false;

  Color _valueColor() {
    switch (widget.status) {
      case CountdownStatus.expired:
        return AppColors.danger;
      case CountdownStatus.expiringSoon:
        return AppColors.warning;
      case CountdownStatus.normal:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = CardContainer(
      borderRadius: AppDimensions.borderRadiusExtraLarge,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      onTap: widget.onTap,
      child: Column(
        children: [
          EmojiText(emoji: widget.icon, fontSize: 24),
          const SizedBox(height: 6),
          Text(widget.label, style: AppTextStyles.labelMedium),
          const SizedBox(height: 4),
          Text(
            widget.value,
            style: AppTextStyles.colored(
              color: _valueColor(),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(widget.date, style: AppTextStyles.labelSmall),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: _hovering
            ? Matrix4.translationValues(0.0, -2.0, 0.0)
            : Matrix4.identity(),
        child: card,
      ),
    );
  }
}
