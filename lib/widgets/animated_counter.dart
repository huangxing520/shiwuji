import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedCounter extends StatefulWidget {
  final int target;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.target,
    this.prefix,
    this.suffix,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _displayValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.addListener(_updateValue);
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  void _updateValue() {
    final eased = 1 - math.pow(1 - _animation.value, 3).toDouble();
    setState(() {
      _displayValue = (widget.target * eased).round();
    });
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _displayValue = 0;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateValue);
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(int n) {
    if (n > 999) return _formatWithCommas(n);
    return n.toString();
  }

  String _formatWithCommas(int n) {
    final str = n.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    final text = '${widget.prefix ?? ''}${_formatNumber(_displayValue)}${widget.suffix ?? ''}';
    return Text(text, style: widget.style);
  }
}