import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/providers/profile_provider.dart';
import 'package:shi_wu_ji/widgets/emoji_text.dart';

/// 头像 + 昵称卡片
class ProfileHeaderSection extends ConsumerWidget {
  final VoidCallback onEdit;

  const ProfileHeaderSection({super.key, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileManagerProvider);

    return profile.when(
      loading: () => _buildSkeleton(),
      error: (_, __) => _buildSkeleton(),
      data: (data) => _buildCard(
        nickname: data['nickname'] ?? '小橘',
        emoji: data['avatar_emoji'] ?? '🧑',
      ),
    );
  }

  Widget _buildCard({required String nickname, required String emoji}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: const Cubic(0.34, 1.56, 0.64, 1),
      builder: (context, t, child) {
        return Transform.scale(
          scale: 0.8 + 0.2 * t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 头像
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(child: EmojiText(emoji: emoji, fontSize: 32)),
              ),
              const SizedBox(width: 16),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '管理我的物品世界',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // 编辑按钮
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 104,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
