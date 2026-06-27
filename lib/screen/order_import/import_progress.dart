import 'package:flutter/material.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';

/// Data class for a single imported item displayed in the progress list.
class ImportedItem {
  final String emoji;
  final String name;
  final String price;
  final bool success;

  const ImportedItem({
    required this.emoji,
    required this.name,
    required this.price,
    required this.success,
  });
}

/// Import progress section — shows progress bar, stats, and imported items list.
class ImportProgressSection extends StatelessWidget {
  final bool importDone;
  final bool isImporting;
  final String? platformName;
  final double progressValue;
  final int totalCount;
  final int successCount;
  final int failCount;
  final int pendingCount;
  final List<ImportedItem> importedItems;
  final Animation<double> fadeAnimation;
  final AnimationController shimmerController;

  const ImportProgressSection({
    super.key,
    required this.importDone,
    required this.isImporting,
    this.platformName,
    required this.progressValue,
    required this.totalCount,
    required this.successCount,
    required this.failCount,
    required this.pendingCount,
    required this.importedItems,
    required this.fadeAnimation,
    required this.shimmerController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowCard,
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  importDone
                      ? '导入完成！'
                      : '正在导入${platformName ?? ''}订单…',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: importDone
                        ? AppColors.successLight
                        : isImporting
                            ? AppColors.accentLight
                            : AppColors.dangerLight,
                  ),
                  child: Text(
                    importDone
                        ? '已完成'
                        : isImporting
                            ? '导入中'
                            : '出错',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: importDone
                          ? AppColors.statusUsing
                          : isImporting
                              ? AppColors.primaryDark
                              : AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress bar
            _buildProgressBar(),
            const SizedBox(height: 10),
            // Stats
            _buildProgressStats(),
            const SizedBox(height: 14),
            // Imported items list
            _buildProgressItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 10,
        child: Stack(
          children: [
            // Background
            Container(color: AppColors.background),
            // Fill
            AnimatedBuilder(
              animation: shimmerController,
              builder: (context, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressValue,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.warning],
                          ),
                        ),
                      ),
                      // Shimmer effect
                      Positioned.fill(
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            final shimmerX =
                                (shimmerController.value * 2 - 1) * rect.width;
                            return LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              transform: _SlidingGradientTransform(
                                  shimmerX / rect.width),
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.srcATop,
                          child: Container(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem(
            value: '$totalCount', label: '总订单', color: AppColors.textPrimary),
        _buildStatItem(
            value: '$successCount', label: '成功', color: AppColors.success),
        _buildStatItem(
            value: '$failCount', label: '失败', color: AppColors.danger),
        _buildStatItem(
            value: '$pendingCount', label: '等待中', color: AppColors.warning),
      ],
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressItems() {
    if (importedItems.isEmpty) return const SizedBox.shrink();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 160),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: importedItems.length,
        separatorBuilder: (_, _) => const Divider(
          color: AppColors.border,
          height: 1,
          thickness: 1,
        ),
        itemBuilder: (context, index) {
          final item = importedItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  item.price,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: item.success
                        ? AppColors.successLight
                        : AppColors.dangerLight,
                  ),
                  child: Text(
                    item.success ? '成功' : '失败',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: item.success
                          ? AppColors.statusUsing
                          : AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Gradient transform for shimmer animation on the progress bar.
class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}
