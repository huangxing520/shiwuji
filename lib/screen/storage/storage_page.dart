import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/toast_utils.dart';
import '../../models/storage.dart';
import '../../models/item.dart';
import '../../providers/storage_providers.dart';
import '../../providers/item_providers.dart';
import 'stats_banner.dart';
import 'add_space_modal.dart';
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
  final Set<String> _selectedItemIds = {};

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
  }) {
    final id = '${level}_${DateTime.now().millisecondsSinceEpoch}';
    const color = AppColors.primary;

    switch (level) {
      case 'room':
        ref
            .read(roomActionsProvider.notifier)
            .addRoom(id: id, name: name, emoji: icon, color: color);
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

  /// 长按格子 → 选择物品迁移到此格子（联动 Item.cabinetId/slotId）
  void _openSlotMovePicker(BuildContext context, Slot slot) {
    final cabinetId = _currentCabinetId;
    final cabinetName = _currentCabinetName;
    final roomName = _currentRoomName;
    if (cabinetId == null) {
      ToastUtils.show(context, '缺少柜体上下文，无法迁移');
      return;
    }
    final pathLabel = '$roomName / $cabinetName / ${slot.name}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final itemsAsync = ref.watch(itemsProvider);
            final items = itemsAsync.value ?? const <Item>[];
            return _SlotMoveSheet(
              slot: slot,
              pathLabel: pathLabel,
              items: items,
              onAssign: (item) async {
                await ref
                    .read(itemsProvider.notifier)
                    .updateLocation(
                      id: item.id,
                      cabinetId: cabinetId,
                      slotId: slot.id,
                      locationLabel: pathLabel,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                ToastUtils.show(context, '「${item.name}」已收纳到 ${slot.name}');
              },
            );
          },
        );
      },
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

  void _batchMigrate() {
    ToastUtils.show(context, '已迁移${_selectedItemIds.length}件物品');
    _closeItemsModal();
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
            if (_showItemsModal) _buildItemsModalFromProvider(),
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

  /// 物品模态框 — 从 provider 读取数据
  Widget _buildItemsModalFromProvider() {
    if (_itemsModalSlotId.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemsAsync = ref.watch(spaceItemsBySlotProvider(_itemsModalSlotId));

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
      data: (items) => ItemsPreviewModal(
        title: _itemsModalTitle,
        items: items,
        selectedItemIds: _selectedItemIds,
        onClose: _closeItemsModal,
        onToggleItem: _toggleItemSelection,
        onBatchMigrate: _batchMigrate,
      ),
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
                onEdit: () => ToastUtils.show(context, '编辑「${cabinet.name}」'),
                onDelete: () =>
                    ToastUtils.show(context, '删除「${cabinet.name}」？'),
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
                onLongPress: () => _openSlotMovePicker(context, slot),
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

  const _RoomCardLarge({
    required this.room,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                    Center(
                      child: Text(
                        room.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
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
  final VoidCallback? onEdit;
  final VoidCallback? onMove;
  final VoidCallback? onDelete;
  final VoidCallback? onLongPress;

  const _SpaceCard({
    this.cabinet,
    this.slot,
    this.slotCount = 0,
    this.items = const [],
    required this.delay,
    required this.onTap,
    this.onEdit,
    this.onMove,
    this.onDelete,
    this.onLongPress,
  });

  String get name => cabinet?.name ?? slot?.name ?? '';
  String get emoji => cabinet?.emoji ?? slot?.emoji ?? '';
  Color get color => cabinet?.color ?? slot?.color ?? AppColors.background;
  int get itemCount => cabinet?.items ?? slot?.items ?? 0;
  int get occupation => cabinet?.occupation ?? slot?.occupation ?? 0;
  bool get hasPhoto => cabinet?.hasPhoto ?? false;

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
                        ],
                      ),
                    ),
                    // 操作按钮
                    Row(
                      children: [
                        if (onEdit != null)
                          _buildActionBtn(
                            Icons.edit_outlined,
                            const Color(0xFFE5A500),
                            onEdit!,
                          ),
                        if (onMove != null)
                          _buildActionBtn(
                            Icons.autorenew,
                            AppColors.info,
                            onMove!,
                          ),
                        if (onDelete != null)
                          _buildActionBtn(
                            Icons.delete_outline,
                            AppColors.danger,
                            onDelete!,
                          ),
                      ],
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
                                  Text(
                                    item.emoji,
                                    style: const TextStyle(fontSize: 13),
                                  ),
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

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 14, color: color),
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

// ========== 长按格子迁移物品弹窗 ==========
class _SlotMoveSheet extends StatefulWidget {
  final Slot slot;
  final String pathLabel;
  final List<Item> items;
  final Future<void> Function(Item item) onAssign;

  const _SlotMoveSheet({
    required this.slot,
    required this.pathLabel,
    required this.items,
    required this.onAssign,
  });

  @override
  State<_SlotMoveSheet> createState() => _SlotMoveSheetState();
}

class _SlotMoveSheetState extends State<_SlotMoveSheet> {
  String _query = '';

  List<Item> get _filtered {
    final q = _query.trim();
    final list = q.isEmpty
        ? widget.items
        : widget.items.where((i) => i.name.contains(q)).toList();
    // 已在该格子的物品排前，再按名称
    list.sort((a, b) {
      final aHere = a.slotId == widget.slot.id;
      final bHere = b.slotId == widget.slot.id;
      if (aHere && !bHere) return -1;
      if (!aHere && bHere) return 1;
      return a.name.compareTo(b.name);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheetHeight = screenHeight * 0.8;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 把手
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
          // 标题
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.slot.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '收纳到「${widget.slot.name}」',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.pathLabel,
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
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '长按格子触发 · 选择一件物品收纳到此格',
                  style: TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ),
          // 搜索框
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: '搜索物品名称',
                hintStyle: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // 列表
          Flexible(
            child: _filtered.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        '没有匹配的物品',
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
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) {
                      final item = _filtered[i];
                      final isHere = item.slotId == widget.slot.id;
                      final isElsewhere = item.cabinetId != null && !isHere;
                      return _MoveItemTile(
                        item: item,
                        isHere: isHere,
                        isElsewhere: isElsewhere,
                        onTap: () => widget.onAssign(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MoveItemTile extends StatelessWidget {
  final Item item;
  final bool isHere;
  final bool isElsewhere;
  final VoidCallback onTap;

  const _MoveItemTile({
    required this.item,
    required this.isHere,
    required this.isElsewhere,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isHere ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isHere
              ? const Color(0xFFFFF8E7)
              : (isElsewhere ? const Color(0xFFFFF3F0) : AppColors.background),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHere ? AppColors.accentGold : AppColors.border,
            width: isHere ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Center(
                child: Text(
                  item.emoji.isNotEmpty ? item.emoji : '📦',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isHere
                        ? '已在当前格子'
                        : (isElsewhere ? '原位置：${item.location}' : '未指定收纳位置'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isHere
                          ? AppColors.accentGold
                          : (isElsewhere
                                ? const Color(0xFFE57373)
                                : AppColors.textHint),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isHere)
              const Icon(
                Icons.check_circle,
                color: AppColors.accentGold,
                size: 20,
              )
            else if (isElsewhere)
              const Icon(Icons.swap_horiz, color: Color(0xFFE57373), size: 18)
            else
              const Icon(
                Icons.add_circle_outline,
                color: AppColors.textSecondary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
