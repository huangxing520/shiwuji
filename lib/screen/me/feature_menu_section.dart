import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';

/// 功能入口列表
class FeatureMenuSection extends ConsumerWidget {
  final VoidCallback onHelpTap;

  const FeatureMenuSection({super.key, required this.onHelpTap});

  static const _entries = [
    _MenuEntry(
      icon: Icons.cloud_upload_outlined,
      title: '数据备份',
      subtitle: 'WebDAV 云端备份与恢复',
      color: AppColors.primary,
      route: '/data-backup',
    ),
    _MenuEntry(
      icon: Icons.notifications_outlined,
      title: '通知设置',
      subtitle: '保修到期提醒与推送',
      color: AppColors.warning,
      route: '/notification-settings',
    ),
    _MenuEntry(
      icon: Icons.lock_outline,
      title: '私密空间',
      subtitle: '保护隐私物品',
      color: AppColors.purple,
      comingSoon: true,
    ),
    _MenuEntry(
      icon: Icons.family_restroom,
      title: '家庭共享',
      subtitle: '与家人共享物品信息',
      color: AppColors.info,
      comingSoon: true,
    ),
    _MenuEntry(
      icon: Icons.update_outlined,
      title: '检查更新',
      subtitle: '检查是否有新版本可用',
      color: AppColors.info,
      route: '/check-update',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ...List.generate(_entries.length, (i) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 400),
              curve: const Cubic(0.34, 1.56, 0.64, 1),
              builder: (context, t, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - t)),
                  child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(top: i > 0 ? 10 : 0),
                child: _buildRow(context, _entries[i]),
              ),
            );
          }),
          // AI 模型设置
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: const Cubic(0.34, 1.56, 0.64, 1),
            builder: (context, t, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - t)),
                child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _buildRow(
                context,
                const _MenuEntry(
                  icon: Icons.smart_toy_outlined,
                  title: 'AI 模型设置',
                  subtitle: '选择供应商、配置 API Key',
                  color: AppColors.info,
                  route: '/ai-settings',
                ),
              ),
            ),
          ),
          // 帮助反馈
          // TweenAnimationBuilder<double>(
          //   tween: Tween(begin: 0, end: 1),
          //   duration: const Duration(milliseconds: 400),
          //   curve: const Cubic(0.34, 1.56, 0.64, 1),
          //   builder: (context, t, child) {
          //     return Transform.translate(
          //       offset: Offset(0, 20 * (1 - t)),
          //       child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
          //     );
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.only(top: 10),
          //     child: _buildRow(
          //       context,
          //       const _MenuEntry(
          //         icon: Icons.help_outline,
          //         title: '帮助反馈',
          //         subtitle: '使用帮助与意见反馈',
          //         color: AppColors.success,
          //       ),
          //       onTap: onHelpTap,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  /// AI 模型配置已迁移到 `/ai-settings` 页面，此 section 仅负责入口展示

  Widget _buildRow(
    BuildContext context,
    _MenuEntry entry, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            if (entry.comingSoon) {
              ToastUtils.show(context, '即将上线，敬请期待');
            } else if (entry.route != null) {
              context.push(entry.route!);
            }
          },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: entry.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(entry.icon, size: 24, color: entry.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (entry.comingSoon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '即将上线',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Icon(Icons.chevron_right, size: 20, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _MenuEntry {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? route;
  final bool comingSoon;

  const _MenuEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.route,
    this.comingSoon = false,
  });
}
