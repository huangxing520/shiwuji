import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import 'card_container.dart';
import 'emoji_text.dart';

/// 倒计时卡片 — 质保 / 维护倒计时
class CountdownCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String date;
  final bool isWarning;

  const CountdownCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.date,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CardContainer(
        borderRadius: AppDimensions.borderRadiusExtraLarge,
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        child: Column(
          children: [
            EmojiText(emoji: icon, fontSize: 24),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.labelMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.colored(
                color: isWarning ? AppColors.danger : AppColors.success,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(date, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}
