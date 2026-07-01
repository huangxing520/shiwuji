import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/emoji_text.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/toast_utils.dart';
import '../../models/storage.dart';
import '../../providers/item_providers.dart';
import '../../providers/storage_providers.dart';
import 'stats_banner.dart';
import 'add_space_modal.dart';
import 'edit_space_modal.dart';
import 'items_preview_modal.dart';

/// 收纳位置管理页面
class StoragePage extends ConsumerStatefulWidget {
  const StoragePage({super.key});

  @override
  ConsumerState<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends ConsumerState<StoragePage> {
  // 当前层级：0=房间，1=柜体，2=格子
  int _currentLevel = 0;
  String? _currentRoomId;
  String? _currentCabinetId;

  // 面包屑名称
  String _currentRoomName = '';
  String _currentCabinetName = '';

  // 模态框状态
  bool _showAddModal = false;
  bool _showItemsModal = false;
  String _itemsModalTitle = '';
  String _itemsModalSlotId = '';
  final Set<String> _selectedItemIds = {}; // 选中物品的 Item.id（UUID 字符串）

  // 编辑模态框状态
  bool _showEditModal = false;
  _EditTarget? _editTarget;

  // 批量操作进行中
  bool _batchProcessing = false;

  // 删除前置检查进行中
  bool _deleteChecking = false;

  // ========== 导航 ==========
  void _navigateLevel(int level) {
    setState(() {
      if (level == 0) {
        _currentLevel = 0;
        _currentRoomId = null;
        _currentCabinetId = null;
        _currentRoomName = '';
        _currentCabinetName = '';
      } else if (level == 1) {
        _currentLevel = 1;
        _currentCabinetId = null;
        _currentCabinetName = '';
      }
    });
  }

  void _enterRoom(String roomId, String roomName) {
    setState(() {
      _currentLevel = 1;
      _currentRoomId = roomId;
      _currentRoomName = roomName;
      _currentCabinetId = null;
      _currentCabinetName = '';
    });
  }

  void _enterCabinet(String cabinetId, String cabinetName) {
    setState(() {
      _currentLevel = 2;
      _currentCabinetId = cabinetId;
      _currentCabinetName = cabinetName;
    });
  }

  // ========== 模态框 ==========
  void _openAddModal() {
    setState(() {
      _showAddModal = true;
    });
  }

  void _closeAddModal() {
    setState(() {
      _showAddModal = false;
    });
  }

  void _onAddConfirm({
    required String level,
    required String parentId,
    required String name,
    required String icon,
    int expectedItems = 1,
    String? photoPath,
  }) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final id = '${level}_$ts';
    const color = AppColors.primary;

    switch (level) {
      case 'room':
        ref
            .read(roomActionsProvider.notifier)
            .addRoom(id: id, name: name, emoji: icon, color: color);
        // 自动创建默认柜体
        final cabinetId = 'cabinet_${ts}_default';
        ref
            .read(cabinetActionsProvider.notifier)
            .addCabinet(
              id: cabinetId,
              name: '默认柜体',
              emoji: '🗄️',
              color: color,
              roomId: id,
            );
        // 自动创建默认格子区域
        final slotId = 'slot_${ts}_default';
        ref
            .read(slotActionsProvider.notifier)
            .addSlot(
              id: slotId,
              name: '默认区域',
              emoji: '📦',
              color: color,
              cabinetId: cabinetId,
            );
        break;
      case 'cabinet':
        if (parentId.isNotEmpty) {
          ref
              .read(cabinetActionsProvider.notifier)
              .addCabinet(
                id: id,
                name: name,
                emoji: icon,
                color: color,
                roomId: parentId,
                photoPath: photoPath,
              );
          // 自动创建默认格子区域
          final slotId = 'slot_${ts}_default';
          ref
              .read(slotActionsProvider.notifier)
              .addSlot(
                id: slotId,
                name: '默认区域',
                emoji: '📦',
                color: color,
                cabinetId: id,
              );
        }
        break;
      case 'slot':
        if (parentId.isNotEmpty) {
          ref
              .read(slotActionsProvider.notifier)
              .addSlot(
                id: id,
                name: name,
                emoji: icon,
                color: color,
                cabinetId: parentId,
                expectedItems: expectedItems,
              );
        }
        break;
    }

    ToastUtils.show(context, '「$name」已添加');
    _closeAddModal();
  }

