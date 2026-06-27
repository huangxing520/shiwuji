import 'package:flutter/material.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/models/platform_data.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';

/// Platform selection grid widget.
class PlatformGrid extends StatelessWidget {
  final List<PlatformData> platforms;
  final void Function(PlatformData) onPlatformTap;

  const PlatformGrid({
    super.key,
    required this.platforms,
    required this.onPlatformTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: platforms.length + 1, // +1 for "more"
      itemBuilder: (context, index) {
        if (index == platforms.length) {
          return _buildMoreButton(context);
        }
        return _buildPlatformItem(platforms[index]);
      },
    );
  }

  Widget _buildPlatformItem(PlatformData platform) {
    return GestureDetector(
      onTap: () => onPlatformTap(platform),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: platform.gradientColors,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowCard,
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    platform.iconText,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Connection status dot
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color:
                        platform.connected ? AppColors.success : AppColors.textHint,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cardBg, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            platform.name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return GestureDetector(
      onTap: () => ToastUtils.show(context, '更多平台开发中…'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppColors.cardBg,
              border: Border.all(
                color: AppColors.border,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowCard,
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 24, color: AppColors.textHint),
          ),
          const SizedBox(height: 8),
          const Text(
            '更多',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
