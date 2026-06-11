import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';

/// 信息单元格 — 标签 + 值（用于 GridView 排列）
class InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final bool isAccent;

  const InfoCell({
    super.key,
    required this.label,
    required this.value,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 3),
        Text(value, style: AppTextStyles.infoValue(isAccent: isAccent)),
      ],
    );
  }
}