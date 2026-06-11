import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/toast_utils.dart';

/// 收纳位置管理页面
class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  // 当前层级：0=房间，1=柜体，2=格子
  int _currentLevel = 0;
  String? _currentRoomId;
  String? _currentCabinetId;

  // 模态框状态
  bool _showAddModal = false;
  bool _showItemsModal = false;
  String _itemsModalTitle = '';
  List<_SpaceItem> _currentItems = [];
  final Set<String> _selectedItemIds = {};

  // 添加表单
  String _addLevel = 'room';
  String _addParent = '我的家（顶级）';
  String _addName = '';
  String _selectedIcon = '🛋️';

  // 图标选项
  final List<String> _iconOptions = [
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

  // ========== 数据 ==========
  final List<_Room> _rooms = [
    _Room(
      id: 'r1',
      name: '客厅',
      emoji: '🛋️',
      color: const Color(0xFFFFE8CC),
      items: 42,
      storageCount: 3,
      occupation: 78,
    ),
    _Room(
      id: 'r2',
      name: '卧室',
      emoji: '🛏️',
      color: const Color(0xFFE8F5E9),
      items: 56,
      storageCount: 4,
      occupation: 65,
    ),
    _Room(
      id: 'r3',
      name: '书房',
      emoji: '📚',
      color: const Color(0xFFD4E8FF),
      items: 68,
      storageCount: 3,
      occupation: 82,
    ),
    _Room(
      id: 'r4',
      name: '厨房',
      emoji: '🍳',
      color: const Color(0xFFFFD4D4),
      items: 34,
      storageCount: 2,
      occupation: 55,
    ),
    _Room(
      id: 'r5',
      name: '储物间',
      emoji: '🗄️',
      color: const Color(0xFFE4DAFF),
      items: 36,
      storageCount: 2,
      occupation: 90,
    ),
  ];

  final Map<String, List<_Cabinet>> _cabinets = {
    'r1': [
      _Cabinet(
        id: 'c1',
        name: '电视柜',
        emoji: '📺',
        color: const Color(0xFFFFE8CC),
        items: 12,
        occupation: 45,
        hasPhoto: true,
      ),
      _Cabinet(
        id: 'c2',
        name: '收纳柜',
        emoji: '🗄️',
        color: const Color(0xFFFFE8CC),
        items: 18,
        occupation: 85,
        hasPhoto: true,
      ),
      _Cabinet(
        id: 'c3',
        name: '茶几抽屉',
        emoji: '☕',
        color: const Color(0xFFFFE8CC),
        items: 12,
        occupation: 60,
        hasPhoto: false,
      ),
    ],
    'r2': [
      _Cabinet(
        id: 'c4',
        name: '衣柜',
        emoji: '👔',
        color: const Color(0xFFE8F5E9),
        items: 28,
        occupation: 72,
        hasPhoto: true,
      ),
      _Cabinet(
        id: 'c5',
        name: '梳妆台',
        emoji: '💄',
        color: const Color(0xFFE8F5E9),
        items: 16,
        occupation: 58,
        hasPhoto: true,
      ),
      _Cabinet(
        id: 'c6',
        name: '床头柜',
        emoji: '💡',
        color: const Color(0xFFE8F5E9),
        items: 8,
        occupation: 40,
        hasPhoto: false,
      ),
      _Cabinet(
        id: 'c7',
        name: '斗柜',
        emoji: '📦',
        color: const Color(0xFFE8F5E9),
        items: 4,
        occupation: 20,
        hasPhoto: false,
      ),
    ],
    'r3': [
      _Cabinet(
        id: 'c8',
        name: '书架',
        emoji: '📚',
        color: const Color(0xFFD4E8FF),
        items: 32,
        occupation: 88,
        hasPhoto: true,
      ),
      _Cabinet(
        id: 'c9',
        name: '桌面',
        emoji: '🖥️',
        color: const Color(0xFFD4E8FF),
        items: 24,
        occupation: 70,
        hasPhoto: false,
      ),
      _Cabinet(
        id: 'c10',
        name: '抽屉柜',
        emoji: '🗄️',
        color: const Color(0xFFD4E8FF),
        items: 12,
        occupation: 50,
        hasPhoto: false,
      ),
    ],
    'r4': [
      _Cabinet(
        id: 'c11',
        name: '吊柜',
        emoji: '🍳',
        color: const Color(0xFFFFD4D4),
        items: 14,
        occupation: 62,
        hasPhoto: true,
      ),
      _Cabinet(
        id: 'c12',
        name: '料理台',
        emoji: '🔪',
        color: const Color(0xFFFFD4D4),
        items: 20,
        occupation: 48,
        hasPhoto: false,
      ),
    ],
    'r5': [
      _Cabinet(
        id: 'c13',
        name: '置物架A',
        emoji: '📦',
        color: const Color(0xFFE4DAFF),
        items: 22,
        occupation: 95,
        hasPhoto: true,
      ),
      _Cabinet(
        id: 'c14',
        name: '置物架B',
        emoji: '📦',
        color: const Color(0xFFE4DAFF),
        items: 14,
        occupation: 78,
        hasPhoto: false,
      ),
    ],
  };

  final Map<String, List<_Slot>> _slots = {
    'c2': [
      _Slot(
        id: 's1',
        name: '上层·日常杂物',
        emoji: '🔋',
        color: const Color(0xFFFFF3CC),
        items: 8,
        occupation: 90,
      ),
      _Slot(
        id: 's2',
        name: '中层·电子配件',
        emoji: '🔌',
        color: const Color(0xFFFFF3CC),
        items: 6,
        occupation: 75,
      ),
      _Slot(
        id: 's3',
        name: '下层·工具备用',
        emoji: '🔧',
        color: const Color(0xFFFFF3CC),
        items: 4,
        occupation: 55,
      ),
    ],
    'c4': [
      _Slot(
        id: 's4',
        name: '左区·上衣区',
        emoji: '👔',
        color: const Color(0xFFD4F5D9),
        items: 12,
        occupation: 80,
      ),
      _Slot(
        id: 's5',
        name: '右区·裤裙区',
        emoji: '👖',
        color: const Color(0xFFD4F5D9),
        items: 10,
        occupation: 65,
      ),
      _Slot(
        id: 's6',
        name: '顶层·换季收纳',
        emoji: '🧣',
        color: const Color(0xFFD4F5D9),
        items: 6,
        occupation: 70,
      ),
    ],
    'c8': [
      _Slot(
        id: 's7',
        name: '第一层·常用书',
        emoji: '📖',
        color: const Color(0xFFD4E8FF),
        items: 14,
        occupation: 92,
      ),
      _Slot(
        id: 's8',
        name: '第二层·技术书',
        emoji: '💻',
        color: const Color(0xFFD4E8FF),
        items: 10,
        occupation: 80,
      ),
      _Slot(
        id: 's9',
        name: '第三层·收藏',
        emoji: '🧱',
        color: const Color(0xFFD4E8FF),
        items: 8,
        occupation: 60,
      ),
    ],
  };

  final Map<String, List<_SpaceItem>> _spaceItems = {
    's1': [
      _SpaceItem(emoji: '🔋', name: '南孚电池AA×24', meta: '日用 · 购入2024-06'),
      _SpaceItem(emoji: '💡', name: 'LED灯泡E27×6', meta: '照明 · 购入2024-03'),
      _SpaceItem(emoji: '📎', name: '得力回形针盒', meta: '文具 · 购入2024-08'),
      _SpaceItem(emoji: '🧴', name: '除湿盒×3', meta: '日用 · 购入2025-01'),
      _SpaceItem(emoji: '🧹', name: '粘毛滚筒替换装', meta: '清洁 · 购入2025-04'),
      _SpaceItem(emoji: '🔌', name: '魔方插座', meta: '数码 · 购入2024-11'),
      _SpaceItem(emoji: '✂️', name: '得力剪刀', meta: '文具 · 购入2024-02'),
      _SpaceItem(emoji: '🧻', name: '保鲜膜套装', meta: '日用 · 购入2025-03'),
    ],
    's2': [
      _SpaceItem(emoji: '🔌', name: 'Type-C数据线×3', meta: '数码 · 购入2024-12'),
      _SpaceItem(emoji: '🎧', name: '3.5mm音频线', meta: '数码 · 购入2024-09'),
      _SpaceItem(emoji: '📱', name: 'iPhone充电器', meta: '数码 · 购入2024-10'),
      _SpaceItem(emoji: '🖱️', name: '鼠标接收器', meta: '数码 · 购入2024-07'),
      _SpaceItem(emoji: '💾', name: 'U盘128GB', meta: '数码 · 购入2024-05'),
      _SpaceItem(emoji: '🔋', name: '充电宝20000mAh', meta: '数码 · 购入2024-08'),
    ],
    's3': [
      _SpaceItem(emoji: '🔧', name: '多功能螺丝刀套装', meta: '工具 · 购入2024-01'),
      _SpaceItem(emoji: '🔨', name: '羊角锤', meta: '工具 · 购入2023-12'),
      _SpaceItem(emoji: '📐', name: '卷尺5m', meta: '工具 · 购入2024-04'),
      _SpaceItem(emoji: '🩹', name: '工具胶水套装', meta: '工具 · 购入2024-06'),
    ],
  };

  // ========== 统计数据 ==========
  int get _totalCabinets =>
      _cabinets.values.fold(0, (sum, list) => sum + list.length);
  int get _totalSlots =>
      _slots.values.fold(0, (sum, list) => sum + list.length);
  int get _totalItems => _rooms.fold(0, (sum, r) => sum + r.items);

  // ========== 导航 ==========
  void _navigateLevel(int level) {
    setState(() {
      if (level == 0) {
        _currentLevel = 0;
        _currentRoomId = null;
        _currentCabinetId = null;
      } else if (level == 1) {
        _currentLevel = 1;
        _currentCabinetId = null;
      }
    });
  }

  void _enterRoom(String roomId) {
    setState(() {
      _currentLevel = 1;
      _currentRoomId = roomId;
      _currentCabinetId = null;
    });
  }

  void _enterCabinet(String cabinetId) {
    setState(() {
      _currentLevel = 2;
      _currentCabinetId = cabinetId;
    });
  }

  // ========== 模态框 ==========
  void _openAddModal() {
    setState(() {
      _showAddModal = true;
      _addName = '';
      _selectedIcon = _iconOptions.first;
    });
  }

  void _closeAddModal() {
    setState(() {
      _showAddModal = false;
    });
  }

  void _saveSpace() {
    if (_addName.isEmpty) {
      ToastUtils.show(context, '请输入空间名称');
      return;
    }
    ToastUtils.show(context, '已添加「$_addName」');
    _closeAddModal();
  }

  void _openItemsModal(String title, List<_SpaceItem> items) {
    setState(() {
      _showItemsModal = true;
      _itemsModalTitle = title;
      _currentItems = items;
      _selectedItemIds.clear();
    });
  }

  void _closeItemsModal() {
    setState(() {
      _showItemsModal = false;
    });
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
      backgroundColor: Color(0xFFFFFDF7),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                //_buildStatusBar(),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          _buildTopBar(),
                          //_buildBreadcrumb(),
                          Expanded(
                            child: Column(
                              children: [
                                _buildLevelTabs(),
                                Expanded(child: _buildScrollArea()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_showAddModal) _buildAddModal(),
          if (_showItemsModal) _buildItemsModal(),
        ],
      ),
    );
  }

  // ========== 顶部栏 ==========
  Widget _buildTopBar() {
    return
    // padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
    Row(
      children: [
        const Spacer(),

        Text(
          '收纳位置管理',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _openAddModal,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              //               gradient: RadialGradient(
              //   // 渐变起始、结束颜色，可填多个颜色分段
              //   colors: [
              //     Color(0xFFFFC250),
              //     Color.fromARGB(255, 217, 134, 57),
              //   ],

              // ),
              color: Color(0xFFFF8818),
              shape: BoxShape.circle, // 强制圆形
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 18, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  // ========== 面包屑 ==========
  Widget _buildBreadcrumb() {
    final items = <Widget>[];

    // 我的家
    items.add(
      _buildBreadcrumbItem(
        '🏠 我的家',
        _currentLevel == 0 && _currentRoomId == null,
        () => _navigateLevel(0),
      ),
    );

    if (_currentRoomId != null) {
      final room = _rooms.firstWhere((r) => r.id == _currentRoomId);
      items.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Text(
            '›',
            style: TextStyle(fontSize: 10, color: Color(0xFFF0E4D0)),
          ),
        ),
      );
      items.add(
        _buildBreadcrumbItem(
          '${room.emoji} ${room.name}',
          _currentLevel == 1 && _currentCabinetId == null,
          () => _navigateLevel(1),
        ),
      );
    }

    if (_currentCabinetId != null) {
      final cabinet = _cabinets[_currentRoomId]?.firstWhere(
        (c) => c.id == _currentCabinetId,
      );
      if (cabinet != null) {
        items.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              '›',
              style: TextStyle(fontSize: 10, color: Color(0xFFF0E4D0)),
            ),
          ),
        );
        items.add(
          _buildBreadcrumbItem('${cabinet.emoji} ${cabinet.name}', true, null),
        );
      }
    }

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: items),
      ),
    );
  }

  Widget _buildBreadcrumbItem(
    String text,
    bool isCurrent,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
          color: isCurrent ? const Color(0xFFE5A500) : AppColors.textHint,
        ),
      ),
    );
  }

  // ========== 层级标签 ==========
  Widget _buildLevelTabs() {
    final levels = [('房间', _rooms.length), ('柜体', _totalCabinets)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: levels.asMap().entries.map((entry) {
          final i = entry.key;
          final (label, count) = entry.value;
          final isActive = i == _currentLevel;
          return Padding(
            padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
            child: GestureDetector(
              onTap: () => _navigateLevel(i),
              child: Container(
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
                  color: isActive ? null : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isActive
                        ? Colors.transparent
                        : const Color(0xFFF0E4D0),
                    width: 1.5,
                  ),
                  boxShadow: [
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
                            : AppColors.textSecondary,
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
                            : Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
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
          _buildStatsBanner(),
          const SizedBox(height: 16),
          _buildContent(),
        ],
      ),
    );
  }

  // ========== 统计横幅 ==========
  Widget _buildStatsBanner() {
    return Container(
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
          // 装饰圆
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: 30,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // 统计项
          Row(
            children: [
              _buildStatItem(_rooms.length, '房间'),
              _buildStatItem(_totalCabinets, '柜体'),
              //_buildStatItem(_totalSlots, '格子/区域'),
              _buildStatItem(_totalItems, '物品总数'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(int num, String label) {
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

  // ========== 内容区域 ==========
  Widget _buildContent() {
    if (_currentLevel == 0) {
      return _buildRoomsList();
    } else if (_currentLevel == 1) {
      if (_currentRoomId != null && _cabinets[_currentRoomId] != null) {
        return _buildCabinetsList(_cabinets[_currentRoomId]!);
      } else {
        return _buildAllCabinetsList();
      }
    }
    return SizedBox.shrink();
    //  else {
    //   if (_currentCabinetId != null && _slots[_currentCabinetId] != null) {
    //     return _buildSlotsList(_slots[_currentCabinetId]!);
    //   } else {
    //     return _buildAllSlotsList();
    //   }
    // }
  }

  // ========== 房间列表 ==========
  Widget _buildRoomsList() {
    return Column(
      children: _rooms.asMap().entries.map((entry) {
        final i = entry.key;
        final room = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _RoomCardLarge(
            room: room,
            delay: i * 0.08,
            onTap: () => _enterRoom(room.id),
          ),
        );
      }).toList(),
    );
  }

  // ========== 柜体列表 ==========
  Widget _buildCabinetsList(List<_Cabinet> cabinets) {
    return Column(
      children: cabinets.asMap().entries.map((entry) {
        final i = entry.key;
        final cabinet = entry.value;
        final hasSlots =
            _slots[cabinet.id] != null && _slots[cabinet.id]!.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _SpaceCard(
            cabinet: cabinet,
            slotCount: hasSlots ? _slots[cabinet.id]!.length : 0,
            delay: i * 0.08,
            onTap: () {
              if (hasSlots) {
                _enterCabinet(cabinet.id);
              } else {
                _openItemsModal(cabinet.name, _spaceItems['s1'] ?? []);
              }
            },
            onEdit: () => ToastUtils.show(context, '编辑「${cabinet.name}」'),
            onDelete: () => ToastUtils.show(context, '删除「${cabinet.name}」？'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllCabinetsList() {
    final allCabinets = <_Cabinet>[];
    _cabinets.forEach((roomId, cabs) {
      allCabinets.addAll(cabs);
    });
    return _buildCabinetsList(allCabinets);
  }

  // ========== 添加模态框 ==========
  Widget _buildAddModal() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _closeAddModal,
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: GestureDetector(
            onTap: () {}, // 阻止点击穿透
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 720),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 头部
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '新增收纳空间',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: _closeAddModal,
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
                      const SizedBox(height: 18),
                      // 所属层级
                      _buildFormRow('所属层级', _buildLevelSelect()),
                      // 上级空间
                      _buildFormRow('上级空间', _buildParentSelect()),
                      // 空间名称
                      _buildFormRow('空间名称', _buildNameInput(), required: true),
                      // 选择图标
                      _buildFormRow('选择图标', _buildIconGrid()),
                      // 上传实景图
                      _buildFormRow('上传实景图', _buildPhotoUpload()),
                      const SizedBox(height: 6),
                      // 确认按钮
                      GestureDetector(
                        onTap: _saveSpace,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accentGold, AppColors.warning],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x40FFB800),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '确认添加',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormRow(String label, Widget child, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(fontSize: 10, color: AppColors.danger),
                ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _buildLevelSelect() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0E4D0), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _addLevel,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'room', child: Text('房间')),
            DropdownMenuItem(value: 'cabinet', child: Text('柜体')),
            DropdownMenuItem(value: 'slot', child: Text('格子/区域')),
          ],
          onChanged: (v) => setState(() => _addLevel = v!),
        ),
      ),
    );
  }

  Widget _buildParentSelect() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0E4D0), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _addParent,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: '我的家（顶级）', child: Text('我的家（顶级）')),
            DropdownMenuItem(value: '客厅', child: Text('客厅')),
            DropdownMenuItem(value: '卧室', child: Text('卧室')),
            DropdownMenuItem(value: '书房', child: Text('书房')),
            DropdownMenuItem(value: '厨房', child: Text('厨房')),
          ],
          onChanged: (v) => setState(() => _addParent = v!),
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return TextField(
      decoration: InputDecoration(
        hintText: '例如：客厅收纳柜',
        hintStyle: const TextStyle(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF0E4D0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF0E4D0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
      ),
      onChanged: (v) => _addName = v,
    );
  }

  Widget _buildIconGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _iconOptions.map((icon) {
        final isSelected = icon == _selectedIcon;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = icon),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFFF3CC)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentGold
                    : const Color(0xFFF0E4D0),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: () => ToastUtils.show(context, '选择实景照片'),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFF0E4D0),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 24,
              color: AppColors.textHint,
            ),
            SizedBox(width: 8),
            Text(
              '点击上传空间照片',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== 物品列表模态框 ==========
  Widget _buildItemsModal() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _closeItemsModal,
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: GestureDetector(
            onTap: () {}, // 阻止点击穿透
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 720),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 头部
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _itemsModalTitle,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: _closeItemsModal,
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
                      const SizedBox(height: 18),
                      // 物品列表
                      ...(_currentItems.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        final isSelected = _selectedItemIds.contains('$i');
                        return _buildItemListTile(item, '$i', isSelected);
                      })),
                      if (_selectedItemIds.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _batchMigrate,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.info, Color(0xFF7AB8FF)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x405B9BFF),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '批量迁移选中物品',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemListTile(_SpaceItem item, String id, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleItemSelection(id),
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
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 20)),
              ),
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
                    item.meta,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
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

// ========== 数据模型 ==========
class _Room {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final int items;
  final int storageCount;
  final int occupation;

  _Room({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.items,
    required this.storageCount,
    required this.occupation,
  });
}
// ========== 柜子 ==========
class _Cabinet {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final int items;
  final int occupation;
  final bool hasPhoto;

  _Cabinet({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.items,
    required this.occupation,
    required this.hasPhoto,
  });
}
// ========== 格子 ==========
class _Slot {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final int items;
  final int occupation;

  _Slot({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.items,
    required this.occupation,
  });
}
// ========== 物品 ==========
class _SpaceItem {
  final String emoji;
  final String name;
  final String meta;

  _SpaceItem({required this.emoji, required this.name, required this.meta});
}

// ========== 房间大卡片 ==========
class _RoomCardLarge extends StatelessWidget {
  final _Room room;
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
  final _Cabinet? cabinet;
  final _Slot? slot;
  final int slotCount;
  final List<_SpaceItem> items;
  final double delay;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onMove;
  final VoidCallback? onDelete;

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
