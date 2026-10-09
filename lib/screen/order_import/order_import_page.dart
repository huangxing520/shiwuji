import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/models/history_record.dart';
import 'package:shi_wu_ji/models/platform_data.dart';
import 'package:shi_wu_ji/providers/import_providers.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';
import 'package:shi_wu_ji/widgets/emoji_text.dart';

import 'platform_grid.dart';
import 'platform_tutorial_sheet.dart';

// ==================== Main Page ====================
class OrderImportPage extends ConsumerStatefulWidget {
  const OrderImportPage({super.key});

  @override
  ConsumerState<OrderImportPage> createState() => _OrderImportPageState();
}

class _OrderImportPageState extends ConsumerState<OrderImportPage>
    with TickerProviderStateMixin {
  // Currently selected platform
  PlatformData? _selectedPlatform;

  // Time range
  String _selectedTimeRange = 'all';

  // Import options
  bool _onlyPhysical = true;
  bool _autoMatch = true;

  // Hero number animations
  late AnimationController _heroAnimController;
  late Animation<int> _platformCountAnim;

  // Config panel animation
  late AnimationController _configAnimController;
  late Animation<double> _configFadeAnim;
  late Animation<Offset> _configSlideAnim;

  // Button shine animation
  late AnimationController _btnShineController;

  @override
  void initState() {
    super.initState();

    // Hero number animations
    _heroAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _platformCountAnim = IntTween(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _heroAnimController, curve: Curves.easeOutCubic),
    );
    _heroAnimController.forward();

    // Config panel animation
    _configAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _configFadeAnim = CurvedAnimation(
      parent: _configAnimController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    );
    _configSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _configAnimController,
            curve: Curves.easeOutBack,
          ),
        );

    // Button shine
    _btnShineController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _heroAnimController.dispose();
    _configAnimController.dispose();
    _btnShineController.dispose();
    super.dispose();
  }

  // ==================== Platform Selection & Tutorial Sheet ====================
  void _openPlatform(PlatformData platform) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlatformTutorialSheet(
        platform: platform,
        onConfirm: () {
          Navigator.pop(ctx);
          _confirmPlatform(platform);
        },
      ),
    );
  }

  void _confirmPlatform(PlatformData platform) {
    setState(() => _selectedPlatform = platform);
    _configAnimController.forward(from: 0);
    ToastUtils.show(context, '已选择「${platform.name}」');
  }

  // ==================== 导入（尚未实现）====================
  //
  // 该功能目前只完成了界面骨架：平台网格与教程文案都是静态展示，
  // 既没有「上传订单文件」入口，也没有任何真实订单数据源。
  //
  // 早期版本这里用 Random() 按 90% 概率伪造「成功/失败」，把 18 条写死的
  // 演示商品名（戴森吸尘器、AirPods…）当成订单写进真实数据库，并记一条
  // 假的导入历史。那会让用户在完全不知情的情况下得到几十条与真实订单
  // 无关的物品记录，因此已移除：在接入真实解析之前，这里不写入任何数据。
  void _startImport() {
    if (_selectedPlatform == null) {
      ToastUtils.show(context, '请先选择购物平台');
      return;
    }
    _showNotImplementedDialog();
  }

  void _showNotImplementedDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Text('🚧 ', style: TextStyle(fontSize: 20)),
            Text(
              '功能开发中',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          '订单自动导入还没有接入真实的订单数据源，暂时无法使用。\n\n'
          '在它完成之前，这里不会写入任何数据，你的物品库不会被改动。\n\n'
          '现在可以先在「新增物品」里手动记录。',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  // ==================== Build ====================
  @override
  Widget build(BuildContext context) {
    // Watch providers
    final platforms = ref.watch(platformsProvider);
    final historyAsync = ref.watch(importHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 8),
                      _buildHeroBanner(),
                      const SizedBox(height: 20),
                      _buildSectionTitle(
                        iconBg: AppColors.primaryLight,
                        iconColor: AppColors.primaryDark,
                        icon: Icons.grid_view,
                        title: '选择购物平台',
                      ),
                      const SizedBox(height: 12),
                      PlatformGrid(
                        platforms: platforms,
                        onPlatformTap: _openPlatform,
                      ),
                      const SizedBox(height: 20),
                      if (_selectedPlatform != null) _buildConfigPanel(),
                      const SizedBox(height: 20),
                      _buildSectionTitle(
                        iconBg: AppColors.successLight,
                        iconColor: AppColors.statusUsing,
                        icon: Icons.check_circle,
                        title: '导入记录',
                      ),
                      const SizedBox(height: 12),
                      _buildHistoryList(historyAsync),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== Top Navigation Bar ====================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '订单导入',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Help button
          GestureDetector(
            onTap: () => ToastUtils.show(context, '导入常见问题解答'),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.help_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Hero Banner ====================
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientGold,
            AppColors.primary,
            AppColors.primaryDeep,
          ],
          stops: [0.0, 0.4, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: 40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        '🛒 一键导入购物订单',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      _ComingSoonBadge(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '订单自动解析功能开发中，暂未接入真实订单数据',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildHeroStat(
                        value: '${_platformCountAnim.value}',
                        label: '计划支持平台',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStat({required String value, required String label}) {
    return AnimatedBuilder(
      animation: _heroAnimController,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  // ==================== Section Title ====================
  Widget _buildSectionTitle({
    required Color iconBg,
    required Color iconColor,
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ==================== Config Panel ====================
  Widget _buildConfigPanel() {
    return FadeTransition(
      opacity: _configFadeAnim,
      child: SlideTransition(
        position: _configSlideAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
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
              // Import range
              _buildConfigLabel('选择导入范围', AppColors.primary),
              const SizedBox(height: 10),
              _buildTimeChips(),
              // Custom date
              if (_selectedTimeRange == 'custom') ...[
                const SizedBox(height: 10),
                _buildCustomDateRow(),
              ],
              const SizedBox(height: 18),
              // Import options
              _buildConfigLabel('导入选项', AppColors.warning),
              const SizedBox(height: 10),
              _buildCheckboxRow(
                label: '仅导入实物商品订单',
                value: _onlyPhysical,
                onChanged: (v) => setState(() => _onlyPhysical = v),
              ),
              const SizedBox(height: 8),
              _buildCheckboxRow(
                label: '自动匹配已有物品',
                value: _autoMatch,
                onChanged: (v) => setState(() => _autoMatch = v),
              ),
              const SizedBox(height: 18),
              // Start import button
              _buildImportButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigLabel(String text, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: timeRangeOptions.map((range) {
        final isSelected = _selectedTimeRange == range['key'];
        return GestureDetector(
          onTap: () => setState(() => _selectedTimeRange = range['key']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Text(
              range['label']!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomDateRow() {
    return Row(
      children: [
        Expanded(child: _buildDateInput('2024-01-01')),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '至',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textHint,
            ),
          ),
        ),
        Expanded(child: _buildDateInput('2025-06-01')),
      ],
    );
  }

  Widget _buildDateInput(String defaultDate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 14, color: AppColors.textHint),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              defaultDate,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportButton() {
    return GestureDetector(
      onTap: _startImport,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.cardBg,
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: const Center(
          child: Text(
            '订单导入开发中',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== History List ====================
  Widget _buildHistoryList(AsyncValue<List<HistoryRecord>> historyAsync) {
    return historyAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (records) {
        if (records.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                '暂无导入记录',
                style: TextStyle(fontSize: 13, color: AppColors.textHint),
              ),
            ),
          );
        }
        return Column(
          children: records.map((record) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => ToastUtils.show(
                  context,
                  '查看${record.title.replaceAll('订单导入', '')}导入详情',
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: record.iconBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: EmojiText(emoji: record.emoji, fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              record.meta,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Count
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${record.count}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const TextSpan(
                              text: ' 件',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// 「开发中」角标：用于明确标注尚未实现的功能，避免界面暗示功能已可用。
class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '开发中',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
