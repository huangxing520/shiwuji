import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/constants/app_dimensions.dart';

/// Callback signature for when filters are applied.
typedef FilterApplyCallback =
    void Function(
      String? priceRange,
      String? location,
      String? status,
      String? borrowedStatus,
      DateTime? purchaseStart,
      DateTime? purchaseEnd,
    );

/// Standalone filter panel shown as a modal bottom sheet.
class FilterPanel extends StatefulWidget {
  final String? initialPriceRange;
  final String? initialLocation;
  final String? initialStatus;
  final String? initialBorrowedStatus;
  final DateTime? initialPurchaseStart;
  final DateTime? initialPurchaseEnd;
  final FilterApplyCallback onApply;
  final VoidCallback onReset;

  /// 外部关闭信号：值每次自增表示请求关闭弹窗。
  /// 用于跨分支跳转场景（首页快捷入口 → 物品库）：宿主页（InventoryPage）
  /// 的 build context 解析到的 Navigator 未必是承载弹窗的那个（showModalBottomSheet
  /// 默认 useRootNavigator=false，弹窗 push 到最近层导航器），因此由宿主页通过
  /// 此信号通知弹窗用【自身 context】执行 pop，确保命中正确的 Navigator。
  final ValueListenable<int>? dismissSignal;

  const FilterPanel({
    super.key,
    this.initialPriceRange,
    this.initialLocation,
    this.initialStatus,
    this.initialBorrowedStatus,
    this.initialPurchaseStart,
    this.initialPurchaseEnd,
    required this.onApply,
    required this.onReset,
    this.dismissSignal,
  });

  /// Convenience method to show the filter panel as a bottom sheet.
  /// 返回的 Future 在弹窗关闭时完成，调用方可据此感知关闭时机。
  static Future<void> show(
    BuildContext context, {
    String? initialPriceRange,
    String? initialLocation,
    String? initialStatus,
    String? initialBorrowedStatus,
    DateTime? initialPurchaseStart,
    DateTime? initialPurchaseEnd,
    required FilterApplyCallback onApply,
    required VoidCallback onReset,
    ValueListenable<int>? dismissSignal,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => FilterPanel(
        initialPriceRange: initialPriceRange,
        initialLocation: initialLocation,
        initialStatus: initialStatus,
        initialBorrowedStatus: initialBorrowedStatus,
        initialPurchaseStart: initialPurchaseStart,
        initialPurchaseEnd: initialPurchaseEnd,
        onApply: onApply,
        onReset: onReset,
        dismissSignal: dismissSignal,
      ),
    );
  }

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late String? _selectedPriceRange = widget.initialPriceRange;
  late String? _selectedLocation = widget.initialLocation;
  late String? _selectedStatus = widget.initialStatus;
  late String? _selectedBorrowedStatus = widget.initialBorrowedStatus;
  late DateTime? _purchaseStart = widget.initialPurchaseStart;
  late DateTime? _purchaseEnd = widget.initialPurchaseEnd;

  /// 收到关闭信号时，用弹窗自身 context 关闭自己。
  /// 此处 context 处于 showModalBottomSheet 创建的 modal route 内，
  /// Navigator.of(context) 必然命中承载该弹窗的导航器，pop 一定生效。
  void _onDismissSignal() {
    if (!mounted) return;
    final signal = widget.dismissSignal;
    if (signal != null && signal.value > 0) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.dismissSignal?.addListener(_onDismissSignal);
  }

  @override
  void dispose() {
    widget.dismissSignal?.removeListener(_onDismissSignal);
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _selectedPriceRange = null;
      _selectedLocation = null;
      _selectedStatus = null;
      _selectedBorrowedStatus = null;
      _purchaseStart = null;
      _purchaseEnd = null;
    });
    widget.onReset();
  }

  void _applyFilters() {
    Navigator.of(context).pop(); // close bottom sheet
    // 归一化：若起止均存在且开始晚于结束，自动交换，避免空结果
    DateTime? start = _purchaseStart;
    DateTime? end = _purchaseEnd;
    if (start != null && end != null && start.isAfter(end)) {
      final tmp = start;
      start = end;
      end = tmp;
    }
    widget.onApply(
      _selectedPriceRange,
      _selectedLocation,
      _selectedStatus,
      _selectedBorrowedStatus,
      start,
      end,
    );
  }

  /// 格式化为 yyyy-MM-dd（仅日期粒度，与物品 purchaseDate 比较口径一致）
  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime> onConfirm,
  }) async {
    await DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2000, 1, 1),
      maxTime: DateTime(2100, 12, 31),
      currentTime: current ?? DateTime.now(),
      locale: LocaleType.zh,
      onConfirm: onConfirm,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Header
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
            // Price range
            _buildFilterSection(
              label: '价格区间',
              options: ['不限', '¥0–100', '¥100–500', '¥500–2000', '¥2000以上'],
              selected: _selectedPriceRange,
              onSelect: (v) => setState(() => _selectedPriceRange = v),
            ),
            const SizedBox(height: 16),
            // Location
            _buildFilterSection(
              label: '收纳位置',
              options: ['全部', '客厅', '卧室', '书房', '厨房', '储物间'],
              selected: _selectedLocation,
              onSelect: (v) => setState(() => _selectedLocation = v),
            ),
            const SizedBox(height: 16),
            // Status（对齐真实数据：underWarranty / expiring / idle）
            _buildFilterSection(
              label: '物品状态',
              options: ['全部', '在保', '即将到期', '过保'],
              selected: _selectedStatus,
              onSelect: (v) => setState(() => _selectedStatus = v),
            ),
            const SizedBox(height: 16),
            // 借出状态
            _buildFilterSection(
              label: '借出状态',
              options: ['全部', '已借出', '可借出'],
              selected: _selectedBorrowedStatus,
              onSelect: (v) => setState(() => _selectedBorrowedStatus = v),
            ),
            const SizedBox(height: 16),
            // 购买时间区间
            _buildDateRangeSection(),
            const SizedBox(height: 8),
            // Confirm button
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
            // 默认（null）与重置后，首个「全部/不限」选项应显示为选中态，
            // 让用户直观看到当前未施加任何筛选。
            final isSelected = selected == null
                ? opt == options.first
                : selected == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentLightBg
                      : AppColors.background,
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

  /// 购买时间区间：开始/结束两个日期Tile，点击弹出日期选择器。
  /// 含「清除」链接一键重置两端；确认时自动归一化（开始≤结束）。
  Widget _buildDateRangeSection() {
    final hasAny = _purchaseStart != null || _purchaseEnd != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '购买时间',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            if (hasAny)
              GestureDetector(
                onTap: () => setState(() {
                  _purchaseStart = null;
                  _purchaseEnd = null;
                }),
                child: const Text(
                  '清除',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildDateTile(
                label: '开始',
                date: _purchaseStart,
                onPick: (d) => setState(() => _purchaseStart = d),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDateTile(
                label: '结束',
                date: _purchaseEnd,
                onPick: (d) => setState(() => _purchaseEnd = d),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTile({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onPick,
  }) {
    final hasValue = date != null;
    return GestureDetector(
      onTap: () => _pickDate(current: date, onConfirm: onPick),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: hasValue ? AppColors.accentLightBg : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event,
              size: 14,
              color: hasValue ? AppColors.accentGold : AppColors.textHint,
            ),
            const SizedBox(width: 6),
            Text(
              hasValue ? _fmtDate(date) : '$label日期',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasValue ? AppColors.accentGold : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
