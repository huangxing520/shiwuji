import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/constants/app_dimensions.dart';
import 'package:shi_wu_ji/widgets/gradient_background.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';

// ─────────────────────────────────────────────
// 数据模型（展示用）
// ─────────────────────────────────────────────

enum ItemStatus { safe, expiring, idle, underWarranty }

class InventoryItem {
  final String id;
  final String emoji;
  final String name;
  final String category;
  final String location;
  final double price;
  final ItemStatus status;
  final String statusLabel;
  final String categoryKey; // 用于分类过滤

  const InventoryItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.category,
    required this.location,
    required this.price,
    required this.status,
    required this.statusLabel,
    required this.categoryKey,
  });
}

// ─────────────────────────────────────────────
// 分类 & 排序 常量
// ─────────────────────────────────────────────

class _Category {
  final String key;
  final String label;
  const _Category(this.key, this.label);
}

const _categories = <_Category>[
  _Category('all', '全部'),
  _Category('digital', '数码'),
  _Category('appliance', '家电'),
  _Category('skincare', '护肤'),
  _Category('kitchen', '厨房'),
  _Category('clothing', '衣物'),
  _Category('books', '书籍'),
  _Category('storage', '收纳'),
];

enum SortType { newest, oldest, priceHigh, priceLow, expiring }

const _sortLabels = {
  SortType.newest: '新增时间',
  SortType.oldest: '最早添加',
  SortType.priceHigh: '价格↓',
  SortType.priceLow: '价格↑',
  SortType.expiring: '到期时间',
};

const _sortFullLabels = {
  SortType.newest: '新增时间（最新优先）',
  SortType.oldest: '新增时间（最早优先）',
  SortType.priceHigh: '价格（高→低）',
  SortType.priceLow: '价格（低→高）',
  SortType.expiring: '到期时间（最近优先）',
};

// ─────────────────────────────────────────────
// Mock 数据
// ─────────────────────────────────────────────

const _seedItems = <InventoryItem>[
  InventoryItem(
    id: '1',
    emoji: '🧹',
    name: '戴森V12吸尘器',
    category: '家电',
    location: '客厅收纳柜',
    price: 3990,
    status: ItemStatus.safe,
    statusLabel: '安全',
    categoryKey: 'appliance',
  ),
  InventoryItem(
    id: '2',
    emoji: '🎧',
    name: 'AirPods Pro 2',
    category: '数码',
    location: '书房桌面',
    price: 1899,
    status: ItemStatus.underWarranty,
    statusLabel: '在保',
    categoryKey: 'digital',
  ),
  InventoryItem(
    id: '3',
    emoji: '💊',
    name: '兰蔻小黑瓶精华',
    category: '护肤',
    location: '卧室梳妆台',
    price: 1080,
    status: ItemStatus.expiring,
    statusLabel: '即将到期',
    categoryKey: 'skincare',
  ),
  InventoryItem(
    id: '4',
    emoji: '📦',
    name: '宜家思库布收纳箱×3',
    category: '收纳',
    location: '储物间',
    price: 149,
    status: ItemStatus.idle,
    statusLabel: '闲置',
    categoryKey: 'storage',
  ),
  InventoryItem(
    id: '5',
    emoji: '🎵',
    name: '索尼WH-1000XM5',
    category: '数码',
    location: '书房',
    price: 2499,
    status: ItemStatus.underWarranty,
    statusLabel: '在保',
    categoryKey: 'digital',
  ),
  InventoryItem(
    id: '6',
    emoji: '🍚',
    name: '美的电饭煲',
    category: '厨房',
    location: '料理台',
    price: 399,
    status: ItemStatus.safe,
    statusLabel: '安全',
    categoryKey: 'kitchen',
  ),
  InventoryItem(
    id: '7',
    emoji: '✨',
    name: 'SK-II神仙水230ml',
    category: '护肤',
    location: '卧室梳妆台',
    price: 1590,
    status: ItemStatus.expiring,
    statusLabel: '即将到期',
    categoryKey: 'skincare',
  ),
  InventoryItem(
    id: '8',
    emoji: '🧱',
    name: '乐高建筑系列·悉尼',
    category: '书籍',
    location: '书架第二层',
    price: 599,
    status: ItemStatus.idle,
    statusLabel: '闲置',
    categoryKey: 'books',
  ),
];

