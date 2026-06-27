import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/toast_utils.dart';
import '../../providers/storage_providers.dart';

/// 数据回调：用户在新增模态框点击确认时触发
typedef AddSpaceCallback = void Function({
  required String level,
  required String parentId,
  required String name,
  required String icon,
});

/// 新增收纳空间模态框
class AddSpaceModal extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final AddSpaceCallback onConfirm;

  /// 当前浏览层级，用于默认选中
  final int currentLevel;
  final String? currentRoomId;
  final String? currentCabinetId;

  const AddSpaceModal({
    super.key,
    required this.onClose,
    required this.onConfirm,
    this.currentLevel = 0,
    this.currentRoomId,
    this.currentCabinetId,
  });

  @override
  ConsumerState<AddSpaceModal> createState() => _AddSpaceModalState();
}

class _AddSpaceModalState extends ConsumerState<AddSpaceModal> {
  late String _addLevel;
  late String _parentId; // 实际 ID（room id 或 cabinet id）
  String _addName = '';
  String _selectedIcon = '🛋️';

  final List<String> _iconOptions = [
    '🛋️', '🛏️', '📚', '🍳', '🗄️', '📺',
    '👔', '💄', '💡', '📦', '🖥️', '🔌',
    '🔧', '🧹', '🚪', '🧒', '🌱', '🚗',
  ];

  @override
  void initState() {
    super.initState();
    // 根据当前浏览层级自动设置默认值
    if (widget.currentLevel == 2 && widget.currentCabinetId != null) {
      _addLevel = 'slot';
      _parentId = widget.currentCabinetId!;
    } else if (widget.currentLevel == 1 && widget.currentRoomId != null) {
      _addLevel = 'cabinet';
      _parentId = widget.currentRoomId!;
    } else {
      _addLevel = 'room';
      _parentId = '';
    }
  }

  void _save() {
    if (_addName.isEmpty) {
      ToastUtils.show(context, '请填写名称');
      return;
    }
    if (_addLevel != 'room' && _parentId.isEmpty) {
      ToastUtils.show(context, '请选择上级空间');
      return;
    }
    widget.onConfirm(
      level: _addLevel,
      parentId: _parentId,
      name: _addName,
      icon: _selectedIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose,
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
                      // 所属层级
                      _buildFormRow('所属层级', _buildLevelSelect()),
                      // 上级空间（仅非 room 级别时显示）
                      if (_addLevel != 'room')
                        _buildFormRow('上级空间', _buildDynamicParentSelect()),
                      // 空间名称
                      _buildFormRow('空间名称', _buildNameInput(), required: true),
                      // 选择图标
                      _buildFormRow('选择图标', _buildIconGrid()),
                      // 上传实景图
                      _buildFormRow('上传实景图', _buildPhotoUpload()),
                      const SizedBox(height: 6),
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
          onChanged: (v) {
            setState(() {
              _addLevel = v!;
              // 切换层级时重置父级选择
              if (_addLevel == 'room') {
                _parentId = '';
              } else if (_addLevel == 'cabinet') {
                _parentId = widget.currentRoomId ?? '';
              } else {
                _parentId = widget.currentCabinetId ?? '';
              }
            });
          },
        ),
      ),
    );
  }

  /// 动态父级选择器 — 从 providers 读取房间/柜体数据
  Widget _buildDynamicParentSelect() {
    if (_addLevel == 'cabinet') {
      // 选择房间作为柜体的上级
      final roomsAsync = ref.watch(roomsProvider);
      return roomsAsync.when(
        loading: () => _buildLoadingSelect(),
        error: (e, _) => _buildErrorSelect(),
        data: (rooms) {
          if (rooms.isEmpty) {
            return _buildEmptyHint('请先添加房间');
          }
          // 确保当前 parentId 在列表中
          final validId = rooms.any((r) => r.id == _parentId) ? _parentId : rooms.first.id;
          if (validId != _parentId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _parentId = validId);
            });
          }
          return _buildSelectFromList(
            items: rooms.map((r) => (id: r.id, label: '${r.emoji} ${r.name}')).toList(),
            selectedId: validId,
            onChanged: (id) => setState(() => _parentId = id),
          );
        },
      );
    } else if (_addLevel == 'slot') {
      // 选择柜体作为格子的上级
      if (widget.currentRoomId == null) {
        return _buildEmptyHint('请先选择房间');
      }
      final cabinetsAsync = ref.watch(cabinetsByRoomProvider(widget.currentRoomId!));
      return cabinetsAsync.when(
        loading: () => _buildLoadingSelect(),
        error: (e, _) => _buildErrorSelect(),
        data: (cabinets) {
          if (cabinets.isEmpty) {
            return _buildEmptyHint('该房间暂无柜体，请先添加');
          }
          final validId = cabinets.any((c) => c.id == _parentId) ? _parentId : cabinets.first.id;
          if (validId != _parentId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _parentId = validId);
            });
          }
          return _buildSelectFromList(
            items: cabinets.map((c) => (id: c.id, label: '${c.emoji} ${c.name}')).toList(),
            selectedId: validId,
            onChanged: (id) => setState(() => _parentId = id),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSelectFromList({
    required List<({String id, String label})> items,
    required String selectedId,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0E4D0), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item.id,
                    child: Text(item.label),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSelect() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorSelect() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '加载失败',
        style: TextStyle(color: AppColors.danger, fontSize: 13),
      ),
    );
  }

  Widget _buildEmptyHint(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        hint,
        style: const TextStyle(color: AppColors.textHint, fontSize: 13),
      ),
    );
  }

  Widget _buildNameInput() {
    return TextField(
      decoration: InputDecoration(
        hintText: _addLevel == 'room'
            ? '例如：客厅、卧室'
            : _addLevel == 'cabinet'
                ? '例如：电视柜、衣柜'
                : '例如：上层隔板、抽屉',
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
}
