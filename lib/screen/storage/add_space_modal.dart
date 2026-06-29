import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/toast_utils.dart';
import '../../widgets/app_dropdown_button.dart';
import '../../widgets/emoji_text.dart';
import '../../providers/storage_providers.dart';

/// 数据回调：用户在新增模态框点击确认时触发
typedef AddSpaceCallback =
    void Function({
      required String level,
      required String parentId,
      required String name,
      required String icon,
      int expectedItems,
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
  int _expectedItems = 1;
  // slot 级别专用：用户选择的房间 ID（用于级联筛选柜体）
  // 初始为 currentRoomId，若为空则等房间列表加载后取第一个
  String? _slotParentRoomId;

  // 预期物品数量输入控制器
  final TextEditingController _expectedItemsController =
      TextEditingController();
  final FocusNode _expectedItemsFocusNode = FocusNode();
  static const int _maxExpectedItems = 100;

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

  @override
  void initState() {
    super.initState();
    // 根据当前浏览层级自动设置默认值
    if (widget.currentLevel == 2 && widget.currentCabinetId != null) {
      _addLevel = 'slot';
      _parentId = widget.currentCabinetId!;
      _slotParentRoomId = widget.currentRoomId;
    } else if (widget.currentLevel == 1 && widget.currentRoomId != null) {
      _addLevel = 'cabinet';
      _parentId = widget.currentRoomId!;
    } else {
      _addLevel = 'room';
      _parentId = '';
    }

    // 初始化预期物品数量控制器
    _expectedItemsController.text = '$_expectedItems';
    _expectedItemsFocusNode.addListener(_onExpectedItemsFocusChange);
  }

  @override
  void dispose() {
    _expectedItemsController.dispose();
    _expectedItemsFocusNode.removeListener(_onExpectedItemsFocusChange);
    _expectedItemsFocusNode.dispose();
    super.dispose();
  }

  void _onExpectedItemsFocusChange() {
    // 当输入框失去焦点时，确认输入值
    if (!_expectedItemsFocusNode.hasFocus) {
      _confirmExpectedItemsInput();
    }
  }

  void _confirmExpectedItemsInput() {
    final text = _expectedItemsController.text;
    if (text.isEmpty) {
      // 如果输入为空，恢复为当前值
      _expectedItemsController.text = '$_expectedItems';
      return;
    }

    final value = int.tryParse(text);
    if (value == null) {
      // 如果输入不是数字，恢复为当前值
      _expectedItemsController.text = '$_expectedItems';
      ToastUtils.show(context, '请输入有效的数字');
      return;
    }

    // 验证范围
    if (value < 1) {
      _expectedItems = 1;
      _expectedItemsController.text = '$_expectedItems';
      ToastUtils.show(context, '数量不能小于1');
    } else if (value > _maxExpectedItems) {
      _expectedItems = _maxExpectedItems;
      _expectedItemsController.text = '$_expectedItems';
      ToastUtils.show(context, '数量不能大于$_maxExpectedItems');
    } else {
      _expectedItems = value;
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
      expectedItems: _expectedItems,
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
                      // 预期物品数（仅 slot 级别）
                      if (_addLevel == 'slot')
                        _buildFormRow('预期物品数', _buildExpectedItemsInput()),
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
    return AppDropdownButton<String>(
      value: _addLevel,
      items: const [
        DropdownOption('room', '房间'),
        DropdownOption('cabinet', '柜体'),
        DropdownOption('slot', '格子/区域'),
      ],
      onChanged: (v) {
        if (v == null) return;
        setState(() {
          _addLevel = v;
          // 切换层级时重置父级选择
          if (_addLevel == 'room') {
            _parentId = '';
            _slotParentRoomId = null;
          } else if (_addLevel == 'cabinet') {
            _parentId = widget.currentRoomId ?? '';
            _slotParentRoomId = null;
          } else {
            // slot：以当前浏览房间为默认，后续用户可改
            _slotParentRoomId = widget.currentRoomId;
            _parentId = widget.currentCabinetId ?? '';
          }
        });
      },
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
          final validId = rooms.any((r) => r.id == _parentId)
              ? _parentId
              : rooms.first.id;
          if (validId != _parentId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _parentId = validId);
            });
          }
          return _buildSelectFromList(
            items: rooms
                .map((r) => (id: r.id, label: '${r.emoji} ${r.name}'))
                .toList(),
            selectedId: validId,
            onChanged: (id) => setState(() => _parentId = id),
          );
        },
      );
    } else if (_addLevel == 'slot') {
      // 选择柜体作为格子的上级：级联「房间 → 柜体」
      // 用户可跨房间选择任意柜体作为父级
      return _buildSlotParentCascade();
    }
    return const SizedBox.shrink();
  }

  /// slot 级别的级联父级选择器：先选房间，再选该房间下的柜体。
  Widget _buildSlotParentCascade() {
    final roomsAsync = ref.watch(roomsProvider);
    return roomsAsync.when(
      loading: () => _buildLoadingSelect(),
      error: (e, _) => _buildErrorSelect(),
      data: (rooms) {
        if (rooms.isEmpty) {
          return _buildEmptyHint('请先添加房间');
        }
        // 初始化或校验所选房间
        var selectedRoom = _slotParentRoomId;
        if (selectedRoom == null || !rooms.any((r) => r.id == selectedRoom)) {
          selectedRoom = rooms.first.id;
          if (_slotParentRoomId != selectedRoom) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _slotParentRoomId = selectedRoom;
                _parentId = ''; // 房间变了，柜体待重选
              });
            });
          }
        }
        return _buildRoomCabinetCascade(
          rooms: rooms,
          selectedRoomId: selectedRoom,
        );
      },
    );
  }

  /// 渲染房间 + 柜体两个级联下拉，已选项带明确视觉标识。
  Widget _buildRoomCabinetCascade({
    required List<dynamic> rooms,
    required String selectedRoomId,
  }) {
    final cabinetsAsync = ref.watch(cabinetsByRoomProvider(selectedRoomId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 第一级：房间
        _buildLabeledSelect(
          label: '所在房间',
          items: rooms
              .map((r) => (id: r.id as String, label: '${r.emoji} ${r.name}'))
              .toList(),
          selectedId: selectedRoomId,
          onChanged: (id) {
            setState(() {
              _slotParentRoomId = id;
              _parentId = ''; // 重置柜体选择
            });
          },
        ),
        const SizedBox(height: 10),
        // 第二级：柜体（依赖所选房间）
        cabinetsAsync.when(
          loading: () => _buildLoadingSelect(),
          error: (e, _) => _buildErrorSelect(),
          data: (cabinets) {
            if (cabinets.isEmpty) {
              return _buildEmptyHint('该房间暂无柜体，请先添加');
            }
            final validId = cabinets.any((c) => c.id == _parentId)
                ? _parentId
                : cabinets.first.id;
            if (validId != _parentId) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() => _parentId = validId);
              });
            }
            return _buildLabeledSelect(
              label: '所属柜体',
              items: cabinets
                  .map((c) => (id: c.id, label: '${c.emoji} ${c.name}'))
                  .toList(),
              selectedId: validId,
              onChanged: (id) => setState(() => _parentId = id),
              highlight: true, // 最终父级高亮标识
            );
          },
        ),
      ],
    );
  }

  /// 带小标题的下拉选择器，[highlight] 为 true 时给选中项加金色边框。
  Widget _buildLabeledSelect({
    required String label,
    required List<({String id, String label})> items,
    required String selectedId,
    required ValueChanged<String> onChanged,
    bool highlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: highlight
                    ? AppColors.accentGold
                    : AppColors.textSecondary,
              ),
            ),
            if (highlight)
              const Text(
                ' · 已选定',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        _buildSelectFromList(
          items: items,
          selectedId: selectedId,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSelectFromList({
    required List<({String id, String label})> items,
    required String selectedId,
    required ValueChanged<String> onChanged,
  }) {
    return AppDropdownButton<String>(
      value: selectedId,
      items: items
          .map((item) => DropdownOption<String>(item.id, item.label))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
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
            child: Center(child: EmojiText(emoji: icon, fontSize: 24)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpectedItemsInput() {
    return Row(
      children: [
        _buildStepButton(
          icon: Icons.remove,
          onTap: () {
            if (_expectedItems > 1) {
              setState(() {
                _expectedItems--;
                _expectedItemsController.text = '$_expectedItems';
              });
            }
          },
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0E4D0), width: 1.5),
            ),
            child: TextField(
              controller: _expectedItemsController,
              focusNode: _expectedItemsFocusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 11),
                isDense: true,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                // 实时验证输入
                if (value.isNotEmpty) {
                  final intValue = int.tryParse(value);
                  if (intValue != null) {
                    if (intValue >= 1 && intValue <= _maxExpectedItems) {
                      _expectedItems = intValue;
                    }
                  }
                }
              },
              onSubmitted: (value) {
                // 按下回车键时确认输入
                _confirmExpectedItemsInput();
              },
            ),
          ),
        ),
        _buildStepButton(
          icon: Icons.add,
          onTap: () {
            if (_expectedItems < _maxExpectedItems) {
              setState(() {
                _expectedItems++;
                _expectedItemsController.text = '$_expectedItems';
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.accentGold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accentGold, width: 1.5),
        ),
        child: Icon(icon, size: 20, color: AppColors.accentGold),
      ),
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