const _moreItems = <InventoryItem>[
  InventoryItem(
    id: '9',
    emoji: '👔',
    name: '优衣库轻薄羽绒服',
    category: '衣物',
    location: '衣柜左侧',
    price: 499,
    status: ItemStatus.safe,
    statusLabel: '安全',
    categoryKey: 'clothing',
  ),
  InventoryItem(
    id: '10',
    emoji: '📱',
    name: 'iPhone 15手机壳',
    category: '数码',
    location: '书房抽屉',
    price: 89,
    status: ItemStatus.idle,
    statusLabel: '闲置',
    categoryKey: 'digital',
  ),
  InventoryItem(
    id: '11',
    emoji: '🍳',
    name: '不粘煎锅26cm',
    category: '厨房',
    location: '厨房吊柜',
    price: 159,
    status: ItemStatus.safe,
    statusLabel: '安全',
    categoryKey: 'kitchen',
  ),
  InventoryItem(
    id: '12',
    emoji: '📖',
    name: '设计中的设计·原研哉',
    category: '书籍',
    location: '书架第一层',
    price: 48,
    status: ItemStatus.safe,
    statusLabel: '安全',
    categoryKey: 'books',
  ),
];

// ═════════════════════════════════════════════
// Inventory Page
// ═════════════════════════════════════════════

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage>
    with TickerProviderStateMixin {
  // ── 数据 ──
  List<InventoryItem> _allItems = [..._seedItems];

  // ── 状态 ──
  String _activeCategory = 'all';
  bool _isGridView = true;
  bool _batchMode = false;
  final Set<String> _selectedIds = {};
  String _searchQuery = '';
  SortType _sortType = SortType.newest;
  bool _sortDropdownOpen = false;
  bool _allLoaded = false;
  bool _isLoadingMore = false;

  final TextEditingController _searchController = TextEditingController();

  // ── 筛选面板 ──
  String? _selectedPriceRange;
  String? _selectedLocation;
  String? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────
  // 过滤 & 排序逻辑
  // ───────────────────────────────────────────

  List<InventoryItem> get _filteredItems {
    var items = _allItems.where((item) {
      // 分类过滤
      if (_activeCategory != 'all' && item.categoryKey != _activeCategory) {
        return false;
      }
      // 搜索过滤
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!item.name.toLowerCase().contains(q) &&
            !item.category.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    // 排序
    switch (_sortType) {
      case SortType.newest:
        items.sort((a, b) => b.id.compareTo(a.id));
        break;
      case SortType.oldest:
        items.sort((a, b) => a.id.compareTo(b.id));
        break;
      case SortType.priceHigh:
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortType.priceLow:
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortType.expiring:
        items.sort((a, b) {
          if (a.status == ItemStatus.expiring &&
              b.status != ItemStatus.expiring) {
            return -1;
          }
          if (b.status == ItemStatus.expiring &&
              a.status != ItemStatus.expiring) {
            return 1;
          }
          return 0;
        });
        break;
    }
    return items;
  }

  // ───────────────────────────────────────────
  // 操作
  // ───────────────────────────────────────────

  void _onCategoryChanged(String key) {
    setState(() => _activeCategory = key);
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _toggleBatchMode() {
    setState(() {
      _batchMode = !_batchMode;
      if (!_batchMode) _selectedIds.clear();
    });
    ToastUtils.show(
      context,
      _batchMode ? '已进入批量管理模式' : '退出批量管理模式',
    );
  }

  void _toggleCheck(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _onItemTap(InventoryItem item) {
    if (_batchMode) {
      _toggleCheck(item.id);
      return;
    }
    ToastUtils.show(context, '查看「${item.name}」详情');
  }

  void _selectSort(SortType type) {
    setState(() {
      _sortType = type;
      _sortDropdownOpen = false;
    });
    ToastUtils.show(context, '按${_sortFullLabels[type]}排序');
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {});
      ToastUtils.show(context, '数据已刷新 🎉');
    }
  }

  void _loadMore() async {
    if (_allLoaded || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _allItems = [..._allItems, ..._moreItems];
        _allLoaded = true;
        _isLoadingMore = false;
      });
    }
  }

  void _applyFilters() {
    Navigator.of(context).pop(); // close bottom sheet
    ToastUtils.show(context, '已应用筛选条件');
  }

  void _resetFilters() {
    setState(() {
      _selectedPriceRange = null;
      _selectedLocation = null;
      _selectedStatus = null;
    });
  }

  // ───────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      body: GradientBackground(
        child: GestureDetector(
          onTap: () {
            // 点击空白关闭排序下拉
            if (_sortDropdownOpen) {
              setState(() => _sortDropdownOpen = false);
            }
          },
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildTopBar(),
                    const SizedBox(height: 12),
                    _buildCategoryTabs(),
                    const SizedBox(height: 12),
                    _buildFilterBar(),
                    if (_sortDropdownOpen) _buildSortDropdown(),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _onRefresh,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            // 结果计数
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppDimensions.pageMarginHorizontal,
                                  4,
                                  AppDimensions.pageMarginHorizontal,
                                  10,
                                ),
                                child: _buildResultCount(items.length),
                              ),
                            ),
                            // 列表内容
                            if (_isGridView)
                              _buildGridSliver(items)
                            else
                              _buildListSliver(items),
                            // 加载更多
                            SliverToBoxAdapter(
                              child: _buildLoadMore(),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 80),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // 批量操作栏
                if (_batchMode)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBatchBar(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Top Bar ───────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageMarginHorizontal,
      ),
      child: Row(
        children: [
          // 返回按钮
          _buildIconButton(
            icon: Icons.chevron_left,
            onTap: () => ToastUtils.show(context, '返回首页'),
          ),
          const SizedBox(width: 10),
          // 搜索框
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMedium,
                ),
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
                  const Icon(Icons.search, size: 18, color: AppColors.textHint),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: '搜索物品名称、分类…',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.textHint,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 批量模式按钮
          _buildIconButton(
            icon: Icons.edit_note,
            onTap: _toggleBatchMode,
            isActive: _batchMode,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentLightBg : AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? AppColors.accentGold : AppColors.textSecondary,
        ),
      ),
    );
  }

  // ─── Category Tabs ─────────────────────────

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pageMarginHorizontal,
        ),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isActive = _activeCategory == cat.key;
          return GestureDetector(
            onTap: () => _onCategoryChanged(cat.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? null : AppColors.cardBg,
                gradient: isActive
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.warning],
                      )
                    : null,
                borderRadius: BorderRadius.circular(22),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                cat.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Filter Bar ────────────────────────────

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageMarginHorizontal,
      ),
      child: Row(
        children: [
          // 排序 chip
          _buildFilterChip(
            label: _sortLabels[_sortType] ?? '排序',
            isActive: true,
            showArrow: true,
            onTap: () {
              setState(() => _sortDropdownOpen = !_sortDropdownOpen);
            },
          ),
          const SizedBox(width: 6),
          // 筛选 chip
          _buildFilterChip(
            label: '筛选',
            isActive: false,
            showArrow: false,
            icon: Icons.tune,
            onTap: () => _showFilterPanel(),
          ),
          const Spacer(),
          // 视图切换
          _buildViewToggle(),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    bool showArrow = false,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentLightBg : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.accentGold : AppColors.textSecondary,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 4),
              Icon(
                _sortDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 12,
                color: isActive ? AppColors.accentGold : AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Row(
      children: [
        _buildViewBtn(
          icon: Icons.grid_view,
          isActive: _isGridView,
          onTap: () {
            if (!_isGridView) setState(() => _isGridView = true);
          },
        ),
        const SizedBox(width: 4),
        _buildViewBtn(
          icon: Icons.view_list,
          isActive: !_isGridView,
          onTap: () {
            if (_isGridView) setState(() => _isGridView = false);
          },
        ),
      ],
    );
  }

  Widget _buildViewBtn({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentGold : AppColors.cardBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? Colors.white : AppColors.textHint,
        ),
      ),
    );
  }

  // ─── Sort Dropdown ─────────────────────────

  Widget _buildSortDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pageMarginHorizontal,
        4,
        AppDimensions.pageMarginHorizontal,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusExtraLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.14),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: SortType.values.map((type) {
              final isActive = _sortType == type;
              return GestureDetector(
                onTap: () => _selectSort(type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _sortFullLabels[type]!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? AppColors.accentGold
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (isActive)
                        const Icon(
                          Icons.check,
                          size: 18,
                          color: AppColors.accentGold,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ─── Result Count ──────────────────────────

  Widget _buildResultCount(int count) {
    return RichText(
      text: TextSpan(
        text: '共 ',
        style: const TextStyle(fontSize: 12, color: AppColors.textHint),
        children: [
          TextSpan(
            text: '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accentGold,
            ),
          ),
          const TextSpan(
            text: ' 件物品',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  // ─── Grid View ─────────────────────────────

  Widget _buildGridSliver(List<InventoryItem> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageMarginHorizontal,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return _buildGridCard(item, index);
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildGridCard(InventoryItem item, int index) {
    final isSelected = _selectedIds.contains(item.id);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + index * 50),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: Transform.scale(
            scale: 0.96 + 0.04 * value,
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _onItemTap(item),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片区域
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    // Emoji 背景
                    Container(
                      width: double.infinity,
                      color: AppColors.accentLightBg,
                      child: Center(
                        child: Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 44),
                        ),
                      ),
                    ),
                    // 批量选择圆圈
                    if (_batchMode)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: () => _toggleCheck(item.id),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black12,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.7),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    // 状态标签
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildStatusBadge(item),
                    ),
                  ],
                ),
              ),
              // 信息区域
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.category} · ${item.location}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                      const Spacer(),
                      _buildPrice(item.price),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── List View ─────────────────────────────

  Widget _buildListSliver(List<InventoryItem> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageMarginHorizontal,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildListCard(item, index),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildListCard(InventoryItem item, int index) {
    final isSelected = _selectedIds.contains(item.id);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + index * 50),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-12 * (1 - value), 0),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _onItemTap(item),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusExtraLarge),
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
              // 缩略图
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.accentLightBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        item.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  if (_batchMode)
                    Positioned(
                      top: -4,
                      left: -4,
                      child: GestureDetector(
                        onTap: () => _toggleCheck(item.id),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.black12,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.cardBg,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
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
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          item.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 价格 + 状态
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildPrice(item.price),
                  const SizedBox(height: 3),
                  _buildStatusBadge(item, isSmall: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 通用组件 ──────────────────────────────

  Widget _buildStatusBadge(InventoryItem item, {bool isSmall = false}) {
    Color bgColor;
    Color textColor;
    switch (item.status) {
      case ItemStatus.expiring:
        bgColor = AppColors.dangerLight;
        textColor = AppColors.danger;
        break;
      case ItemStatus.safe:
        bgColor = AppColors.successLight;
        textColor = AppColors.statusUsing;
        break;
      case ItemStatus.idle:
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        break;
      case ItemStatus.underWarranty:
        bgColor = AppColors.successLight;
        textColor = AppColors.statusUsing;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 8,
        vertical: isSmall ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isSmall ? 10 : 12),
      ),
      child: Text(
        item.statusLabel,
        style: TextStyle(
          fontSize: isSmall ? 10 : 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildPrice(double price) {
    final formatted = price >= 1000
        ? '${(price / 1000).floor()},${(price % 1000).toInt().toString().padLeft(3, '0')}'
        : price.toInt().toString();
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '¥',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.accentGold,
            height: 1.2,
          ),
        ),
        Text(
          formatted,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.accentGold,
            height: 1,
          ),
        ),
      ],
    );
  }

  // ─── Load More ─────────────────────────────

  Widget _buildLoadMore() {
    if (_allLoaded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            '已全部加载',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: _loadMore,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoadingMore) ...[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '加载中…',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else
                const Text(
                  '上拉加载更多',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Batch Bar ─────────────────────────────

  Widget _buildBatchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              text: '已选 ',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: '${_selectedIds.length}',
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' 件'),
              ],
            ),
          ),
          Row(
            children: [
              _buildBatchBtn('移动', AppColors.infoLight, AppColors.info),
              const SizedBox(width: 8),
              _buildBatchBtn('导出', AppColors.successLight, AppColors.statusUsing),
              const SizedBox(width: 8),
              _buildBatchBtn('删除', AppColors.dangerLight, AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchBtn(String label, Color bgColor, Color textColor) {
    return GestureDetector(
      onTap: () {
        final actions = {'移动': '移动到…', '导出': '导出选中物品', '删除': '确认删除？'};
        ToastUtils.show(context, actions[label] ?? label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // ─── Filter Panel (Bottom Sheet) ───────────

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _buildFilterSheet(ctx),
    );
  }

  Widget _buildFilterSheet(BuildContext ctx) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadiusXLarge),
          topRight: Radius.circular(AppDimensions.borderRadiusXLarge),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
                  '筛选条件',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: _resetFilters,
                  child: const Text(
                    '重置',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 价格区间
            _buildFilterSection(
              label: '价格区间',
              options: ['不限', '¥0–100', '¥100–500', '¥500–2000', '¥2000以上'],
              selected: _selectedPriceRange,
              onSelect: (v) => setState(() => _selectedPriceRange = v),
            ),
            const SizedBox(height: 16),
            // 收纳位置
            _buildFilterSection(
              label: '收纳位置',
              options: ['全部', '客厅', '卧室', '书房', '厨房', '储物间'],
              selected: _selectedLocation,
              onSelect: (v) => setState(() => _selectedLocation = v),
            ),
            const SizedBox(height: 16),
            // 物品状态
            _buildFilterSection(
              label: '物品状态',
              options: ['全部', '正常使用', '闲置', '即将到期', '已借出'],
              selected: _selectedStatus,
              onSelect: (v) => setState(() => _selectedStatus = v),
            ),
            const SizedBox(height: 8),
            // 确认按钮
            GestureDetector(
              onTap: _applyFilters,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.warning],
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusExtraLarge,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '确认筛选',
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
    );
  }

  Widget _buildFilterSection({
    required String label,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentLightBg : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.accentGold
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
