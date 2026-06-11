import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ==================== 颜色常量 ====================
class AppColors {
  static const Color bg = Color(0xFFFFF8E7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color fg = Color(0xFF3D2B1F);
  static const Color fgSecondary = Color(0xFF7A6555);
  static const Color muted = Color(0xFFB8A48E);
  static const Color border = Color(0xFFF0E4D0);
  static const Color accent = Color(0xFFFFB800);
  static const Color accentLight = Color(0xFFFFE066);
  static const Color accentDark = Color(0xFFE5A500);
  static const Color orange = Color(0xFFFF8C42);
  static const Color orangeLight = Color(0xFFFFD4B8);
  static const Color green = Color(0xFF6BCB77);
  static const Color greenLight = Color(0xFFD4F5D9);
  static const Color red = Color(0xFFFF6B6B);
  static const Color redLight = Color(0xFFFFD4D4);
  static const Color blue = Color(0xFF5B9BFF);
  static const Color blueLight = Color(0xFFD4E8FF);
  static const Color purple = Color(0xFF9B7BFF);
  static const Color purpleLight = Color(0xFFE4DAFF);
}

// ==================== 数据模型 ====================
class TemplateField {
  final String label;
  final String placeholder;
  final String id;
  final bool isDate;

  const TemplateField({
    required this.label,
    required this.placeholder,
    required this.id,
    this.isDate = false,
  });
}

class TemplateData {
  final String name;
  final List<TemplateField> fields;

  const TemplateData({required this.name, required this.fields});
}

class PickerItem {
  final String emoji;
  final String name;

