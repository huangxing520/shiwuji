import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'animated_counter.dart';

class DataCard extends StatefulWidget {
  final IconData icon;
  final int target;
  final String unit;
  final String label;
  final String trendLabel;
  final bool trendUp;
  final Color color;
  final Color decoColor;
  final Color iconBgColor;
  final Color iconColor;
  final int delayMs;

  const DataCard({
    super.key,
    required this.icon,
    required this.target,
    required this.unit,
    required this.label,
    required this.trendLabel,
    required this.trendUp,
    required this.color,
    required this.decoColor,
    required this.iconBgColor,
    required this.iconColor,
    this.delayMs = 0,
  });

  @override
  State<DataCard> createState() => _DataCardState();
}

class _DataCardState extends State<DataCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounceAnim;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Cubic(0.34, 1.56, 0.64, 1),
      ),
    );
    if (widget.delayMs == 0) {
      _ctrl.forward();
      _visible = true;
    } else {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) {
          setState(() => _visible = true);
          _ctrl.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
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
      child: Container(clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowCard,
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.decoColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.iconBgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 22),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: AnimatedCounter(
                          target: widget.target,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: widget.color,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          widget.unit,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: widget.color.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.trendUp
                          ? AppColors.tagNewBg
                          : AppColors.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.trendUp ? Icons.trending_up : Icons.trending_down,
                          size: 12,
                          color: widget.trendUp
                              ? AppColors.tagNew
                              : AppColors.danger,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.trendLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: widget.trendUp
                                ? AppColors.tagNew
                                : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}