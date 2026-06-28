import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/emoji_text.dart';
import '../../widgets/toast_utils.dart';

/// 编辑回调：用户点击确认时触发，传入新的名称和图标
typedef EditSpaceCallback =
    void Function({required String name, required String icon});

/// 编辑收纳空间模态框（房间/柜体/格子通用，仅编辑名称和图标）
class EditSpaceModal extends StatefulWidget {
  final String title;
  final String initialName;
  final String initialIcon;
  final List<String> iconOptions;
  final VoidCallback onClose;
  final EditSpaceCallback onConfirm;

  const EditSpaceModal({
    super.key,
    required this.title,
    required this.initialName,
    required this.initialIcon,
    required this.iconOptions,
    required this.onClose,
    required this.onConfirm,
  });

  @override
  State<EditSpaceModal> createState() => _EditSpaceModalState();
}

class _EditSpaceModalState extends State<EditSpaceModal> {
  late TextEditingController _nameController;
  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedIcon = widget.initialIcon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ToastUtils.show(context, '请填写名称');
      return;
    }
    widget.onConfirm(name: name, icon: _selectedIcon);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: GestureDetector(
            onTap: () {},
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
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
                            widget.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onClose,
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
                      // 名称输入
                      const Text(
                        '名称',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.accentGold,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 图标选择
                      const Text(
                        '图标',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.iconOptions.map((icon) {
                          final isSelected = icon == _selectedIcon;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedIcon = icon),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accentGold.withValues(alpha: 0.15)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accentGold
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: EmojiText(emoji: icon, fontSize: 22),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 22),
                      // 确认按钮
                      GestureDetector(
                        onTap: _save,
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
                                color: const Color(0x4DFFB800),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '保存',
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
}
