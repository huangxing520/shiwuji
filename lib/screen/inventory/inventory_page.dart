import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/constants/app_dimensions.dart';
import 'package:shi_wu_ji/widgets/gradient_background.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';
import 'package:shi_wu_ji/models/item.dart';
import 'package:shi_wu_ji/models/inventory_item.dart';
import 'package:shi_wu_ji/models/enums/item_status.dart';
import 'package:shi_wu_ji/models/enums/sort_type.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';
import 'package:shi_wu_ji/screen/inventory/sort_dropdown.dart';
import 'package:shi_wu_ji/screen/inventory/filter_panel.dart';

// ─────────────────────────────────────────────
// 分类 & 排序 常量
// ─────────────────────────────────────────────

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

// ═════════════════════════════════════════════
// Inventory Page
// ═════════════════════════════════════════════

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  // ── 状态 ──
  String _activeCategory = 'all';
  bool _isGridView = true;
  bool _batchMode = false;
  final Set<String> _selectedIds = {};
  String _searchQuery = '';
  SortType _sortType = SortType.newest;
  bool _sortDropdownOpen = false;

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

  @override
  void initState() {
    super.initState();
    // 在 initState 中处理来自其他页面的 pending 筛选请求。
    // IndexedStack 首次懒加载页面时，build 中 ref.watch 改 State + postFrame
    // 清空 provider 的模式存在时序竞态，可能导致首次跳转筛选未应用。
    // initState 一定先于 build 执行，此时 provider 值刚由来源页设置，可稳定读取。
    String? pendingCat = ref.read(pendingCategoryProvider);
    String? pendingStatus = ref.read(pendingStatusFilterProvider);

    if (pendingCat != null) {
      _activeCategory = pendingCat;
    }
    if (pendingStatus != null) {
      const statusMap = {
        'expiring': '即将到期',
        'idle': '闲置',
        'underWarranty': '在保',
        'safe': '安全',
      };
      final label = statusMap[pendingStatus];
      if (label != null) {
        _selectedStatus = label;
      }
    }
    // 统一在 postFrame 清空 pending provider，避免下次进入重复触发
    if (pendingCat != null || pendingStatus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(pendingCategoryProvider.notifier).set(null);
          ref.read(pendingStatusFilterProvider.notifier).set(null);
        }
      });
    }
  }

  // ───────────────────────────────────────────
  // Status helpers
  // ───────────────────────────────────────────

  String _statusLabel(String status) {
    switch (status) {
      case 'safe':
        return '安全';
      case 'expiring':
        return '即将到期';
      case 'idle':
        return '闲置';
      case 'underWarranty':
        return '在保';
      default:
        return '安全';
    }
  }

  ItemStatus _toItemStatus(String status) {
    switch (status) {
      case 'safe':
        return ItemStatus.safe;
      case 'expiring':
        return ItemStatus.expiring;
      case 'idle':
        return ItemStatus.idle;
      case 'underWarranty':
        return ItemStatus.underWarranty;
      default:
        return ItemStatus.safe;
    }
  }

  // ───────────────────────────────────────────
  // 过滤 & 排序逻辑 (from Riverpod provider)
  // ───────────────────────────────────────────

  /// 当前激活的筛选条件数量（用于筛选 chip 角标）
  int get _activeFilterCount {
    int count = 0;
    if (_selectedPriceRange != null && _selectedPriceRange != '不限') count++;
    if (_selectedLocation != null && _selectedLocation != '全部') count++;
    if (_selectedStatus != null && _selectedStatus != '全部') count++;
    return count;
  }

  List<Item> get _filteredItems {
    final allItemsAsync = ref.watch(itemsProvider);
    return allItemsAsync.maybeWhen(
      data: (allItems) {
        var filtered = allItems;
        if (_activeCategory != 'all') {
          filtered = filtered
              .where((i) => i.categoryKey == _activeCategory)
              .toList();
        }
        if (_searchQuery.isNotEmpty) {
          filtered = filtered
              .where(
                (i) =>
                    i.name.contains(_searchQuery) ||
                    i.category.contains(_searchQuery) ||
                    i.location.contains(_searchQuery),
              )
              .toList();
        }
        // 价格区间筛选
        if (_selectedPriceRange != null && _selectedPriceRange != '不限') {
          filtered = filtered.where((i) {
            switch (_selectedPriceRange!) {
              case '¥0–100':
                return i.price >= 0 && i.price <= 100;
              case '¥100–500':
                return i.price > 100 && i.price <= 500;
              case '¥500–2000':
                return i.price > 500 && i.price <= 2000;
              case '¥2000以上':
                return i.price > 2000;
              default:
                return true;
            }
          }).toList();
        }
        // 收纳位置筛选（包含匹配，如「客厅」匹配「客厅收纳柜」）
        if (_selectedLocation != null && _selectedLocation != '全部') {
          filtered = filtered
              .where((i) => i.location.contains(_selectedLocation!))
              .toList();
        }
        // 物品状态筛选
        if (_selectedStatus != null && _selectedStatus != '全部') {
          const statusKey = {
            '安全': 'safe',
            '在保': 'underWarranty',
            '即将到期': 'expiring',
            '闲置': 'idle',
          };
          final key = statusKey[_selectedStatus!];
          if (key != null) {
            filtered = filtered.where((i) => i.status == key).toList();
          }
        }
        switch (_sortType) {
          case SortType.newest:
            filtered.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
            break;
          case SortType.oldest:
            filtered.sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
            break;
          case SortType.priceHigh:
            filtered.sort((a, b) => b.price.compareTo(a.price));
            break;
          case SortType.priceLow:
            filtered.sort((a, b) => a.price.compareTo(b.price));
            break;
          case SortType.expiring:
            filtered.sort(
              (a, b) => a.daysUntilWarrantyExpiry.compareTo(
                b.daysUntilWarrantyExpiry,
              ),
            );
            break;
        }
        return filtered;
      },
      orElse: () => [],
    );
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
    ToastUtils.show(context, _batchMode ? '已进入批量管理模式' : '退出批量管理模式');
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

  void _onItemTap(Item item) {
    if (_batchMode) {
      _toggleCheck(item.id);
      return;
    }
    context.push('/detail/${item.id}');
  }

  void _selectSort(SortType type) {
    setState(() {
      _sortType = type;
      _sortDropdownOpen = false;
    });
    ToastUtils.show(context, '按${_sortFullLabels[type]}排序');
  }

  Future<void> _onRefresh() async {
    ref.invalidate(itemsProvider);
    await ref.read(itemsProvider.future);
  }

  // ───────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // 用 watch 监听待选分类：IndexedStack 切换分支不会重建已存在的页面 State，
    // 必须用 watch 让 provider 变化时强制 rebuild，才能读到其他页面设置的值。
    final pending = ref.watch(pendingCategoryProvider);
    if (pending != null) {
      if (pending != _activeCategory) {
        _activeCategory = pending;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(pendingCategoryProvider.notifier).set(null);
        }
      });
    }

    // 监听来自首页的状态筛选请求
    final pendingStatus = ref.watch(pendingStatusFilterProvider);
    if (pendingStatus != null) {
      const statusMap = {
        'expiring': '即将到期',
        'idle': '闲置',
        'underWarranty': '在保',
        'safe': '安全',
      };
      final label = statusMap[pendingStatus];
      if (label != null && _selectedStatus != label) {
        _selectedStatus = label;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(pendingStatusFilterProvider.notifier).set(null);
        }
      });
    }

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
                    Expanded(child: _buildListArea(items)),
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

  // ─── List Area (排序下拉作为浮层，不影响列表布局) ──

  Widget _buildListArea(List<Item> items) {
    return Stack(
      children: [
        RefreshIndicator(
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
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
        // 排序下拉浮层：叠在列表之上，不挤压下方内容
        if (_sortDropdownOpen) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _sortDropdownOpen = false),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            top: 4,
            left: 0,
            right: 0,
            child: SortDropdown(
              currentSort: _sortType,
              onSortSelected: _selectSort,
            ),
          ),
        ],
      ],
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
        itemCount: Category.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = Category.all[index];
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
            label: _activeFilterCount > 0 ? '筛选·$_activeFilterCount' : '筛选',
            isActive: _activeFilterCount > 0,
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
                color: isActive
                    ? AppColors.accentGold
                    : AppColors.textSecondary,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 4),
              Icon(
                _sortDropdownOpen
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 12,
                color: isActive
                    ? AppColors.accentGold
                    : AppColors.textSecondary,
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

  Widget _buildGridSliver(List<Item> items) {
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
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          return _buildGridCard(item, index);
        }, childCount: items.length),
      ),
    );
  }

  Widget _buildGridCard(Item item, int index) {
    final isSelected = _selectedIds.contains(item.id);
    final emoji = item.emoji.isNotEmpty ? item.emoji : '📦';
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
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadiusXLarge,
            ),
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
                          emoji,
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

  Widget _buildListSliver(List<Item> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageMarginHorizontal,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildListCard(item, index),
          );
        }, childCount: items.length),
      ),
    );
  }

  Widget _buildListCard(Item item, int index) {
    final isSelected = _selectedIds.contains(item.id);
    final emoji = item.emoji.isNotEmpty ? item.emoji : '📦';
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
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadiusExtraLarge,
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
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
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

  Widget _buildStatusBadge(Item item, {bool isSmall = false}) {
    final itemStatus = _toItemStatus(item.status);
    Color bgColor;
    Color textColor;
    switch (itemStatus) {
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
        _statusLabel(item.status),
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
              _buildBatchBtn(
                '导出',
                AppColors.successLight,
                AppColors.statusUsing,
              ),
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
    FilterPanel.show(
      context,
      initialPriceRange: _selectedPriceRange,
      initialLocation: _selectedLocation,
      initialStatus: _selectedStatus,
      onApply: (priceRange, location, status) {
        setState(() {
          _selectedPriceRange = priceRange;
          _selectedLocation = location;
          _selectedStatus = status;
        });
        ToastUtils.show(context, '已应用筛选条件');
      },
      onReset: () {
        setState(() {
          _selectedPriceRange = null;
          _selectedLocation = null;
          _selectedStatus = null;
        });
      },
    );
  }
}
