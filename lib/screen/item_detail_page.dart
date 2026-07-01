import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/constants/app_text_styles.dart';
import 'package:shi_wu_ji/constants/app_dimensions.dart';
import 'package:shi_wu_ji/widgets/base_page.dart';
import 'package:shi_wu_ji/widgets/card_container.dart';
import 'package:shi_wu_ji/widgets/countdown_card.dart';
import 'package:shi_wu_ji/widgets/emoji_text.dart';
import 'package:shi_wu_ji/widgets/info_cell.dart';
import 'package:shi_wu_ji/widgets/photo_carousel.dart';
import 'package:shi_wu_ji/models/item.dart';
import 'package:shi_wu_ji/models/template.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';
import 'package:shi_wu_ji/providers/storage_providers.dart';
import 'package:shi_wu_ji/services/notification_service.dart';
import 'package:shi_wu_ji/services/photo_service.dart';

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

    return BasePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopBar(context),
          const SizedBox(height: AppDimensions.spacingLarge),
          _buildImageGallery(item),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          _buildItemHeader(item),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          _buildCountdownSection(context, item),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          _buildInfoSection(context, ref, item),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          _buildTemplateSection(item),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
          _buildBottomActions(context, ref, item),
          const SizedBox(height: AppDimensions.spacingExtraLarge),
        ],
      ),
    );
  }

  // ─── 顶部导航（随内容滚动）──────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
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
            '物品详情',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
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

  /// 底部操作按钮：编辑物品 + 删除物品（并排平齐）
  Widget _buildBottomActions(BuildContext context, WidgetRef ref, Item item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium,
      ),
      child: Row(
        children: [
          // 编辑物品
          Expanded(
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
          ),
          const SizedBox(width: 12),
          // 删除物品
          Expanded(
            child: GestureDetector(
              onTap: () => _confirmDelete(context, ref, item),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColors.cardBg,
                  border: Border.all(color: AppColors.danger, width: 2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '删除物品',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 删除确认弹窗：二次确认后清理通知/照片并从数据库删除，最后返回上一页
  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Item item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除物品'),
        content: Text('确定要删除「${item.name}」吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // 取消已调度的提醒通知（保修 / 保质期）
    await NotificationService().cancelWarrantyReminder(item.id);
    await NotificationService().cancelShelfLifeReminder(item.id);

    // 清理物品照片文件
    for (final photo in item.photos) {
      PhotoService.instance.deleteFile(photo);
    }

    // 从数据库删除
    await ref.read(itemsProvider.notifier).removeItem(item.id);

    if (context.mounted) {
      context.pop();
    }
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

  Widget _buildCountdownSection(BuildContext context, Item item) {
    final cards = <Widget>[];

    // 卡片显示条件以"信息是否设置"为准，与提醒开关解耦：
    // 仅设置了保修/保质期/保养信息即展示对应卡片，提醒开关仅控制通知推送。
    if (item.hasWarranty) {
      cards.add(_buildWarrantyCard(context, item));
    }
    if (item.hasShelfLife) {
      cards.add(_buildShelfLifeCard(context, item));
    }
    if (item.hasMaintenance) {
      cards.add(_buildMaintenanceCard(context, item));
    }

    // 未设置任何到期信息：不渲染该区块
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    // 统一半宽 Wrap：1 卡片靠左、2 卡片并排、3 卡片 2+1 换行
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - AppDimensions.spacingMedium) / 2;
        return Wrap(
          spacing: AppDimensions.spacingMedium,
          runSpacing: AppDimensions.spacingMedium,
          alignment: WrapAlignment.start,
          children: cards
              .map((c) => SizedBox(width: cardWidth, child: c))
              .toList(),
        );
      },
    );
  }

  Widget _buildWarrantyCard(BuildContext context, Item item) {
    final remaining = _daysUntil(item.warrantyEndDate);
    return CountdownCard(
      icon: '🛡️',
      label: '保修',
      value: _formatValue(remaining),
      date: _formatDate(remaining),
      status: _resolveStatus(remaining),
      onTap: () => _showExpiryDetail(
        context,
        title: '保修信息',
        icon: '🛡️',
        endDate: item.warrantyEndDate,
        remainingDays: remaining,
      ),
    );
  }

  Widget _buildShelfLifeCard(BuildContext context, Item item) {
    final remaining = _daysUntil(item.shelfLifeEndDate);
    return CountdownCard(
      icon: '⏳',
      label: '保质期',
      value: _formatValue(remaining),
      date: _formatDate(remaining),
      status: _resolveStatus(remaining),
      onTap: () => _showExpiryDetail(
        context,
        title: '保质信息',
        icon: '⏳',
        endDate: item.shelfLifeEndDate,
        remainingDays: remaining,
      ),
    );
  }

  Widget _buildMaintenanceCard(BuildContext context, Item item) {
    final remaining = item.daysUntilNextMaintenance;
    return CountdownCard(
      icon: '🔧',
      label: '维护保养',
      value: '$remaining',
      date: remaining == 0 ? '今日需保养' : '剩余天数',
      status: _resolveMaintenanceStatus(remaining),
      onTap: () =>
          _showMaintenanceDetail(context, item: item, remainingDays: remaining),
    );
  }

  static CountdownStatus _resolveMaintenanceStatus(int remaining) {
    // 保养周期循环，不存在"过期"概念：今日保养或 7 天内 → expiringSoon
    if (remaining == 0) return CountdownStatus.expiringSoon;
    if (remaining <= 7) return CountdownStatus.expiringSoon;
    return CountdownStatus.normal;
  }

  /// 以日期粒度计算剩余天数（UTC 比较，规避 DST / 时分秒导致的偏移）：
  /// `>0` 剩余天数；`==0` 当天到期；`<0` 已过期，绝对值为过期天数。
  static int _daysUntil(DateTime end) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final endDate = DateTime.utc(end.year, end.month, end.day);
    return endDate.difference(today).inDays;
  }

  static CountdownStatus _resolveStatus(int remaining) {
    if (remaining < 0) return CountdownStatus.expired;
    if (remaining <= 7) return CountdownStatus.expiringSoon;
    return CountdownStatus.normal;
  }

  static String _formatValue(int remaining) =>
      remaining < 0 ? '${-remaining}' : '$remaining';

  static String _formatDate(int remaining) => remaining < 0 ? '已过期天数' : '剩余天数';

  /// 展示到期详情：到期日 / 今日 / 状态文案
  void _showExpiryDetail(
    BuildContext context, {
    required String title,
    required String icon,
    required DateTime endDate,
    required int remainingDays,
  }) {
    final isExpired = remainingDays < 0;
    final isExpiringSoon = !isExpired && remainingDays <= 7;

    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    String statusText;
    Color statusColor;
    if (isExpired) {
      statusText = '已过期 ${-remainingDays} 天';
      statusColor = AppColors.danger;
    } else if (isExpiringSoon) {
      statusText = '即将到期 · 剩余 $remainingDays 天';
      statusColor = AppColors.warning;
    } else {
      statusText = '有效 · 剩余 $remainingDays 天';
      statusColor = AppColors.success;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            EmojiText(emoji: icon, fontSize: 22),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('到期日期：${fmt(endDate)}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text('今日：${fmt(DateTime.now())}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppDimensions.spacingMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusSmall,
                ),
              ),
              child: Text(
                statusText,
                style: AppTextStyles.colored(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
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

  /// 展示保养详情：周期 / 下次保养日 / 状态文案
  void _showMaintenanceDetail(
    BuildContext context, {
    required Item item,
    required int remainingDays,
  }) {
    final isDueToday = remainingDays == 0;
    final isDueSoon = !isDueToday && remainingDays <= 7;

    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    String statusText;
    Color statusColor;
    if (isDueToday) {
      statusText = '今日需保养';
      statusColor = AppColors.warning;
    } else if (isDueSoon) {
      statusText = '即将保养 · 剩余 $remainingDays 天';
      statusColor = AppColors.warning;
    } else {
      statusText = '有效 · 剩余 $remainingDays 天';
      statusColor = AppColors.success;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            EmojiText(emoji: '🔧', fontSize: 22),
            const SizedBox(width: 8),
            Text('保养信息', style: AppTextStyles.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '保养周期：${item.maintenanceCycle}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              '下次保养：${fmt(item.nextMaintenanceDate)}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusSmall,
                ),
              ),
              child: Text(
                statusText,
                style: AppTextStyles.colored(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
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
              InfoCell(label: '来源', value: item.source),
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
