import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/widgets/gradient_background.dart';
import 'package:shi_wu_ji/widgets/section_title.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';
import 'package:shi_wu_ji/providers/profile_provider.dart';
import 'profile_header_section.dart';
import 'data_stats_section.dart';
import 'feature_menu_section.dart';
import 'edit_profile_modal.dart';
import 'help_feedback_sheet.dart';

class MePage extends ConsumerStatefulWidget {
  const MePage({super.key});

  @override
  ConsumerState<MePage> createState() => _MePageState();
}

class _MePageState extends ConsumerState<MePage> {
  bool _showEditModal = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            _buildBackgroundDecoration(),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        _buildPageHeader(),
                        const SizedBox(height: 16),
                        ProfileHeaderSection(onEdit: _openEditModal),
                        const SizedBox(height: 24),
                        const SectionTitle(title: '数据概览'),
                        const SizedBox(height: 14),
                        const DataStatsSection(),
                        const SizedBox(height: 24),
                        const SectionTitle(title: '功能服务'),
                        const SizedBox(height: 14),
                        FeatureMenuSection(
                          onHelpTap: () => HelpFeedbackSheet.show(context),
                        ),
                        //const SizedBox(height: 32),
                        //_buildVersionInfo(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_showEditModal) _buildEditModal(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: 80,
            left: -50,
            width: 180,
            height: 180,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 350,
            right: -30,
            width: 120,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 220,
            left: -20,
            width: 100,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '个人中心',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '管理账号与应用设置',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 扫描按钮：调用 flutter_smart_scanner 识别物体
          GestureDetector(
            onTap: () => context.push('/scan'),
            child: Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: Color(0xFFFFF3DD), // 和头像背景同色系浅暖黄
      borderRadius: BorderRadius.circular(99),
    ),
    child: Center(
      child: Icon(Icons.crop_free, size: 22, color: Color(0xFF33281E)),
    ),
  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return GestureDetector(
      onTap: () => context.push('/check-update'),
      child: Center(
        child: Column(
          children: [
            Text(
              '拾物记 v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '点击检查更新',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.primary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditModal() {
    setState(() => _showEditModal = true);
  }

  Widget _buildEditModal() {
    final profile = ref.read(profileManagerProvider).value ?? {};
    return EditProfileModal(
      currentNickname: profile['nickname'] ?? '小橘',
      currentEmoji: profile['avatar_emoji'] ?? '🧑',
      onClose: () => setState(() => _showEditModal = false),
      onConfirm: ({required String nickname, required String emoji}) {
        ref.read(profileManagerProvider.notifier).updateNickname(nickname);
        ref.read(profileManagerProvider.notifier).updateAvatarEmoji(emoji);
        setState(() => _showEditModal = false);
        ToastUtils.show(context, '资料已更新');
      },
    );
  }
}