  void _openItemsModal(String title, String slotId) {
    setState(() {
      _showItemsModal = true;
      _itemsModalTitle = title;
      _itemsModalSlotId = slotId;
      _selectedItemIds.clear();
    });
  }

  void _closeItemsModal() {
    setState(() {
      _showItemsModal = false;
    });
  }

  /// 长按房间 → 显示编辑/删除选项
  void _showRoomActionSheet(Room room) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: Color(0xFFE5A500),
              ),
              title: const Text('编辑房间'),
              onTap: () {
                Navigator.pop(ctx);
                _openEditModal(
                  _EditTarget(
                    kind: _EditKind.room,
                    id: room.id,
                    name: room.name,
                    emoji: room.emoji,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.danger,
              ),
              title: const Text('删除房间'),
              subtitle: Text(
                '将一并删除其下所有柜体与格子（含物品时不可删除）',
                style: TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteRoom(room);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 长按柜体 → 显示编辑/删除选项
  void _showCabinetActionSheet(Cabinet cabinet) {
    final roomId = _currentRoomId;
    if (roomId == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: Color(0xFFE5A500),
              ),
              title: const Text('编辑柜体'),
              onTap: () {
                Navigator.pop(ctx);
                _openEditModal(
                  _EditTarget(
                    kind: _EditKind.cabinet,
                    id: cabinet.id,
                    parentId: roomId,
                    name: cabinet.name,
                    emoji: cabinet.emoji,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.danger,
              ),
              title: const Text('删除柜体'),
              subtitle: Text(
                '将一并删除其下所有格子（含物品时不可删除）',
                style: TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteCabinet(cabinet, roomId);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 长按格子 → 显示编辑/删除选项
  void _showSlotActionSheet(Slot slot) {
    final cabinetId = _currentCabinetId;
    if (cabinetId == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: Color(0xFFE5A500),
              ),
              title: const Text('编辑格子'),
              onTap: () {
                Navigator.pop(ctx);
                _openEditModal(
                  _EditTarget(
                    kind: _EditKind.slot,
                    id: slot.id,
                    parentId: cabinetId,
                    name: slot.name,
                    emoji: slot.emoji,
                    expectedItems: slot.expectedItems,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.danger,
              ),
              title: const Text('删除格子'),
              subtitle: Text(
                '含物品时不可删除，请先迁移格子内物品',
                style: TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteSlot(slot, cabinetId);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ========== 编辑模态框 ==========
  void _openEditModal(_EditTarget target) {
    setState(() {
      _editTarget = target;
      _showEditModal = true;
    });
  }

  void _closeEditModal() {
    setState(() {
      _showEditModal = false;
      _editTarget = null;
    });
  }

  void _onEditConfirm({
    required String name,
    required String icon,
    int? expectedItems,
  }) {
    final t = _editTarget;
    if (t == null) return;
    switch (t.kind) {
      case _EditKind.room:
        ref
            .read(roomActionsProvider.notifier)
            .updateRoom(id: t.id, name: name, emoji: icon);
        break;
      case _EditKind.cabinet:
        ref
            .read(cabinetActionsProvider.notifier)
            .updateCabinet(
              id: t.id,
              roomId: t.parentId!,
              name: name,
              emoji: icon,
            );
        break;
      case _EditKind.slot:
        ref
            .read(slotActionsProvider.notifier)
            .updateSlot(
              id: t.id,
              cabinetId: t.parentId!,
              name: name,
              emoji: icon,
              expectedItems: expectedItems,
            );
        break;
    }
    ToastUtils.show(context, '「$name」已更新');
    _closeEditModal();
  }

  // ========== 删除确认 ==========
  Future<void> _confirmDeleteRoom(Room room) async {
    setState(() => _deleteChecking = true);
    DeletionBlocker? blocker;
    try {
      blocker = await ref
          .read(roomActionsProvider.notifier)
          .checkRoomDeletion(room.id);
    } finally {
      if (mounted) setState(() => _deleteChecking = false);
    }
    if (!mounted) return;
    if (blocker != null) {
      _showDeleteBlockedDialog(blocker);
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除房间'),
        content: Text('确定删除「${room.name}」？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(roomActionsProvider.notifier).deleteRoom(room.id);
              ToastUtils.show(context, '「${room.name}」已删除');
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteCabinet(Cabinet cabinet, String roomId) async {
    setState(() => _deleteChecking = true);
    DeletionBlocker? blocker;
    try {
      blocker = await ref
          .read(cabinetActionsProvider.notifier)
          .checkCabinetDeletion(cabinet.id);
    } finally {
      if (mounted) setState(() => _deleteChecking = false);
    }
    if (!mounted) return;
    if (blocker != null) {
      _showDeleteBlockedDialog(blocker);
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除柜体'),
        content: Text('确定删除「${cabinet.name}」？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(cabinetActionsProvider.notifier)
                  .deleteCabinet(cabinet.id, roomId);
              ToastUtils.show(context, '「${cabinet.name}」已删除');
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteSlot(Slot slot, String cabinetId) async {
    setState(() => _deleteChecking = true);
    DeletionBlocker? blocker;
    try {
      blocker = await ref
          .read(slotActionsProvider.notifier)
          .checkSlotDeletion(slot.id);
    } finally {
      if (mounted) setState(() => _deleteChecking = false);
    }
    if (!mounted) return;
    if (blocker != null) {
      _showDeleteBlockedDialog(blocker);
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除格子'),
        content: Text('确定删除「${slot.name}」？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(slotActionsProvider.notifier)
                  .deleteSlot(slot.id, cabinetId);
              ToastUtils.show(context, '「${slot.name}」已删除');
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 删除被阻止时的提示对话框：指明具体子单元路径与物品数
  void _showDeleteBlockedDialog(DeletionBlocker blocker) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('无法删除'),
        content: Text(
          '「${blocker.path}」中存在 ${blocker.count} 件物品，请先将物品迁移至其他收纳位置后再删除。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  // ========== 批量迁移 ==========
  Future<void> _batchMigrate() async {
    if (_selectedItemIds.isEmpty) return;
    final fromSlotId = _itemsModalSlotId;
    if (fromSlotId.isEmpty) return;

    // 弹出目标格子选择器
    final target = await showModalBottomSheet<StorageLocationNode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildMoveTargetPicker(ctx),
    );
    if (!mounted) return;
    if (target == null) return;
    if (!target.isSlot) {
      ToastUtils.show(context, '请选择目标格子（不可直接选柜体）');
      return;
    }
    if (target.id == fromSlotId) {
      ToastUtils.show(context, '目标格子与源格子相同');
      return;
    }

    setState(() => _batchProcessing = true);
    try {
      await ref
          .read(itemsProvider.notifier)
          .migrateItems(
            _selectedItemIds.toList(),
            cabinetId: target.cabinetId,
            slotId: target.id,
            locationLabel: target.pathLabel,
          );
      if (mounted) {
        ToastUtils.show(
          context,
          '已迁移 ${_selectedItemIds.length} 件物品到「${target.name}」',
        );
      }
    } catch (e) {
      if (mounted) ToastUtils.show(context, '迁移失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _batchProcessing = false;
          _selectedItemIds.clear();
        });
        _closeItemsModal();
      }
    }
  }

  Widget _buildMoveTargetPicker(BuildContext ctx) {
    return Consumer(
      builder: (ctx, ref, _) {
        final treeAsync = ref.watch(storageLocationTreeProvider);
        final screenHeight = MediaQuery.sizeOf(ctx).height;
        return treeAsync.when(
          loading: () => Container(
            height: screenHeight * 0.5,
            color: Colors.white,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          ),
          error: (e, _) => Container(
            height: screenHeight * 0.5,
            color: Colors.white,
            alignment: Alignment.center,
            child: Text('加载失败: $e'),
          ),
          data: (nodes) {
            final slots = nodes.where((n) => n.isSlot).toList();
            return Container(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.5),
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '选择目标格子',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  Flexible(
                    child: slots.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Text(
                                '暂无可选格子',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: slots.length,
                            itemBuilder: (ctx, i) {
                              final node = slots[i];
                              final isCurrent = node.id == _itemsModalSlotId;
                              return ListTile(
                                leading: EmojiText(
                                  emoji: node.emoji,
                                  fontSize: 22,
                                ),
                                title: Text(node.name),
                                subtitle: Text(
                                  node.pathLabel,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textHint,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: isCurrent
                                    ? const Text(
                                        '当前',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textHint,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.chevron_right,
                                        color: AppColors.textHint,
                                      ),
                                onTap: isCurrent
                                    ? null
                                    : () => Navigator.pop(ctx, node),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ========== 批量删除 ==========
  Future<void> _batchDelete() async {
    if (_selectedItemIds.isEmpty) return;
    if (_itemsModalSlotId.isEmpty) return;

    // 确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('批量删除'),
        content: Text('确定删除选中的 ${_selectedItemIds.length} 件物品？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _batchProcessing = true);
    try {
      await ref
          .read(itemsProvider.notifier)
          .removeItems(_selectedItemIds.toList());
      if (mounted) {
        ToastUtils.show(context, '已删除 ${_selectedItemIds.length} 件物品');
      }
    } catch (e) {
      if (mounted) ToastUtils.show(context, '删除失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _batchProcessing = false;
          _selectedItemIds.clear();
        });
        _closeItemsModal();
      }
    }
  }

  // ========== 构建UI ==========
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
                  _buildTopBar(),
                  // _buildBreadcrumb(),
                  _buildLevelTabs(),
                  Expanded(child: _buildScrollArea()),
                ],
              ),
            ),

            if (_showAddModal)
              AddSpaceModal(
                onClose: _closeAddModal,
                onConfirm: _onAddConfirm,
                currentLevel: _currentLevel,
                currentRoomId: _currentRoomId,
                currentCabinetId: _currentCabinetId,
              ),
            if (_showEditModal && _editTarget != null)
              EditSpaceModal(
                title: _editTarget!.title,
                initialName: _editTarget!.name,
                initialIcon: _editTarget!.emoji,
                iconOptions: _editTarget!.iconOptions,
                onClose: _closeEditModal,
                onConfirm: _onEditConfirm,
                showExpectedItems: _editTarget!.kind == _EditKind.slot,
                initialExpectedItems: _editTarget!.expectedItems,
              ),
            if (_showItemsModal) _buildItemsModalFromProvider(),
            if (_batchProcessing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            if (_deleteChecking)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: const Center(child: CircularProgressIndicator()),
                ),
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
            top: 80,
            right: -40,
            width: 150,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 350,
            left: -25,
            width: 90,
            height: 90,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gradientBlue.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            right: -20,
            width: 110,
            height: 110,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 物品模态框 — 从 itemsProvider 读取该格位下的物品（主物品，按 slotId 过滤）
  Widget _buildItemsModalFromProvider() {
    if (_itemsModalSlotId.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemsAsync = ref.watch(itemsProvider);

    return itemsAsync.when(
      loading: () => Positioned.fill(
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Positioned.fill(
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: Center(
            child: Text(
              '加载失败: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      data: (allItems) {
        final items = allItems
            .where((i) => i.slotId == _itemsModalSlotId)
            .toList();
        return ItemsPreviewModal(
          title: _itemsModalTitle,
          items: items,
          selectedItemIds: _selectedItemIds,
          onClose: _closeItemsModal,
          onToggleItem: _toggleItemSelection,
          onBatchMigrate: _batchMigrate,
          onBatchDelete: _batchDelete,
        );
      },
    );
  }

  // ========== 顶部栏 ==========
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
      child: Row(
        children: [
          const Text(
            '收纳位置',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
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

  // ========== 面包屑导航 ==========
  Widget _buildBreadcrumb() {
    if (_currentLevel == 0) return const SizedBox.shrink();

    final crumbs = <_BreadcrumbItem>[
      _BreadcrumbItem('我的家', () => _navigateLevel(0)),
    ];

    if (_currentLevel >= 1 && _currentRoomName.isNotEmpty) {
      crumbs.add(
        _BreadcrumbItem(
          _currentRoomName,
          _currentLevel > 1 ? () => _navigateLevel(1) : null,
        ),
      );
    }

    if (_currentLevel >= 2 && _currentCabinetName.isNotEmpty) {
      crumbs.add(_BreadcrumbItem(_currentCabinetName, null));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < crumbs.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                ),
              GestureDetector(
                onTap: crumbs[i].onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: crumbs[i].onTap != null
                        ? AppColors.cardBg
                        : AppColors.accentGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    crumbs[i].label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: crumbs[i].onTap != null
                          ? AppColors.textSecondary
                          : AppColors.accentGold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ========== 层级标签 ==========
  Widget _buildLevelTabs() {
    final statsAsync = ref.watch(storageStatsProvider);
    final roomsAsync = ref.watch(roomsProvider);

    // 房间数：始终为全局房间总数
    final roomCount = roomsAsync.whenOrNull(data: (rooms) => rooms.length) ?? 0;

    // 柜体数：进入房间（level 1/2）时显示当前房间的柜体数，
    // 否则显示全局柜体总数
    int cabinetCount;
    if (_currentRoomId != null) {
      cabinetCount =
          ref
              .watch(cabinetsByRoomProvider(_currentRoomId!))
              .whenOrNull(data: (cabinets) => cabinets.length) ??
          0;
    } else {
      cabinetCount =
          statsAsync.whenOrNull(data: (s) => s['cabinets'] ?? 0) ?? 0;
    }

    // 物品数：进入柜体（level 2）时显示当前柜体下所有格子的物品总数，
    // 进入房间（level 1）时显示该房间所有柜体的物品总数，
    // 否则显示全局物品总数
    int itemCount;
    if (_currentCabinetId != null) {
      itemCount =
          ref
              .watch(slotsByCabinetProvider(_currentCabinetId!))
              .whenOrNull(
                data: (slots) => slots.fold<int>(0, (sum, s) => sum + s.items),
              ) ??
          0;
    } else if (_currentRoomId != null) {
      itemCount =
          ref
              .watch(cabinetsByRoomProvider(_currentRoomId!))
              .whenOrNull(
                data: (cabinets) =>
                    cabinets.fold<int>(0, (sum, c) => sum + c.items),
              ) ??
          0;
    } else {
      itemCount = statsAsync.whenOrNull(data: (s) => s['items'] ?? 0) ?? 0;
    }

    final levels = [('房间', roomCount), ('柜体', cabinetCount), ('物品', itemCount)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: levels.asMap().entries.map((entry) {
          final i = entry.key;
          final (label, count) = entry.value;
          final isActive = i == _currentLevel;
          // 越级标签禁用：只能点击 ≤ 当前层级的标签
          final isDisabled = i > _currentLevel;
          return Padding(
            padding: EdgeInsets.only(right: i < levels.length - 1 ? 6 : 0),
            child: GestureDetector(
              onTap: isDisabled ? null : () => _navigateLevel(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [AppColors.accentGold, AppColors.warning],
                        )
                      : null,
                  color: isActive
                      ? null
                      : (isDisabled ? const Color(0xFFF5F0E8) : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isActive
                        ? Colors.transparent
                        : (isDisabled
                              ? const Color(0xFFEDE4D4)
                              : const Color(0xFFF0E4D0)),
                    width: 1.5,
                  ),
                  boxShadow: isDisabled
                      ? []
                      : [
                          BoxShadow(
                            color: isActive
                                ? const Color(0x4DFFB800)
                                : AppColors.textPrimary.withValues(alpha: 0.06),
                            blurRadius: isActive ? 14 : 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? Colors.white
                            : (isDisabled
                                  ? AppColors.textHint
                                  : AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.3)
                            : (isDisabled
                                  ? Colors.black.withValues(alpha: 0.04)
                                  : Colors.black.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? Colors.white
                              : (isDisabled
                                    ? AppColors.textHint
                                    : AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ========== 滚动区域 ==========
  Widget _buildScrollArea() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      child: Column(
        children: [
          _buildStatsBannerFromProvider(),
          const SizedBox(height: 16),
          _buildContent(),
        ],
      ),
    );
  }

  // ========== 统计横幅（使用 provider） ==========
  Widget _buildStatsBannerFromProvider() {
    final statsAsync = ref.watch(storageStatsProvider);

    return statsAsync.when(
      loading: () =>
          const StorageStatsBanner(roomCount: 0, cabinetCount: 0, itemCount: 0),
      error: (e, _) =>
          StorageStatsBanner(roomCount: 0, cabinetCount: 0, itemCount: 0),
      data: (stats) => StorageStatsBanner(
        roomCount: stats['rooms'] ?? 0,
        cabinetCount: stats['cabinets'] ?? 0,
        itemCount: stats['items'] ?? 0,
      ),
    );
  }

  // ========== 内容区域 ==========
  Widget _buildContent() {
    if (_currentLevel == 0) {
      return _buildRoomsList();
    } else if (_currentLevel == 1) {
      if (_currentRoomId != null) {
        return _buildCabinetsListFromProvider(_currentRoomId!);
      } else {
        // 未选择房间时，显示所有房间的柜体概览（提示选择房间）
        return _buildRoomsList();
      }
    } else if (_currentLevel == 2) {
      if (_currentCabinetId != null) {
        return _buildSlotsListFromProvider(_currentCabinetId!);
      }
    }
    return const SizedBox.shrink();
  }

  // ========== 房间列表 ==========
  Widget _buildRoomsList() {
    final roomsAsync = ref.watch(roomsProvider);

    return roomsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text('加载失败: $e')),
      ),
      data: (rooms) {
        if (rooms.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                '暂无房间，点击右上角 + 添加',
                style: TextStyle(color: AppColors.textHint, fontSize: 14),
              ),
            ),
          );
        }
        return Column(
          children: rooms.asMap().entries.map((entry) {
            final i = entry.key;
            final room = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RoomCardLarge(
                room: room,
                delay: i * 0.08,
                onTap: () => _enterRoom(room.id, room.name),
                onLongPress: () => _showRoomActionSheet(room),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ========== 柜体列表（从 provider） ==========
  Widget _buildCabinetsListFromProvider(String roomId) {
    final cabinetsAsync = ref.watch(cabinetsByRoomProvider(roomId));

    return cabinetsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text('加载失败: $e')),
      ),
      data: (cabinets) {
        if (cabinets.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                '该房间暂无柜体，点击右上角 + 添加',
                style: TextStyle(color: AppColors.textHint, fontSize: 14),
              ),
            ),
          );
        }
        return Column(
          children: cabinets.asMap().entries.map((entry) {
            final i = entry.key;
            final cabinet = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SpaceCard(
                cabinet: cabinet,
                slotCount: 0, // slot count is fetched separately
                delay: i * 0.08,
                onTap: () => _enterCabinet(cabinet.id, cabinet.name),
                onLongPress: () => _showCabinetActionSheet(cabinet),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ========== 格子列表（从 provider） ==========
  Widget _buildSlotsListFromProvider(String cabinetId) {
    final slotsAsync = ref.watch(slotsByCabinetProvider(cabinetId));

    return slotsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text('加载失败: $e')),
      ),
      data: (slots) {
        if (slots.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                '该柜体暂无格子/区域',
                style: TextStyle(color: AppColors.textHint, fontSize: 14),
              ),
            ),
          );
        }
        return Column(
          children: slots.asMap().entries.map((entry) {
            final i = entry.key;
            final slot = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SpaceCard(
                slot: slot,
                delay: i * 0.08,
                onTap: () => _openItemsModal(slot.name, slot.id),
                onLongPress: () => _showSlotActionSheet(slot),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ========== 房间大卡片 ==========
class _RoomCardLarge extends StatelessWidget {
  final Room room;
  final double delay;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _RoomCardLarge({
    required this.room,
    required this.delay,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: const Cubic(0.34, 1.4, 0.64, 1),
        builder: (context, value, child) {
          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 14 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14FFB800),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 视觉区域
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: room.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(child: EmojiText(emoji: room.emoji, fontSize: 48)),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0x66000000)],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              room.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${room.items}件物品',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xD9FFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 统计区域
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildStat(room.storageCount, '柜体'),
                    _buildStat(room.items, '物品'),
                    _buildOccupancyStat(room.occupation),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(int num, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$num',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
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
        ),
      ),
    );
  }

  Widget _buildOccupancyStat(int occupation) {
    Color color;
    if (occupation > 80) {
      color = AppColors.danger;
    } else if (occupation > 50) {
      color = AppColors.warning;
    } else {
      color = AppColors.success;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$occupation%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              '占用率',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== 空间卡片 ==========
class _SpaceCard extends StatelessWidget {
  final Cabinet? cabinet;
  final Slot? slot;
  final int slotCount;
  final List<SpaceItem> items;
  final double delay;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _SpaceCard({
    this.cabinet,
    this.slot,
    this.slotCount = 0,
    this.items = const [],
    required this.delay,
    required this.onTap,
    this.onLongPress,
  });

  String get name => cabinet?.name ?? slot?.name ?? '';
  String get emoji => cabinet?.emoji ?? slot?.emoji ?? '';
  Color get color => cabinet?.color ?? slot?.color ?? AppColors.background;
  int get itemCount => cabinet?.items ?? slot?.items ?? 0;
  int get occupation => cabinet?.occupation ?? slot?.occupation ?? 0;
  bool get hasPhoto => cabinet?.hasPhoto ?? false;
  int get expectedItems => cabinet?.expectedItems ?? slot?.expectedItems ?? 0;
  bool get isCabinet => cabinet != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: const Cubic(0.34, 1.4, 0.64, 1),
        builder: (context, value, child) {
          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 14 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14FFB800),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 头部
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 视觉图标
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                        if (hasPhoto)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.accentGold,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.photo_camera,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // 信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (slotCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4F5D9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$slotCount格',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF3A9E4A),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            cabinet != null
                                ? '$itemCount件物品 · ${hasPhoto ? '已拍实景图' : '暂无实景图'}'
                                : '$itemCount件物品',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                          if (cabinet != null || slot != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildMetricBadge(
                                  '预期 $expectedItems',
                                  color: const Color(0xFFE5A500),
                                  bgColor: const Color(0xFFFFF4D6),
                                ),
                                const SizedBox(width: 6),
                                _buildMetricBadge(
                                  '占用率 $occupation%',
                                  color: occupation > 100
                                      ? AppColors.danger
                                      : (occupation > 80
                                            ? AppColors.danger
                                            : (occupation > 50
                                                  ? const Color(0xFFE5A500)
                                                  : const Color(0xFF3A9E4A))),
                                  bgColor: occupation > 100
                                      ? const Color(0xFFFFE0E0)
                                      : (occupation > 80
                                            ? const Color(0xFFFFE0E0)
                                            : (occupation > 50
                                                  ? const Color(0xFFFFF4D6)
                                                  : const Color(0xFFD4F5D9))),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // 长按提示图标
                    const Icon(
                      Icons.more_vert,
                      size: 18,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ),

              // 物品预览
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...items
                          .take(4)
                          .map(
                            (item) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  EmojiText(emoji: item.emoji, fontSize: 13),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      if (items.length > 4)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '+${items.length - 4}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
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
  }

  Widget _buildMetricBadge(
    String label, {
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ========== 面包屑数据类 ==========
class _BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const _BreadcrumbItem(this.label, this.onTap);
}

// ========== 编辑目标数据类 ==========
enum _EditKind { room, cabinet, slot }

class _EditTarget {
  final _EditKind kind;
  final String id;
  final String? parentId; // cabinet: roomId; slot: cabinetId
  final String name;
  final String emoji;
  final int? expectedItems;

  const _EditTarget({
    required this.kind,
    required this.id,
    this.parentId,
    required this.name,
    required this.emoji,
    this.expectedItems,
  });

  String get title {
    switch (kind) {
      case _EditKind.room:
        return '编辑房间';
      case _EditKind.cabinet:
        return '编辑柜体';
      case _EditKind.slot:
        return '编辑格子';
    }
  }

  List<String> get iconOptions {
    switch (kind) {
      case _EditKind.room:
        return const [
          '🛋️',
          '🛏️',
          '📚',
          '🍳',
          '🗄️',
          '📺',
          '👔',
          '💄',
          '💡',
          '📦',
          '🖥️',
          '🔌',
          '🔧',
          '🧹',
          '🚪',
          '🧒',
          '🌱',
          '🚗',
        ];
      case _EditKind.cabinet:
        return const [
          '📦',
          '🗄️',
          '🚪',
          '📺',
          '🧱',
          '📚',
          '🪑',
          '🛁',
          '🪴',
          '🧸',
          '🍳',
          '💡',
          '🖼️',
          '🧺',
        ];
      case _EditKind.slot:
        return const [
          '📦',
          '📚',
          '👗',
          '👔',
          '💄',
          '💊',
          '🧴',
          '🔧',
          '🔌',
          '🔋',
          '🎧',
          '📷',
          '🎮',
          '🔑',
          '📝',
          '🧹',
        ];
    }
  }
}
