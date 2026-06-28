/// 项目统一的下拉框组件。
///
/// 基于 `dropdown_button2` 封装，遵循项目设计规范：
/// - 8px 圆角边框
/// - 内边距 `EdgeInsets.symmetric(horizontal: 12, vertical: 8)`
/// - 选中项在菜单内以金色加粗 + 对勾标识
/// - 颜色、字号、交互反馈全局一致
///
/// 使用方式：
/// ```dart
/// AppDropdownButton<String>(
///   value: _level,
///   items: const [
///     DropdownOption('room', '房间'),
///     DropdownOption('cabinet', '柜体'),
///   ],
///   onChanged: (v) => setState(() => _level = v),
/// );
/// ```
library;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// 单个下拉选项：把任意类型的值与可显示文本绑定。
class DropdownOption<T> {
  final T value;
  final String label;
  const DropdownOption(this.value, this.label);
}

/// 统一下拉框。
///
/// 内部以 [ValueNotifier] 维护当前选中值，自动同步外部 [value]，
/// 因此调用方仍可使用传统的 setState 模式，无需感知 dropdown_button2 3.x 的破坏性变更。
class AppDropdownButton<T> extends StatefulWidget {
  const AppDropdownButton({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.disabled = false,
    this.isExpanded = true,
  });

  /// 选项列表。
  final List<DropdownOption<T>> items;

  /// 当前选中值。若不在 [items] 中则视为未选中并显示 [hint]。
  final T? value;

  /// 选项变更回调（不会传 null，除非 [items] 为空）。
  final ValueChanged<T?> onChanged;

  /// 占位提示。
  final Widget? hint;

  /// 是否禁用。
  final bool disabled;

  /// 是否撑满父级宽度。
  final bool isExpanded;

  @override
  State<AppDropdownButton<T>> createState() => _AppDropdownButtonState<T>();
}

class _AppDropdownButtonState<T> extends State<AppDropdownButton<T>> {
  late final ValueNotifier<T?> _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier<T?>(widget.value);
  }

  @override
  void didUpdateWidget(covariant AppDropdownButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部 value 变化时同步到内部 notifier
    if (oldWidget.value != widget.value && _notifier.value != widget.value) {
      _notifier.value = widget.value;
    }
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled || widget.items.isEmpty;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        isExpanded: widget.isExpanded,
        valueListenable: _notifier,
        hint:
            widget.hint ??
            Text(
              '请选择',
              style: TextStyle(fontSize: 14, color: AppColors.textHint),
            ),
        disabledHint: widget.hint,
        items: widget.items
            .map(
              (opt) => DropdownItem<T>(
                value: opt.value,
                height: 44,
                child: ValueListenableBuilder<T?>(
                  valueListenable: _notifier,
                  builder: (context, selected, _) {
                    final isSelected = selected == opt.value;
                    return Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_rounded : null,
                          size: 16,
                          color: AppColors.accentGold,
                        ).visibility(visible: isSelected),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            opt.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.accentGold
                                  : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            )
            .toList(),
        // 选项之间的分隔符：1px 高的浅色细线，自动插入到每两个 item 之间
        dropdownSeparator: DropdownSeparator<T>(
          height: 1,
          child: const Divider(
            height: 1,
            thickness: 0.5,
            color: AppColors.divider,
          ),
        ),
        onChanged: isDisabled
            ? null
            : (v) {
                _notifier.value = v;
                widget.onChanged(v);
              },
        buttonStyleData: ButtonStyleData(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
        ),
        iconStyleData: IconStyleData(
          icon: Icon(
            Icons.expand_more_rounded,
            size: 18,
            color: isDisabled ? AppColors.textHint : AppColors.textSecondary,
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 280,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(8),
            thickness: WidgetStateProperty.all<double>(4),
            thumbVisibility: WidgetStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          overlayColor: WidgetStatePropertyAll<Color?>(AppColors.primaryLight),
        ),
      ),
    );
  }
}

/// 为 [Icon] 增加 visibility 切换的便捷扩展：当 [visible] 为 false 时
/// 返回 0×0 的占位，避免影响 Row 布局。
extension _IconVisibility on Icon {
  Widget visibility({required bool visible}) {
    if (visible) return this;
    return const SizedBox(width: 16, height: 16);
  }
}
