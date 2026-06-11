import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Overlay 面板头部 — 左侧标题 + 右侧关闭按钮
class OverlayHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const OverlayHeader({
    super.key,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.overlayTitle),
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              color: AppColors.textHint,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }
}