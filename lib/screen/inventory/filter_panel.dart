import 'package:flutter/material.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/constants/app_dimensions.dart';

/// Callback signature for when filters are applied.
typedef FilterApplyCallback = void Function(
  String? priceRange,
  String? location,
  String? status,
);

/// Standalone filter panel shown as a modal bottom sheet.
class FilterPanel extends StatefulWidget {
  final String? initialPriceRange;
  final String? initialLocation;
  final String? initialStatus;
  final FilterApplyCallback onApply;
  final VoidCallback onReset;

  const FilterPanel({
    super.key,
    this.initialPriceRange,
    this.initialLocation,
    this.initialStatus,
    required this.onApply,
    required this.onReset,
  });

  /// Convenience method to show the filter panel as a bottom sheet.
  static void show(
    BuildContext context, {
    String? initialPriceRange,
    String? initialLocation,
    String? initialStatus,
    required FilterApplyCallback onApply,
    required VoidCallback onReset,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => FilterPanel(
        initialPriceRange: initialPriceRange,
        initialLocation: initialLocation,
        initialStatus: initialStatus,
        onApply: onApply,
        onReset: onReset,
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

  void _resetFilters() {
    setState(() {
      _selectedPriceRange = null;
      _selectedLocation = null;
      _selectedStatus = null;
    });
    widget.onReset();
  }

  void _applyFilters() {
    Navigator.of(context).pop(); // close bottom sheet
    widget.onApply(_selectedPriceRange, _selectedLocation, _selectedStatus);
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
            final isSelected = selected == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.accentLightBg : AppColors.background,
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
