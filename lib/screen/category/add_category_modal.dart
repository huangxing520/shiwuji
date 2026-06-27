import 'package:flutter/material.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';

/// 分类编辑回调
typedef CategoryModalCallback = void Function({
  required String label,
  required String emoji,
});

/// 新增/编辑分类模态框
class AddCategoryModal extends StatefulWidget {
  final VoidCallback onClose;
  final CategoryModalCallback onConfirm;

  /// 编辑模式：传入现有值
  final String? editLabel;
  final String? editEmoji;
  final String title;

  const AddCategoryModal({
    super.key,
    required this.onClose,
    required this.onConfirm,
    this.editLabel,
    this.editEmoji,
    this.title = '新增分类',
  });

  @override
  State<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends State<AddCategoryModal> {
  late String _label;
  late String _emoji;
  late TextEditingController _controller;

  static const _emojiOptions = [
    '📱', '🏠', '💄', '🍚', '👔', '📚', '📦', '🧸',
    '🏋️', '🎨', '🔑', '🔧', '🎮', '🎧', '💻', '📷',
    '🍳', '🧹', '👟', '👜', '💊', '🎵', '🧴', '🪴',
    '🐾', '🚗', '✈️', '🎁', '🏺', '🕯️', '🪑', '🛁',
  ];

  @override
  void initState() {
    super.initState();
    _label = widget.editLabel ?? '';
    _emoji = widget.editEmoji ?? '📦';
    _controller = TextEditingController(text: _label);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_label.trim().isEmpty) {
      ToastUtils.show(context, '请填写分类名称');
      return;
    }
    widget.onConfirm(label: _label.trim(), emoji: _emoji);
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
                constraints: const BoxConstraints(maxHeight: 520),
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
                      _buildHeader(),
                      const SizedBox(height: 18),
                      _buildEmojiGrid(),
                      const SizedBox(height: 16),
                      _buildLabelInput(),
                      const SizedBox(height: 20),
                      _buildConfirmButton(),
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

  Widget _buildHeader() {
    return Row(
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
            child: const Icon(Icons.close, size: 16, color: AppColors.textHint),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择图标',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _emojiOptions.map((icon) {
            final isSelected = icon == _emoji;
            return GestureDetector(
              onTap: () => setState(() => _emoji = icon),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFF3CC) : AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.accentGold : const Color(0xFFF0E4D0),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLabelInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '分类名称',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(fontSize: 10, color: AppColors.danger),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: '例如：美妆、户外、宠物',
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
          onChanged: (v) => _label = v,
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
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
              color: const Color(0x40FFB800),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.editLabel != null ? '保存修改' : '确认添加',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