  const PickerItem({required this.emoji, required this.name});
}

// ==================== 模板 & 选择器数据 ====================
const Map<String, TemplateData?> templateFieldsMap = {
  'none': null,
  'digital': TemplateData(
    name: '数码专属属性',
    fields: [
      TemplateField(label: '型号', placeholder: '例如：A2696', id: 'tplModel'),
      TemplateField(label: '序列号/IMEI', placeholder: '设备唯一标识', id: 'tplSerial'),
      TemplateField(label: '存储容量', placeholder: '例如：256GB', id: 'tplStorage'),
      TemplateField(label: '购买渠道', placeholder: '例如：官网/授权店', id: 'tplChannel'),
    ],
  ),
  'beauty': TemplateData(
    name: '美妆专属属性',
    fields: [
      TemplateField(label: '色号/规格', placeholder: '例如：#23 Ivory', id: 'tplShade'),
      TemplateField(label: '生产批号', placeholder: '瓶身标注的批号', id: 'tplBatch'),
      TemplateField(label: '开盖日期', placeholder: '首次开封使用日期', id: 'tplOpenDate', isDate: true),
      TemplateField(label: '开封保质期', placeholder: '例如：12M', id: 'tplPAO'),
    ],
  ),
  'clothing': TemplateData(
    name: '服饰专属属性',
    fields: [
      TemplateField(label: '尺码', placeholder: '例如：M / 170/92A', id: 'tplSize'),
      TemplateField(label: '材质', placeholder: '例如：100%棉', id: 'tplMaterial'),
      TemplateField(label: '颜色', placeholder: '例如：藏青色', id: 'tplColor'),
      TemplateField(label: '季节', placeholder: '例如：春夏', id: 'tplSeason'),
    ],
  ),
  'food': TemplateData(
    name: '食品专属属性',
    fields: [
      TemplateField(label: '净含量', placeholder: '例如：500g', id: 'tplWeight'),
      TemplateField(label: '生产日期', placeholder: '', id: 'tplProdDate', isDate: true),
      TemplateField(label: '保质期', placeholder: '例如：12个月', id: 'tplShelfLife'),
      TemplateField(label: '存储条件', placeholder: '例如：阴凉干燥处', id: 'tplStorage2'),
    ],
  ),
  'book': TemplateData(
    name: '书籍专属属性',
    fields: [
      TemplateField(label: '作者', placeholder: '例如：原研哉', id: 'tplAuthor'),
      TemplateField(label: '出版社', placeholder: '例如：山东人民出版社', id: 'tplPublisher'),
      TemplateField(label: 'ISBN', placeholder: '国际标准书号', id: 'tplISBN'),
      TemplateField(label: '版本', placeholder: '例如：第一版', id: 'tplEdition'),
    ],
  ),
};

const List<Map<String, String>> templateCards = [
  {'key': 'none', 'emoji': '📝', 'name': '通用'},
  {'key': 'digital', 'emoji': '📱', 'name': '数码'},
  {'key': 'beauty', 'emoji': '💄', 'name': '美妆'},
  {'key': 'clothing', 'emoji': '👔', 'name': '服饰'},
  {'key': 'food', 'emoji': '🍜', 'name': '食品'},
  {'key': 'book', 'emoji': '📚', 'name': '书籍'},
];

const List<String> sourceOptions = ['线下购买', '亲友赠送', '二手收购', '闲置已有', '其他'];

const List<PickerItem> categoryData = [
  PickerItem(emoji: '📱', name: '数码'),
  PickerItem(emoji: '🏠', name: '家电'),
  PickerItem(emoji: '💄', name: '护肤'),
  PickerItem(emoji: '🍚', name: '厨房'),
  PickerItem(emoji: '👔', name: '衣物'),
  PickerItem(emoji: '📚', name: '书籍'),
  PickerItem(emoji: '📦', name: '收纳'),
  PickerItem(emoji: '🧸', name: '玩具'),
  PickerItem(emoji: '🏋️', name: '运动'),
  PickerItem(emoji: '🎨', name: '文具'),
  PickerItem(emoji: '🔑', name: '钥匙'),
  PickerItem(emoji: '🔧', name: '工具'),
];

const List<PickerItem> locationData = [
  PickerItem(emoji: '🛋️', name: '客厅'),
  PickerItem(emoji: '🛏️', name: '卧室'),
  PickerItem(emoji: '📚', name: '书房'),
  PickerItem(emoji: '🍳', name: '厨房'),
  PickerItem(emoji: '🚿', name: '浴室'),
  PickerItem(emoji: '🗄️', name: '储物间'),
  PickerItem(emoji: '🚪', name: '玄关'),
  PickerItem(emoji: '🧒', name: '儿童房'),
  PickerItem(emoji: '♿', name: '阳台'),
  PickerItem(emoji: '🚗', name: '车里'),
  PickerItem(emoji: '🏢', name: '办公室'),
  PickerItem(emoji: '🎒', name: '随身包'),
];

// ==================== 主页面 ====================
class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> with TickerProviderStateMixin {
  // 表单控制器
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  final _buyDateController = TextEditingController();
  final _scrollController = ScrollController();

  // 模板字段控制器
  final Map<String, TextEditingController> _tplControllers = {};

  // 照片（模拟用 emoji + 颜色替代）
  final List<_PhotoData> _photos = [];
  static const _photoEmojis = ['📷', '🖼️', '📸', '🏞️', '🏠', '✨'];
  static const _photoColors = [
    Color(0xFFFFE8CC), Color(0xFFE8F5E9), Color(0xFFE3F2FD),
    Color(0xFFF3E5F5), Color(0xFFFFF9C4), Color(0xFFFFEBEE),
  ];

  // 状态
  String _selectedTemplate = 'none';
  String _selectedSource = '线下购买';
  String? _selectedCategory;
  String? _selectedLocation;

  // 提醒开关
  bool _expiryOn = false;
  bool _warrantyOn = false;
  bool _maintainOn = false;
  String _maintainCycle = '每半年';

  // 日期
  DateTime? _expiryDate;
  DateTime? _warrantyDate;
  final _expiryDateController = TextEditingController();
  final _warrantyDateController = TextEditingController();

  // 成功弹窗
  bool _showSuccess = false;
  String _successTitle = '保存成功！';
  String _successSub = '';
  String _successBtnText = '好的';
  VoidCallback? _successBtnAction;

