import 'package:flutter/material.dart';

/// 圆形图标按钮 — 半透明背景的小按钮（返回 / 更多）
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.size = 38,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.47),
      ),
    );
  }
}