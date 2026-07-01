import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/item.dart';
import '../../widgets/emoji_text.dart';

/// 物品预览模态框 — 展示某个格子/区域内的物品列表，支持批量迁移与批量删除。
/// 数据源为 items 表（主物品），按 slotId 过滤。
class ItemsPreviewModal extends StatelessWidget {
  final String title;
  final List<Item> items;
  final Set<String> selectedItemIds; // 使用 Item.id（UUID 字符串）
  final VoidCallback onClose;
  final ValueChanged<String> onToggleItem;
  final VoidCallback onBatchMigrate;
  final VoidCallback onBatchDelete;

  const ItemsPreviewModal({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItemIds,
    required this.onClose,
    required this.onToggleItem,
    required this.onBatchMigrate,
    required this.onBatchDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 严格限制浮层最高高度为当前屏幕高度的 50%
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheetHeight = screenHeight * 0.5;

    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: GestureDetector(
            onTap: () {}, // 阻止点击穿透
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: BoxConstraints(maxHeight: maxSheetHeight),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头部
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (selectedItemIds.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '已选 ${selectedItemIds.length} 项',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // 物品列表（可滚动，受 maxHeight 约束）
                    Flexible(
                      child: items.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Text(
                                  '该格子暂无物品',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: items.length,
                              itemBuilder: (ctx, i) {
                                final item = items[i];
                                final isSelected = selectedItemIds.contains(
                                  item.id,
                                );
                                return _buildItemListTile(item, isSelected);
                              },
                            ),
                    ),
                    // 批量操作按钮
                    if (selectedItemIds.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // 批量迁移
                          Expanded(
                            child: GestureDetector(
                              onTap: onBatchMigrate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.info, Color(0xFF7AB8FF)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x405B9BFF),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    '批量迁移',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // 批量删除
                          Expanded(
                            child: GestureDetector(
                              onTap: onBatchDelete,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.danger,
                                      Color(0xFFE57373),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x40E57373),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    '批量删除',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemListTile(Item item, bool isSelected) {
    // 副标题：分类 · 品牌（品牌为空时仅显示分类）
    final meta = item.brand.isNotEmpty
        ? '${item.category} · ${item.brand}'
        : item.category;
    return GestureDetector(
      onTap: () => onToggleItem(item.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0E4D0), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: EmojiText(emoji: item.emoji, fontSize: 20)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
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
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentGold : null,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentGold
                      : const Color(0xFFF0E4D0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