  // 动画
  late AnimationController _templateFieldsAnimController;
  late Animation<double> _templateFieldsAnim;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _buyDateController.text =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    _templateFieldsAnimController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _templateFieldsAnim = CurvedAnimation(
      parent: _templateFieldsAnimController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    _buyDateController.dispose();
    _expiryDateController.dispose();
    _warrantyDateController.dispose();
    _scrollController.dispose();
    for (final c in _tplControllers.values) {
      c.dispose();
    }
    _templateFieldsAnimController.dispose();
    super.dispose();
  }

  // ==================== Toast ====================
  void _showToast(String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.fg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.only(top: 60, left: 80, right: 80, bottom: 700),
      ),
    );
  }

  // ==================== 照片操作 ====================
  void _addPhoto() {
    if (_photos.length >= 6) {
      _showToast('最多上传6张照片');
      return;
    }
    setState(() {
      final idx = _photos.length;
      _photos.add(_PhotoData(
        emoji: _photoEmojis[idx % _photoEmojis.length],
        color: _photoColors[idx % _photoColors.length],
      ));
    });
    _showToast('图片已添加（模拟）');
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  // ==================== 模板选择 ====================
  void _selectTemplate(String key) {
    setState(() {
      _selectedTemplate = key;
      // 清理旧的模板控制器
      for (final c in _tplControllers.values) {
        c.dispose();
      }
      _tplControllers.clear();
    });

    final data = templateFieldsMap[key];
    if (key == 'none' || data == null) {
      _templateFieldsAnimController.reverse();
    } else {
      for (final f in data.fields) {
        _tplControllers[f.id] = TextEditingController();
      }
      _templateFieldsAnimController.forward();
      _showToast('已切换到${data.name.replaceAll('专属属性', '')}模板');
    }
  }

  // ==================== 选择器 ====================
  void _openPicker({required bool isCategory}) {
    final data = isCategory ? categoryData : locationData;
    final currentSelected = isCategory ? _selectedCategory : _selectedLocation;
    final title = isCategory ? '选择分类' : '选择收纳位置';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PickerSheet(
        title: title,
        items: data,
        selectedName: currentSelected,
        onPick: (name) {
          setState(() {
            if (isCategory) {
              _selectedCategory = name;
            } else {
              _selectedLocation = name;
            }
          });
          Navigator.pop(ctx);
          _showToast('已选择：$name');
        },
      ),
    );
  }

  // ==================== 日期选择 ====================
  Future<void> _pickDate(TextEditingController controller, {void Function(DateTime)? onPicked}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.accent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      onPicked?.call(picked);
    }
  }

  // ==================== 保存 ====================
  void _saveItem(bool andContinue) {
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();

    if (name.isEmpty) {
      _showToast('请填写物品名称');
      FocusScope.of(context).unfocus();
      return;
    }
    if (price.isEmpty) {
      _showToast('请填写购买价格');
      FocusScope.of(context).unfocus();
      return;
    }

    if (andContinue) {
      _successTitle = '已保存！';
      _successSub = '「$name」已入库，继续添加下一件吧';
      _successBtnText = '继续新增';
      _successBtnAction = () {
        setState(() => _showSuccess = false);
        _resetForm();
      };
    } else {
      _successTitle = '保存成功！';
      _successSub = '「$name」已添加到你的物品库';
      _successBtnText = '好的';
      _successBtnAction = () {
        setState(() => _showSuccess = false);
      };
    }

    setState(() => _showSuccess = true);
  }

  void _resetForm() {
    _nameController.clear();
    _brandController.clear();
    _priceController.clear();
    _noteController.clear();
    _expiryDateController.clear();
    _warrantyDateController.clear();
    final today = DateTime.now();
    _buyDateController.text =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    setState(() {
      _selectedTemplate = 'none';
      _selectedSource = '线下购买';
      _selectedCategory = null;
      _selectedLocation = null;
      _expiryOn = false;
      _warrantyOn = false;
      _maintainOn = false;
      _maintainCycle = '每半年';
      _expiryDate = null;
      _warrantyDate = null;
      _photos.clear();

      for (final c in _tplControllers.values) {
        c.dispose();
      }
      _tplControllers.clear();
    });
    _templateFieldsAnimController.reverse();
    _scrollController.jumpTo(0);
    _showToast('表单已重置，继续添加 💪');
  }

  // ==================== Build ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // 主内容
          Column(
            children: [
              // 状态栏占位
              SizedBox(height: MediaQuery.of(context).padding.top),
              // 顶部导航
              _buildTopBar(),
              // 滚动区域
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildPhotoSection(),
                      const SizedBox(height: 16),
                      _buildTemplateSection(),
                      const SizedBox(height: 8),
                      _buildTemplateFields(),
                      const SizedBox(height: 8),
                      _buildBasicInfoSection(),
                      const SizedBox(height: 12),
                      _buildCategoryLocationSection(),
                      const SizedBox(height: 12),
                      _buildReminderSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 底部按钮
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomActions(),
          ),
          // 成功弹窗
          if (_showSuccess) _buildSuccessOverlay(),
        ],
      ),
    );
  }

  // ==================== 顶部导航 ====================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.fg.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 20,
                color: AppColors.fgSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '新增物品',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.fg,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 照片区域 ====================
  Widget _buildPhotoSection() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _photos.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == _photos.length) {
            // 添加按钮
            return GestureDetector(
              onTap: _addPhoto,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border, width: 2.5, strokeAlign: BorderSide.strokeAlignInside),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 28, color: AppColors.muted),
                    const SizedBox(height: 6),
                    const Text(
                      '添加照片',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            );
          }
          // 照片缩略图
          final photo = _photos[index];
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: AppColors.fg.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // 模拟图片
                Container(
                  color: photo.color,
                  child: Center(
                    child: Text(photo.emoji, style: const TextStyle(fontSize: 36)),
                  ),
                ),
                // 删除按钮
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removePhoto(index),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                    ),
                  ),
                ),
                // 封面标签
                if (index == 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.accent, AppColors.orange],
                        ),
                      ),
                      child: const Text(
                        '封面',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== 品类模板 ====================
  Widget _buildTemplateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.grid_view, size: 14, color: AppColors.accentDark),
            const SizedBox(width: 6),
            const Text(
              '品类模板 · 一键匹配专属属性',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.fgSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: templateCards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final card = templateCards[index];
              final key = card['key']!;
              final isSelected = _selectedTemplate == key;
              return GestureDetector(
                onTap: () => _selectTemplate(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFF3CC) : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.accent.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4))]
                        : [BoxShadow(color: AppColors.fg.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(card['emoji']!, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        card['name']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.accentDark : AppColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== 模板专属字段 ====================
  Widget _buildTemplateFields() {
    final data = templateFieldsMap[_selectedTemplate];
    if (_selectedTemplate == 'none' || data == null) {
      return const SizedBox.shrink();
    }

    return SizeTransition(
      sizeFactor: _templateFieldsAnim,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: _templateFieldsAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: AppColors.accentDark),
                  const SizedBox(width: 6),
                  Text(
                    data.name,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accentDark),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 2列网格
              ...List.generate(
                (data.fields.length / 2).ceil(),
                (row) => Padding(
                  padding: EdgeInsets.only(top: row > 0 ? 10 : 0),
                  child: Row(
                    children: List.generate(
                      2,
                      (col) {
                        final fieldIdx = row * 2 + col;
                        if (fieldIdx >= data.fields.length) {
                          return const Expanded(child: SizedBox());
                        }
                        final field = data.fields[fieldIdx];
                        final ctrl = _tplControllers[field.id]!;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: col > 0 ? 5 : 0, right: col > 0 ? 0 : 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    field.label,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.fgSecondary,
                                    ),
                                  ),
                                ),
                                _buildInput(
                                  controller: ctrl,
                                  placeholder: field.placeholder,
                                  fontSize: 13,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                  onTap: field.isDate
                                      ? () => _pickDate(ctrl)
                                      : null,
                                  readOnly: field.isDate,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 基本信息 ====================
  Widget _buildBasicInfoSection() {
    return _FormCard(
      icon: Icons.edit,
      title: '基本信息',
      children: [
        // 物品名称
        _buildLabel('物品名称', required: true),
        const SizedBox(height: 6),
        _buildInput(controller: _nameController, placeholder: '例如：AirPods Pro 2'),
        const SizedBox(height: 14),
        // 品牌
        _buildLabel('品牌'),
        const SizedBox(height: 6),
        _buildInput(controller: _brandController, placeholder: '例如：Apple'),
        const SizedBox(height: 14),
        // 购买价格 & 购买时间
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('购买价格', required: true),
                  const SizedBox(height: 6),
                  _buildInput(
                    controller: _priceController,
                    placeholder: '¥0.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('购买时间'),
                  const SizedBox(height: 6),
                  _buildInput(
                    controller: _buyDateController,
                    placeholder: '选择日期',
                    readOnly: true,
                    onTap: () => _pickDate(_buyDateController),
                    suffix: Icon(Icons.expand_more, size: 14, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // 物品来源
        _buildLabel('物品来源'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sourceOptions.map((source) {
            final isSelected = _selectedSource == source;
            return GestureDetector(
              onTap: () => setState(() => _selectedSource = source),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFF3CC) : AppColors.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  source,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.accentDark : AppColors.fgSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ==================== 归属信息 ====================
  Widget _buildCategoryLocationSection() {
    return _FormCard(
      icon: Icons.inventory_2_outlined,
      title: '归属信息',
      children: [
        Row(
          children: [
            // 物品分类
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('物品分类'),
                  const SizedBox(height: 6),
                  _buildSelectTrigger(
                    text: _selectedCategory ?? '选择分类',
                    hasValue: _selectedCategory != null,
                    onTap: () => _openPicker(isCategory: true),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // 收纳位置
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('收纳位置'),
                  const SizedBox(height: 6),
                  _buildSelectTrigger(
                    text: _selectedLocation ?? '选择位置',
                    hasValue: _selectedLocation != null,
                    onTap: () => _openPicker(isCategory: false),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // 备注
        _buildLabel('备注'),
        const SizedBox(height: 6),
        _buildInput(
          controller: _noteController,
          placeholder: '记录一些补充信息…',
          maxLines: 2,
        ),
      ],
    );
  }

  // ==================== 智能提醒 ====================
  Widget _buildReminderSection() {
    return _FormCard(
      icon: Icons.notifications_outlined,
      title: '智能提醒',
      children: [
        // 保质期提醒
        _buildReminderRow(
          title: '保质期提醒',
          desc: '过期前3天/7天推送通知',
          isOn: _expiryOn,
          onToggle: () => setState(() => _expiryOn = !_expiryOn),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _expiryOn
              ? Padding(
                  key: const ValueKey('expiry_date'),
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('过期日期'),
                            const SizedBox(height: 6),
                            _buildInput(
                              controller: _expiryDateController,
                              placeholder: '选择日期',
                              readOnly: true,
                              onTap: () => _pickDate(
                                _expiryDateController,
                                onPicked: (d) {
                                  setState(() {
                                    _expiryDate = d;
                                    _expiryDateController.text =
                                        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                                  });
                                },
                              ),
                              suffix: Icon(Icons.expand_more, size: 14, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('expiry_empty')),
        ),

        // 保修到期提醒
        _buildReminderRow(
          title: '保修到期提醒',
          desc: '保修到期前7天/30天推送通知',
          isOn: _warrantyOn,
          onToggle: () => setState(() => _warrantyOn = !_warrantyOn),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _warrantyOn
              ? Padding(
                  key: const ValueKey('warranty_date'),
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('保修到期日'),
                            const SizedBox(height: 6),
                            _buildInput(
                              controller: _warrantyDateController,
                              placeholder: '选择日期',
                              readOnly: true,
                              onTap: () => _pickDate(
                                _warrantyDateController,
                                onPicked: (d) {
                                  setState(() {
                                    _warrantyDate = d;
                                    _warrantyDateController.text =
                                        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                                  });
                                },
                              ),
                              suffix: Icon(Icons.expand_more, size: 14, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('warranty_empty')),
        ),

        // 定期保养提醒
        _buildReminderRow(
          title: '定期保养提醒',
          desc: '按周期推送保养维护提醒',
          isOn: _maintainOn,
          onToggle: () => setState(() => _maintainOn = !_maintainOn),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _maintainOn
              ? Padding(
                  key: const ValueKey('maintain_cycle'),
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('保养周期'),
                            const SizedBox(height: 6),
                            _buildDropdown(),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('maintain_empty')),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _maintainCycle,
          isExpanded: true,
          icon: Icon(Icons.expand_more, size: 16, color: AppColors.muted),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          items: ['每月', '每季度', '每半年', '每年']
              .map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(v, style: const TextStyle(fontSize: 14, color: AppColors.fg)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _maintainCycle = v ?? '每半年'),
        ),
      ),
    );
  }

  Widget _buildReminderRow({
    required String title,
    required String desc,
    required bool isOn,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.fg)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: isOn ? AppColors.accent : AppColors.border,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 1)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 底部按钮 ====================
  Widget _buildBottomActions() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [AppColors.bg, AppColors.bg.withOpacity(0)],
          stops: const [0.6, 1.0],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Row(
        children: [
          // 保存入库
          Expanded(
            child: GestureDetector(
              onTap: () => _saveItem(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(colors: [AppColors.accent, AppColors.orange]),
                  boxShadow: [
                    BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '保存入库',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 保存并继续新增
          Expanded(
            child: GestureDetector(
              onTap: () => _saveItem(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '保存并继续新增',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.accentDark),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 成功弹窗 ====================
  Widget _buildSuccessOverlay() {
    return Container(
      color: AppColors.bg.withOpacity(0.96),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 成功图标
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppColors.greenLight, AppColors.green]),
              ),
              child: const Icon(Icons.check, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              _successTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.fg),
            ),
            const SizedBox(height: 6),
            Text(
              _successSub,
              style: const TextStyle(fontSize: 14, color: AppColors.fgSecondary),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _successBtnAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(colors: [AppColors.accent, AppColors.orange]),
                  boxShadow: [
                    BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Text(
                  _successBtnText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 通用组件 ====================
  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.fgSecondary),
        ),
        if (required)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              '*',
              style: TextStyle(fontSize: 10, color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    double fontSize = 14,
    EdgeInsets? padding,
    Widget? suffix,
  }) {
    return GestureDetector(
      onTap: readOnly ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: fontSize, color: AppColors.fg),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: AppColors.muted, fontSize: fontSize),
            contentPadding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            border: InputBorder.none,
            suffixIcon: suffix,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectTrigger({
    required String text,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: hasValue ? AppColors.fg : AppColors.muted,
              ),
            ),
            Icon(Icons.expand_more, size: 14, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

// ==================== 照片数据 ====================
class _PhotoData {
  final String emoji;
  final Color color;

  const _PhotoData({required this.emoji, required this.color});
}

// ==================== 表单卡片容器 ====================
class _FormCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _FormCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.accentDark),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.fg),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ==================== 选择器底部弹窗 ====================
class _PickerSheet extends StatelessWidget {
  final String title;
  final List<PickerItem> items;
  final String? selectedName;
  final ValueChanged<String> onPick;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.selectedName,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.fg)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 14, color: AppColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 4列网格
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.name == selectedName;
                return GestureDetector(
                  onTap: () => onPick(item.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFF3CC) : AppColors.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 6),
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.accentDark : AppColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
