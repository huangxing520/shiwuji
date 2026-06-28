import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/widgets/gradient_background.dart';
import 'package:shi_wu_ji/widgets/emoji_text.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';
import 'package:shi_wu_ji/providers/category_provider.dart';
import 'package:shi_wu_ji/models/category_item.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';
import 'add_category_modal.dart';

/// 分类管理页面
class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  bool _showAddModal = false;
  bool _isReordering = false;

  // 编辑模式状态
  String? _editingId;
  String? _editingLabel;
  String? _editingEmoji;

  void _openAddModal() {
    setState(() {
      _editingId = null;
      _editingLabel = null;
      _editingEmoji = null;
      _showAddModal = true;
    });
  }

  void _openEditModal(CategoryItem cat) {
    setState(() {
      _editingId = cat.id;
      _editingLabel = cat.label;
      _editingEmoji = cat.emoji;
      _showAddModal = true;
    });
  }

  void _closeModal() {
    setState(() => _showAddModal = false);
  }

  void _onModalConfirm({required String label, required String emoji}) {
    final mgr = ref.read(categoryManagerProvider.notifier);
    if (_editingId != null) {
      mgr.updateCategory(_editingId!, label: label, emoji: emoji);
      ToastUtils.show(context, '「$label」已更新');
    } else {
      mgr.addCategory(label: label, emoji: emoji);
      ToastUtils.show(context, '「$label」已添加');
    }
    _closeModal();
  }

  void _confirmDelete(CategoryItem cat) async {
    final count = await ref
        .read(categoryManagerProvider.notifier)
        .itemCountForCategory(cat.label);

    if (!mounted) return;

    if (count > 0) {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '删除「${cat.label}」？',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            '该分类下有 $count 件物品，删除后物品将变为「未分类」。',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                '取消',
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                '确认删除',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        ),
      );
      if (shouldDelete != true) return;
    }

    await ref.read(categoryManagerProvider.notifier).deleteCategory(cat.id);
    if (mounted) {
      ToastUtils.show(context, '「${cat.label}」已删除');
    }
  }

  void _showCategoryActions(CategoryItem cat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              cat.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionItem(
              icon: Icons.edit_outlined,
              iconColor: AppColors.accentGold,
              label: '编辑分类',
              onTap: () {
                Navigator.pop(ctx);
                _openEditModal(cat);
              },
            ),
            if (!cat.isBuiltIn)
              _buildActionItem(
                icon: Icons.delete_outline,
                iconColor: AppColors.danger,
                label: '删除分类',
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(cat);
                },
              ),
            _buildActionItem(
              icon: Icons.inventory_2_outlined,
              iconColor: AppColors.info,
              label: '查看该分类物品',
              onTap: () {
                Navigator.pop(ctx);
                ref.read(pendingCategoryProvider.notifier).set(cat.id);
                context.go('/inventory');
                ToastUtils.show(context, '筛选「${cat.label}」分类');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0E4D0), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryManagerProvider);

    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            _buildBackgroundDecoration(),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: categoriesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('加载失败: $e')),
                      data: (categories) => _buildContent(categories),
                    ),
                  ),
                ],
              ),
            ),
            if (_showAddModal)
              AddCategoryModal(
                onClose: _closeModal,
                onConfirm: _onModalConfirm,
                editLabel: _editingLabel,
                editEmoji: _editingEmoji,
                title: _editingId != null ? '编辑分类' : '新增分类',
              ),
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
            top: 40,
            right: -30,
            width: 140,
            height: 140,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -20,
            width: 100,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gradientGreen.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<CategoryItem> categories) {
    final builtIns = categories.where((c) => c.isBuiltIn).toList();
    final customs = categories.where((c) => !c.isBuiltIn).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildStatsBanner(categories),
        const SizedBox(height: 20),
        _buildSectionHeader('系统分类', '${builtIns.length} 个'),
        const SizedBox(height: 12),
        _buildCategoryGrid(builtIns),
        const SizedBox(height: 24),
        _buildSectionHeader(
          '自定义分类',
          '${customs.length} 个',
          trailing: customs.length > 1
              ? GestureDetector(
                  onTap: () => setState(() => _isReordering = !_isReordering),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isReordering
                          ? AppColors.accentGold.withValues(alpha: 0.15)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isReordering ? Icons.check : Icons.drag_indicator,
                          size: 14,
                          color: _isReordering
                              ? AppColors.accentGold
                              : AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isReordering ? '完成' : '排序',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _isReordering
                                ? AppColors.accentGold
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        if (customs.isEmpty)
          _buildEmptyCustom()
        else
          _buildCustomSection(customs),
        const SizedBox(height: 80),
      ],
    );
  }

  // ─── Header ──────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              '分类管理',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: _openAddModal,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.warning],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Banner ────────────────────────────────────

  Widget _buildStatsBanner(List<CategoryItem> categories) {
    final builtInCount = categories.where((c) => c.isBuiltIn).length;
    final customCount = categories.where((c) => !c.isBuiltIn).length;
    final total = categories.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFD460), Color(0xFFFFB800), Color(0xFFFF9E40)],
            stops: [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0x33FFB800),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: 40,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Row(
              children: [
                _buildBannerStat(total, '全部分类'),
                _buildBannerStat(builtInCount, '系统分类'),
                _buildBannerStat(customCount, '自定义'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerStat(int num, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$num',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xBFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ──────────────────────────────────

  Widget _buildSectionHeader(
    String title,
    String subtitle, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // ─── Category Grid ───────────────────────────────────

  Widget _buildCategoryGrid(List<CategoryItem> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: categories.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value;
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 52) / 2,
            child: _CategoryCard(
              category: cat,
              delay: i * 0.06,
              onTap: () => _showCategoryActions(cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Custom Section ──────────────────────────────────

  Widget _buildCustomSection(List<CategoryItem> customs) {
    if (_isReordering) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: customs.length,
          onReorder: (oldIdx, newIdx) {
            ref
                .read(categoryManagerProvider.notifier)
                .reorderCustom(oldIdx, newIdx);
          },
          itemBuilder: (context, i) {
            return Padding(
              key: ValueKey(customs[i].id),
              padding: const EdgeInsets.only(bottom: 10),
              child: _CategoryCard(
                category: customs[i],
                isReorderable: true,
                onLongPress: () => _showCategoryActions(customs[i]),
                dragHandle: ReorderableDragStartListener(
                  index: i,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.drag_handle,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: customs.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value;
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 52) / 2,
            child: _CategoryCard(
              category: cat,
              delay: i * 0.06,
              onTap: () => _showCategoryActions(cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyCustom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _openAddModal,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  size: 24,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '暂无自定义分类',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '点击右上角 + 添加你常用的品类',
                style: TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category Card Widget ──────────────────────────────

class _CategoryCard extends StatelessWidget {
  final CategoryItem category;
  final double delay;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isReorderable;
  final Widget? dragHandle;

  const _CategoryCard({
    required this.category,
    this.delay = 0,
    this.onTap,
    this.onLongPress,
    this.isReorderable = false,
    this.dragHandle,
  });

  @override
  Widget build(BuildContext context) {
    if (isReorderable) {
      return _buildReorderableCard();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: const Cubic(0.34, 1.4, 0.64, 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _buildCardContent(onTap: onTap, onLongPress: onLongPress),
    );
  }

  Widget _buildReorderableCard() {
    return _buildCardContent(onLongPress: onLongPress, trailing: dragHandle);
  }

  Widget _buildCardContent({
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Widget? trailing,
  }) {
    // 为每个分类生成柔和的主题色
    final accentColor = _accentColorForCategory(category.id);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 顶部色条
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withValues(alpha: 0.5)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Row(
                children: [
                  // Emoji 图标
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: EmojiText(emoji: category.emoji, fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 分类信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category.isBuiltIn ? '系统分类' : '自定义',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null)
                    trailing
                  else
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        size: 14,
                        color: AppColors.textHint,
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

  /// 为不同分类生成柔和的主题色
  Color _accentColorForCategory(String id) {
    const palette = {
      'digital': Color(0xFF5B9BFF),
      'appliance': Color(0xFFFF8C42),
      'skincare': Color(0xFFFF6B9D),
      'kitchen': Color(0xFFFF6B6B),
      'clothing': Color(0xFF9B7BFF),
      'books': Color(0xFF4ECDC4),
      'storage': Color(0xFFFFB800),
      'toy': Color(0xFFFF8FA3),
      'sports': Color(0xFF6BCB77),
      'stationery': Color(0xFFFF9E40),
      'keys': Color(0xFFE5A500),
      'tools': Color(0xFF7B8794),
    };
    return palette[id] ?? AppColors.primary;
  }
}
