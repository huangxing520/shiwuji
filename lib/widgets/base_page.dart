import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import 'gradient_background.dart';

/// 统一页面骨架 — Scaffold + GradientBackground + SafeArea
class BasePage extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget child;
  final bool useScrollView;
  final List<Color>? gradientColors;
  final EdgeInsetsGeometry? padding;

  const BasePage({
    super.key,
    this.appBar,
    required this.child,
    this.useScrollView = true,
    this.gradientColors,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: GradientBackground(
        colors: gradientColors,
        child: SafeArea(
          child: useScrollView
              ? SingleChildScrollView(
                  padding: padding ?? AppDimensions.pagePadding,
                  child: child,
                )
              : child,
        ),
      ),
    );
  }
}