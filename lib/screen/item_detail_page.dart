import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/constants/app_text_styles.dart';
import 'package:shi_wu_ji/constants/app_dimensions.dart';
import 'package:shi_wu_ji/widgets/base_page.dart';
import 'package:shi_wu_ji/widgets/custom_app_bar.dart';
import 'package:shi_wu_ji/widgets/card_container.dart';
import 'package:shi_wu_ji/widgets/countdown_card.dart';
import 'package:shi_wu_ji/widgets/emoji_text.dart';
import 'package:shi_wu_ji/widgets/info_cell.dart';
import 'package:shi_wu_ji/widgets/photo_carousel.dart';
import 'package:shi_wu_ji/models/item.dart';
import 'package:shi_wu_ji/models/template.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';
import 'package:shi_wu_ji/providers/storage_providers.dart';

class ItemDetailPage extends ConsumerWidget {
  final String itemId;

  const ItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the items provider to ensure data is loaded
    final itemsState = ref.watch(itemsProvider);
    if (itemsState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final item = ref.watch(itemByIdProvider(itemId));

    if (item == null) {
      return Scaffold(body: Center(child: Text('未找到物品')));
    }

    final warrantyDays = item.daysUntilWarrantyExpiry;
    final warrantyText = item.isWarrantyExpired ? '已过期' : '$warrantyDays';
    final warrantyDateText = item.isWarrantyExpired ? '天前' : '剩余天数';

    return BasePage(
      appBar: CustomAppBar(title: '物品详情'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimensions.spacingLarge),
          _buildImageGallery(item),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          _buildItemHeader(item),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          _buildCountdownSection(item, warrantyText, warrantyDateText),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          _buildInfoSection(context, ref, item),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          _buildTemplateSection(item),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          _buildBottomEditButton(context, item),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
        ],
      ),
    );
  }

  Widget _buildImageGallery(Item item) {
    // 无照片：显示物品 emoji 作为占位
    if (item.photos.isEmpty) {
      return CardContainer(
        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadiusMedium,
            ),
          ),
          child: Center(child: EmojiText(emoji: item.emoji, fontSize: 96)),
        ),
      );
    }
    // 有照片：轮播组件
    return PhotoCarousel(photos: item.photos);
  }

  /// 底部编辑按钮（与顶部图标互补，提供更明显的入口）
  Widget _buildBottomEditButton(BuildContext context, Item item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium,
      ),
      child: GestureDetector(
        onTap: () => context.push('/edit_item/${item.id}'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.cardBg,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit, size: 18, color: AppColors.primaryDark),
              SizedBox(width: 8),
              Text(
                '编辑物品',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemHeader(Item item) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: AppTextStyles.titleLarge),
          if (item.brand.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSmall),
            Text('品牌: ${item.brand}', style: AppTextStyles.subtitleText),
          ],
          const SizedBox(height: AppDimensions.spacingSmall),
          Text('分类: ${item.category}', style: AppTextStyles.subtitleText),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text('位置: ${item.location}', style: AppTextStyles.subtitleText),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            '¥${item.price.toStringAsFixed(0)}',
            style: AppTextStyles.priceText,
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownSection(
    Item item,
    String warrantyText,
    String warrantyDateText,
  ) {
    return Row(
      children: [
        CountdownCard(
          icon: '🛡️',
          label: '质保',
          value: warrantyText,
          date: warrantyDateText,
          isWarning: item.isWarrantyExpiringSoon || item.isWarrantyExpired,
        ),
        const SizedBox(width: AppDimensions.spacingMedium),
        CountdownCard(
          icon: '🔧',
          label: '维护',
          value: '30',
          date: '剩余天数',
          isWarning: true,
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, WidgetRef ref, Item item) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('详情', style: AppTextStyles.titleSmall),
          const SizedBox(height: AppDimensions.spacingMedium),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimensions.spacingMedium,
            crossAxisSpacing: AppDimensions.spacingLarge,
            childAspectRatio: 2.5,
            children: [
              InfoCell(label: '分类', value: item.category),
              _LocationCell(
                label: '收纳位置',
                value: item.location,
                onTap: () => _changeLocation(context, ref, item),
              ),
              InfoCell(
                label: '购买日期',
                value:
                    '${item.purchaseDate.year}-${item.purchaseDate.month.toString().padLeft(2, '0')}-${item.purchaseDate.day.toString().padLeft(2, '0')}',
              ),
              InfoCell(
                label: '价格',
                value: '¥${item.price.toStringAsFixed(0)}',
                isAccent: true,
              ),
            ],
          ),
          if (item.note.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMedium),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text('备注', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              item.note,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 模板专属属性展示：仅展示非通用分类（templateKey != 'none'）的模板字段
  /// 过滤通用分类相关内容，自动排除未填写值的字段，保持与详情区块统一的展示风格
  Widget _buildTemplateSection(Item item) {
    // 过滤通用分类：通用模版不展示模板信息
    if (item.templateKey == 'none') {
      return const SizedBox.shrink();
    }

    final templateData = templateFieldsMap[item.templateKey];
    if (templateData == null) {
      return const SizedBox.shrink();
    }

    // 仅展示已填写值的字段
    final filledFields = templateData.fields
        .where((f) => (item.templateData[f.id] ?? '').trim().isNotEmpty)
        .toList();
    if (filledFields.isEmpty) {
      return const SizedBox.shrink();
    }

    // 模板名称去掉「专属属性」后缀作为区块标题
    final sectionTitle = templateData.name.replaceAll('专属属性', '信息');

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sectionTitle, style: AppTextStyles.titleSmall),
          const SizedBox(height: AppDimensions.spacingMedium),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimensions.spacingMedium,
            crossAxisSpacing: AppDimensions.spacingLarge,
            childAspectRatio: 2.5,
            children: filledFields
                .map(
                  (f) => InfoCell(
                    label: f.label,
                    value: item.templateData[f.id] ?? '',
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  /// 修改物品收纳位置（联动柜体/格子）
  void _changeLocation(BuildContext context, WidgetRef ref, Item item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final asyncNodes = ref.watch(storageLocationTreeProvider);
            final allNodes = asyncNodes.value ?? const [];
            final nodes = allNodes.where((n) => n.isSlot).toList();
            // 当前选中的节点
            StorageLocationNode? current;
            if (item.slotId != null) {
              current = nodes
                  .where((n) => n.id == item.slotId)
                  .cast<StorageLocationNode?>()
                  .firstWhere((_) => true, orElse: () => null);
            }
            return _DetailLocationSheet(
              nodes: nodes,
              isLoading: asyncNodes.isLoading,
              selectedNode: current,
              onPick: (node) async {
                await ref
                    .read(itemsProvider.notifier)
                    .updateLocation(
                      id: item.id,
                      cabinetId: node.cabinetId,
                      slotId: node.isSlot ? node.id : null,
                      locationLabel: node.pathLabel,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已更新收纳位置：${node.pathLabel}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              onClear: () async {
                await ref
                    .read(itemsProvider.notifier)
                    .updateLocation(
                      id: item.id,
                      cabinetId: null,
                      slotId: null,
                      locationLabel: '未指定',
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              },
            );
          },
        );
      },
    );
  }
}

/// 详情页的位置单元格（可点击）
class _LocationCell extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _LocationCell({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppTextStyles.labelMedium),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 11, color: AppColors.accentGold),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.infoValue(isAccent: true),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 详情页用的位置选择弹窗
class _DetailLocationSheet extends StatelessWidget {
  final List<StorageLocationNode> nodes;
  final bool isLoading;
  final StorageLocationNode? selectedNode;
  final ValueChanged<StorageLocationNode> onPick;
  final VoidCallback onClear;

  const _DetailLocationSheet({
    required this.nodes,
    required this.isLoading,
    required this.selectedNode,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheetHeight = screenHeight * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '修改收纳位置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.refresh,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: '清除位置',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Flexible(
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: AppColors.accentGold,
                      ),
                    ),
                  )
                : nodes.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        '暂无可用格子区域\n请先在收纳页面添加柜体和格子',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: nodes.length,
                    itemBuilder: (ctx, i) {
                      final node = nodes[i];
                      final isSelected = selectedNode?.id == node.id;
                      return InkWell(
                        onTap: () => onPick(node),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFF8E7)
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentGold
                                  : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: node.isSlot
                                      ? const Color(0xFFE8F0FE)
                                      : const Color(0xFFFFF3CC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: EmojiText(
                                    emoji: node.emoji,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      node.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      node.pathLabel,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textHint,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.accentGold,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
