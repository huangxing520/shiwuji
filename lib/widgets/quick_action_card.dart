import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color startColor;
  final Color endColor;
  final VoidCallback? onTap;
  final int delayMs;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.startColor,
    required this.endColor,
    this.onTap,
    this.delayMs = 0,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard>
    with TickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;
  late AnimationController _breathCtrl;
  late Animation<double> _breathAnim;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _bounceCtrl,
        curve: const Cubic(0.34, 1.56, 0.64, 1),
      ),
    );
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _breathAnim = CurvedAnimation(
      parent: _breathCtrl,
      curve: Curves.easeInOut,
    );

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        setState(() => _visible = true);
        _bounceCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bounceAnim,
        builder: (context, child) {
          return Opacity(
            opacity: _bounceAnim.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _bounceAnim.value,
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _breathAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + _breathAnim.value * 0.06,
                  child: child,
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [widget.startColor, widget.endColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.startColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 26),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}