import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/constants/app_text_styles.dart';
import 'package:shi_wu_ji/constants/app_shadows.dart';
import 'package:shi_wu_ji/widgets/gradient_background.dart';
import 'package:shi_wu_ji/services/first_run_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _progress = 0.0;
  bool _isFading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      _runProgress();
    });
  }

  void _runProgress() {
    final start = DateTime.now().millisecondsSinceEpoch;
    const total = 2000;

    void update() {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - start;
      final raw = (elapsed / total).clamp(0.0, 1.0);

      if (mounted) {
        setState(() {
          _progress = raw;
        });
      }

      if (raw < 1.0) {
        Future.delayed(const Duration(milliseconds: 16), update);
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _isFading = true;
            });
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                FirstRunService.markCompleted();
                context.go('/home');
              }
            });
          }
        });
      }
    }

    update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _isFading ? 0.0 : 1.0,
        child: GradientBackground(
          colors: const [
            AppColors.background,
            AppColors.backgroundLight,
            AppColors.primaryMid,
          ],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 28),
                _buildTitle(),
                const SizedBox(height: 10),
                _buildSubtitle(),
                const SizedBox(height: 20),
                _buildLine(),
                const SizedBox(height: 80),
                _buildProgress(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 900),
      tween: Tween(begin: 0.3, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryMid,
                  AppColors.primary,
                  AppColors.primaryDeep,
                ],
              ),
              boxShadow: AppShadows.logo,
            ),
            child: const Center(
              child: Icon(Icons.inventory_2, size: 64, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 650),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: const Text('拾物记', style: AppTextStyles.splashTitle),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: const Text('记录每个物品的故事', style: AppTextStyles.splashSubtitle),
          ),
        );
      },
    );
  }

  Widget _buildLine() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(
            scaleX: value,
            alignment: Alignment.centerLeft,
            child: Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.warning],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.shadowPrimary,
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.warning],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: _progress > 0 ? 1.0 : 0.0,
            child: Text(
              '${(_progress * 100).round()}%',
              style: AppTextStyles.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
