import 'dart:io';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/models/category_item.dart';
import 'package:shi_wu_ji/models/template.dart';
import 'package:shi_wu_ji/models/picker_item.dart';
import 'package:shi_wu_ji/models/emoji_classifier.dart';
import 'package:shi_wu_ji/models/item.dart';
import 'package:shi_wu_ji/widgets/app_dropdown_button.dart';
import 'package:shi_wu_ji/widgets/emoji_text.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';
import 'package:shi_wu_ji/providers/item_providers.dart';
import 'package:shi_wu_ji/providers/storage_providers.dart';
import 'package:shi_wu_ji/providers/category_provider.dart';
import 'package:shi_wu_ji/services/notification_service.dart';
import 'package:shi_wu_ji/services/photo_service.dart';

// ==================== 主页面 ====================

/// 扫一扫识别结果预填充数据，用于从扫描页跳转到新建物品页时回填表单。
class AddItemInitialValues {
  final String name;
  final String? category;
  final String? brand;
  final String? description;
  final String? photoPath;

  const AddItemInitialValues({
    required this.name,
    this.category,
    this.brand,
    this.description,
    this.photoPath,
  });
}

class AddItemPage extends ConsumerStatefulWidget {
  /// 编辑模式时传入的物品 id；新增模式为 null
  final String? itemId;

  /// 扫一扫识别结果预填充数据；仅新增模式且非编辑时生效
  final AddItemInitialValues? initialValues;

  const AddItemPage({super.key, this.itemId, this.initialValues});

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage>
    with TickerProviderStateMixin {
  bool get _isEdit => widget.itemId != null;

  // 表单控制器
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  final _buyDateController = TextEditingController();
  final _scrollController = ScrollController();

  // 模板字段控制器
  final Map<String, TextEditingController> _tplControllers = {};

  // 照片（真实本地文件路径 + 上传状态）
  final List<PhotoEntry> _photos = [];
  bool _isPicking = false;

  // 状态
  String _selectedTemplate = 'none';
  String _selectedSource = '线下购买';
  String? _selectedCategory;
  String? _selectedCategoryKey;
  String? _selectedLocation;
  StorageLocationNode? _selectedLocationNode;

  // 动态 emoji：随模板默认值 + 名称/品牌/备注关键词实时更新
  String _currentEmoji = '📦';

  // 编辑模式下记录原始照片路径，用于提交时清理被删除的文件
  List<String> _originalPhotos = const [];

  // 扫一扫预填充：待匹配的 AI 分类标签（数据库分类异步加载完成后再匹配）
  String? _pendingCategoryLabel;

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

    // 监听名称/品牌/备注变化，实时更新动态 emoji
    _nameController.addListener(_updateEmoji);
    _brandController.addListener(_updateEmoji);
    _noteController.addListener(_updateEmoji);

    // 编辑模式：从数据库预填充；扫一扫：用识别结果预填充；其余新增模式：空白表单
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEdit) {
        _prefillFromItem();
      } else if (widget.initialValues != null) {
        _prefillFromScanResult();
      }
    });

    // 监听分类数据加载完成，匹配扫一扫预填充的分类标签
    ref.listenManual(categoryManagerProvider, (prev, next) {
      if (next.hasValue && _pendingCategoryLabel != null) {
        _tryMatchPendingCategory();
      }
    });
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

  // ==================== 编辑模式预填充 ====================
  void _prefillFromItem() {
    final item = ref.read(itemByIdProvider(widget.itemId!));
    if (item == null) return;

    _nameController.text = item.name;
    _brandController.text = item.brand;
    _priceController.text = item.price.toStringAsFixed(
      item.price == item.price.roundToDouble() ? 0 : 2,
    );
    _noteController.text = item.note;
    _buyDateController.text =
        '${item.purchaseDate.year}-${item.purchaseDate.month.toString().padLeft(2, '0')}-${item.purchaseDate.day.toString().padLeft(2, '0')}';

    _selectedCategory = item.category == '未分类' ? null : item.category;
    _selectedCategoryKey = item.categoryKey.isEmpty ? null : item.categoryKey;
    _selectedLocation = item.location == '未知' ? null : item.location;

    // 还原模板选择与模板字段值
    _selectedTemplate = item.templateKey;
    final tplData = templateFieldsMap[item.templateKey];
    if (item.templateKey != 'none' && tplData != null) {
      for (final f in tplData.fields) {
        _tplControllers[f.id] = TextEditingController(
          text: item.templateData[f.id] ?? '',
        );
      }
      _templateFieldsAnimController.value = 1.0;
    }

    // 还原保修信息
    if (item.warrantyDays > 0 && item.warrantyDays != 365) {
      _warrantyOn = true;
      final warrantyEnd = item.warrantyEndDate;
      _warrantyDate = warrantyEnd;
      _warrantyDateController.text =
          '${warrantyEnd.year}-${warrantyEnd.month.toString().padLeft(2, '0')}-${warrantyEnd.day.toString().padLeft(2, '0')}';
    }

    // 还原照片
    _originalPhotos = List<String>.from(item.photos);
    _photos
      ..clear()
      ..addAll(
        item.photos.map(
          (p) => PhotoEntry(path: p, status: PhotoStatus.success),
        ),
      );

    // 还原收纳位置节点
    if (item.cabinetId != null || item.slotId != null) {
      final nodes = ref.read(storageLocationTreeProvider).value ?? const [];
      StorageLocationNode? matched;
      if (item.slotId != null) {
        matched = nodes
            .where((n) => n.isSlot && n.id == item.slotId)
            .cast<StorageLocationNode?>()
            .firstWhere((_) => true, orElse: () => null);
      } else if (item.cabinetId != null) {
        matched = nodes
            .where((n) => !n.isSlot && n.id == item.cabinetId)
            .cast<StorageLocationNode?>()
            .firstWhere((_) => true, orElse: () => null);
      }
      _selectedLocationNode = matched;
    }

    // 编辑模式：以物品现有 emoji 为初值，后续编辑名称/品牌/备注时由监听器动态更新
    _currentEmoji = item.emoji.isNotEmpty
        ? item.emoji
        : EmojiClassifier.defaultEmojiOf(_selectedTemplate);
    setState(() {});
  }

  // ==================== 扫一扫预填充 ====================
  void _prefillFromScanResult() {
    final iv = widget.initialValues;
    if (iv == null) return;

    _nameController.text = iv.name;
    if (iv.brand != null && iv.brand!.isNotEmpty) {
      _brandController.text = iv.brand!;
    }
    if (iv.description != null && iv.description!.isNotEmpty) {
      _noteController.text = iv.description!;
    }
    if (iv.photoPath != null && iv.photoPath!.isNotEmpty) {
      _photos
        ..clear()
        ..add(PhotoEntry(path: iv.photoPath!, status: PhotoStatus.success));
    }
    // 分类需匹配数据库分类（异步），暂存标签等待 provider 就绪后匹配
    if (iv.category != null && iv.category!.isNotEmpty) {
      _pendingCategoryLabel = iv.category;
      _tryMatchPendingCategory();
    }
    _updateEmoji();
    setState(() {});
  }

  /// 将 AI 返回的分类标签匹配到数据库分类，命中则设置 _selectedCategory/_selectedCategoryKey。
  /// 数据库分类尚未加载时跳过，由 build 中 watch 触发重试。
  void _tryMatchPendingCategory() {
    final label = _pendingCategoryLabel;
    if (label == null) return;
    final dbCats = ref.read(categoryManagerProvider).value ?? const [];
    if (dbCats.isEmpty) return;

    CategoryItem? match;
    for (final c in dbCats) {
      if (c.label == label) {
        match = c;
        break;
      }
    }
    // 精确匹配失败时尝试包含关系兜底（如 AI 返回"数码电子"匹配"数码"）
    if (match == null) {
      for (final c in dbCats) {
        if (label.contains(c.label) || c.label.contains(label)) {
          match = c;
          break;
        }
      }
    }
    if (match != null) {
      _selectedTemplate = 'none';
      _selectedCategory = match.label;
      _selectedCategoryKey = match.id;
    }
    _pendingCategoryLabel = null;
    setState(() {});
  }

  // ==================== Toast ====================
  void _showToast(String message) {
    // 使用 Overlay 实现的顶部 Toast，避免 SnackBar floating 在底部按钮/模板字段
    // 占用较多垂直空间时触发 "Floating SnackBar presented off screen" 断言。
    ToastUtils.show(context, message);
  }

  // ==================== 照片操作 ====================
  Future<void> _addPhoto() async {
    if (_isPicking) return;
    if (_photos.length >= PhotoService.maxPhotos) {
      _showToast('最多添加 ${PhotoService.maxPhotos} 张照片');
      return;
    }
    setState(() => _isPicking = true);

    final remaining = PhotoService.maxPhotos - _photos.length;
    final result = await PhotoService.instance.pickFromGallery(
      remaining: remaining,
    );

    if (!mounted) return;
    setState(() {
      _photos.addAll(result.entries);
      _isPicking = false;
    });

    if (result.error != null && result.entries.isEmpty) {
      _showToast(result.error!);
    } else if (result.error != null) {
      _showToast('部分图片未通过：${result.error}');
    } else if (result.entries.isNotEmpty) {
      _showToast('已添加 ${result.entries.length} 张照片');
    }
  }

  Future<void> _addPhotoFromCamera() async {
    if (_isPicking) return;
    if (_photos.length >= PhotoService.maxPhotos) {
      _showToast('最多添加 ${PhotoService.maxPhotos} 张照片');
      return;
    }
    setState(() => _isPicking = true);

    final result = await PhotoService.instance.pickFromCamera();

    if (!mounted) return;
    setState(() {
      _photos.addAll(result.entries);
      _isPicking = false;
    });

    if (result.error != null) {
      _showToast(result.error!);
    } else if (result.entries.isNotEmpty) {
      _showToast('已添加照片');
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(ctx);
                _addPhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(ctx);
                _addPhotoFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: AppColors.textSecondary),
              title: const Text('取消'),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  void _removePhoto(int index) {
    final removed = _photos[index];
    setState(() {
      _photos.removeAt(index);
    });
    // 编辑模式下：被删除的若是已存库照片，提交时再清理文件；
    // 新增模式下草稿照片直接删除文件
    if (!_isEdit && !_originalPhotos.contains(removed.path)) {
      PhotoService.instance.deleteFile(removed.path);
    }
  }

  void _retryPhoto(int index) {
    final entry = _photos[index];
    if (entry.status != PhotoStatus.failed) return;
    setState(() {
      _photos[index] = entry.copyWith(status: PhotoStatus.uploading);
    });
    // 失败重试：重新拷贝（失败条目 path 指向缓存原图路径的场景极少，这里直接移除让用户重选）
    setState(() {
      _photos.removeAt(index);
    });
    _showToast('请重新选择该照片');
  }

  // ==================== 模板选择 ====================
  /// 动态 emoji 更新：基于当前模板大类默认值 + 名称/品牌/备注关键词匹配。
  /// 由 _nameController/_brandController/_noteController 的监听器触发，
  /// 也在模板切换、表单重置后主动调用。
  void _updateEmoji() {
    final content =
        '${_nameController.text} ${_brandController.text} ${_noteController.text}';
    final emoji = EmojiClassifier.classify(
      mainCategoryKey: _selectedTemplate,
      content: content,
    );
    // 始终 setState：emoji 不变时预览标签（命中分类名）仍可能变化
    setState(() => _currentEmoji = emoji);
  }

  void _selectTemplate(String key) {
    setState(() {
      _selectedTemplate = key;
      // 清理旧的模板控制器
      for (final c in _tplControllers.values) {
        c.dispose();
      }
      _tplControllers.clear();

      // 品类模版与分类一一对应：非通用模版自动设置分类
      if (key == 'none') {
        _selectedCategory = null;
        _selectedCategoryKey = null;
      } else {
        final card = TemplateCard.cards.firstWhere(
          (c) => c.key == key,
          orElse: () => TemplateCard(key: key, emoji: '📦', name: key),
        );
        _selectedCategory = card.name;
        _selectedCategoryKey = key;
      }
      // 模板切换后重置为该大类默认 emoji，再依据当前输入内容重新匹配
      _currentEmoji = EmojiClassifier.defaultEmojiOf(key);
    });
    _updateEmoji();

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
    final title = isCategory ? '选择分类' : '选择收纳位置';
    final currentSelected = isCategory ? _selectedCategory : _selectedLocation;

    // 分类选择：动态读取数据库分类（含用户增删改），不用硬编码 categoryData
    // 虚拟物品分类（会员订阅等）不在此处可选，仅能通过品类模版设置
    final List<PickerItem> data;
    final Map<String, String> labelToKey;
    if (isCategory) {
      final dbCats = ref.read(categoryManagerProvider).value ?? const [];
      data = [
        for (final c in dbCats) PickerItem(emoji: c.emoji, name: c.label),
      ];
      labelToKey = {for (final c in dbCats) c.label: c.id};
    } else {
      data = locationData;
      labelToKey = const {};
    }

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
              _selectedCategoryKey = labelToKey[name];
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

  // ==================== 收纳位置选择（联动柜体/格子）====================
  void _openLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final asyncNodes = ref.watch(storageLocationTreeProvider);
            final allNodes = asyncNodes.value ?? const [];
            final slotNodes = allNodes.where((n) => n.isSlot).toList();
            return _LocationPickerSheet(
              nodes: slotNodes,
              isLoading: asyncNodes.isLoading,
              selectedNode: _selectedLocationNode,
              onPick: (node) {
                setState(() {
                  _selectedLocationNode = node;
                  _selectedLocation = node.pathLabel;
                });
                Navigator.pop(ctx);
                _showToast('已选择：${node.pathLabel}');
              },
              onClear: () {
                setState(() {
                  _selectedLocationNode = null;
                  _selectedLocation = null;
                });
                Navigator.pop(ctx);
              },
            );
          },
        );
      },
    );
  }

  // ==================== 日期选择 ====================
  Future<void> _pickDate(
    TextEditingController controller, {
    void Function(DateTime)? onPicked,
  }) async {
    final now = DateTime.now();
    // 尝试解析控制器中已有的日期作为初始值
    DateTime currentDate = now;
    if (controller.text.isNotEmpty) {
      try {
        currentDate = DateTime.parse(controller.text);
      } catch (_) {}
    }

    await DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2000, 1, 1),
      maxTime: DateTime(2100, 12, 31),
      currentTime: currentDate,
      theme: DatePickerTheme(
        titleHeight: 45,
        itemStyle: const TextStyle(fontSize: 18, color: AppColors.textPrimary),
        doneStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
        cancelStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),
      locale: LocaleType.zh,
      onChanged: (date) {},
      onConfirm: (date) {
        controller.text =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        onPicked?.call(date);
      },
    );
  }

  // ==================== 保存 ====================
  Future<void> _saveItem(bool andContinue) async {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();

    if (name.isEmpty) {
      _showToast('请填写物品名称');
      FocusScope.of(context).unfocus();
      return;
    }
    final price = double.tryParse(priceStr);
    if (price == null || price <= 0) {
      _showToast('请填写有效的购买价格');
      FocusScope.of(context).unfocus();
      return;
    }

    // 通用物品创建流程：必须手动选择分类（非通用模版已自动绑定分类）
    if (_selectedTemplate == 'none' && _selectedCategory == null) {
      _showToast('请选择物品分类');
      FocusScope.of(context).unfocus();
      return;
    }

    // 必须选择收纳位置
    if (_selectedLocation == null) {
      _showToast('请选择收纳位置');
      FocusScope.of(context).unfocus();
      return;
    }

    // 解析购买日期
    DateTime purchaseDate = DateTime.now();
    if (_buyDateController.text.isNotEmpty) {
      try {
        purchaseDate = DateTime.parse(_buyDateController.text);
      } catch (_) {}
    }

    // 计算保修天数
    int warrantyDays = 365;
    if (_warrantyOn && _warrantyDateController.text.isNotEmpty) {
      try {
        final warrantyEnd = DateTime.parse(_warrantyDateController.text);
        warrantyDays = warrantyEnd.difference(purchaseDate).inDays;
        if (warrantyDays < 0) warrantyDays = 365;
      } catch (_) {}
    }

    // 照片路径（仅取成功状态的）
    final photoPaths = _photos
        .where((p) => p.status == PhotoStatus.success)
        .map((p) => p.path)
        .toList();

    // 模板字段值
    final tplDataMap = <String, String>{};
    for (final e in _tplControllers.entries) {
      final v = e.value.text.trim();
      if (v.isNotEmpty) tplDataMap[e.key] = v;
    }

    final node = _selectedLocationNode;
    final bool saving = _isEdit;

    if (saving) {
      // 编辑模式：全量更新
      final existing = ref.read(itemByIdProvider(widget.itemId!));
      final item = Item(
        id: existing!.id,
        name: name,
        price: price,
        emoji: existing.emoji.isEmpty ? '📦' : existing.emoji,
        category: _selectedCategory ?? '未分类',
        location: _selectedLocation ?? '未知',
        purchaseDate: purchaseDate,
        warrantyDays: warrantyDays,
        status: existing.status,
        categoryKey: _selectedCategoryKey ?? '',
        cabinetId: node?.cabinetId,
        slotId: node?.isSlot == true ? node?.id : null,
        photos: photoPaths,
        brand: _brandController.text.trim(),
        note: _noteController.text.trim(),
        templateKey: _selectedTemplate,
        templateData: tplDataMap,
      );

      await ref.read(itemsProvider.notifier).updateItem(item);

      // 清理被删除的旧照片文件
      final removedFiles = _originalPhotos
          .where((p) => !photoPaths.contains(p))
          .toList();
      for (final f in removedFiles) {
        PhotoService.instance.deleteFile(f);
      }

      // 重新调度保修提醒
      if (_warrantyOn && _warrantyDate != null) {
        NotificationService().scheduleWarrantyReminder(item);
      }

      _successTitle = '保存成功！';
      _successSub = '「$name」的信息已更新';
      _successBtnText = '好的';
      _successBtnAction = () {
        if (mounted) {
          setState(() => _showSuccess = false);
          Navigator.of(context).pop();
        }
      };
    } else {
      // 新增模式
      final item = Item.create(
        name: name,
        price: price,
        emoji: _currentEmoji,
        category: _selectedCategory ?? '未分类',
        location: _selectedLocation ?? '未知',
        purchaseDate: purchaseDate,
        warrantyDays: warrantyDays,
        status: 'safe',
        categoryKey: _selectedCategoryKey ?? '',
        cabinetId: node?.cabinetId,
        slotId: node?.isSlot == true ? node?.id : null,
        photos: photoPaths,
        brand: _brandController.text.trim(),
        note: _noteController.text.trim(),
        templateKey: _selectedTemplate,
        templateData: tplDataMap,
      );

      await ref.read(itemsProvider.notifier).addItem(item);

      if (_warrantyOn && _warrantyDate != null) {
        NotificationService().scheduleWarrantyReminder(item);
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
          if (mounted) {
            setState(() => _showSuccess = false);
            Navigator.of(context).pop();
          }
        };
      }
    }

    if (mounted) setState(() => _showSuccess = true);
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
      _selectedCategoryKey = null;
      _selectedLocation = null;
      _selectedLocationNode = null;
      _currentEmoji = '📦';
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
      backgroundColor: AppColors.background,
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
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _isEdit ? '编辑物品' : '新增物品',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 照片区域 ====================
  Widget _buildPhotoSection() {
    final canAddMore = _photos.length < PhotoService.maxPhotos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 14,
              color: AppColors.primaryDark,
            ),
            const SizedBox(width: 6),
            Text(
              '物品照片 · ${_photos.length}/${PhotoService.maxPhotos}（JPG/PNG，≤5MB）',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photos.length + (canAddMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == _photos.length) {
                // 添加按钮
                return GestureDetector(
                  onTap: _isPicking ? null : _showPhotoSourceSheet,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.border,
                        width: 2.5,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: _isPicking
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add,
                                size: 28,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                '添加照片',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              }
              // 照片缩略图
              final photo = _photos[index];
              return _PhotoThumb(
                entry: photo,
                isCover: index == 0,
                onRemove: () => _removePhoto(index),
                onRetry: photo.status == PhotoStatus.failed
                    ? () => _retryPhoto(index)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== 品类模板 ====================
  Widget _buildTemplateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.grid_view, size: 14, color: AppColors.primaryDark),
            const SizedBox(width: 6),
            const Text(
              '品类模板 · 一键匹配专属属性',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: TemplateCard.cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final card = TemplateCard.cards[index];
              final key = card.key;
              final isSelected = _selectedTemplate == key;
              return GestureDetector(
                onTap: () => _selectTemplate(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFF3CC)
                        : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: AppColors.textPrimary.withValues(
                                alpha: 0.06,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EmojiText(emoji: card.emoji, fontSize: 22),
                      const SizedBox(width: 8),
                      Text(
                        card.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
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
            color: AppColors.background,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    data.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
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
                    children: List.generate(2, (col) {
                      final fieldIdx = row * 2 + col;
                      if (fieldIdx >= data.fields.length) {
                        return const Expanded(child: SizedBox());
                      }
                      final field = data.fields[fieldIdx];
                      final ctrl = _tplControllers[field.id]!;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: col > 0 ? 5 : 0,
                            right: col > 0 ? 0 : 5,
                          ),
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
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              _buildInput(
                                controller: ctrl,
                                placeholder: field.placeholder,
                                fontSize: 13,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                onTap: field.isDate
                                    ? () => _pickDate(ctrl)
                                    : null,
                                readOnly: field.isDate,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 动态 emoji 预览：实时展示根据模板+名称/品牌/备注匹配到的图标。
  /// 配合 AnimatedSwitcher 实现切换过渡，命中二级分类时附带分类名提示。
  Widget _buildEmojiPreview() {
    final content =
        '${_nameController.text} ${_brandController.text} ${_noteController.text}';
    final matched = EmojiClassifier.matchDetail(
      mainCategoryKey: _selectedTemplate,
      content: content,
    );
    final isMatched = matched != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isMatched ? matched.name : '默认',
          style: TextStyle(
            fontSize: 11,
            color: isMatched ? AppColors.primary : AppColors.textHint,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Container(
            key: ValueKey(_currentEmoji),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.accentLightBg,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(_currentEmoji, style: const TextStyle(fontSize: 17)),
          ),
        ),
      ],
    );
  }

  // ==================== 基本信息 ====================
  Widget _buildBasicInfoSection() {
    return _FormCard(
      icon: Icons.edit,
      title: '基本信息',
      children: [
        // 物品名称 + 动态 emoji 预览
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_buildLabel('物品名称', required: true), _buildEmojiPreview()],
        ),
        const SizedBox(height: 6),
        _buildInput(
          controller: _nameController,
          placeholder: '例如：AirPods Pro 2',
        ),
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
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
                    suffix: Icon(
                      Icons.expand_more,
                      size: 14,
                      color: AppColors.textHint,
                    ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFF3CC)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  source,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryDark
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
                  _buildLabel('物品分类', required: _selectedTemplate == 'none'),
                  const SizedBox(height: 6),
                  _buildSelectTrigger(
                    text: _selectedCategory ?? '选择分类',
                    hasValue: _selectedCategory != null,
                    onTap: () => _openPicker(isCategory: true),
                    disabled: _selectedTemplate != 'none',
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
                  _buildLabel('收纳位置', required: true),
                  const SizedBox(height: 6),
                  _buildSelectTrigger(
                    text: _selectedLocation ?? '选择位置',
                    hasValue: _selectedLocation != null,
                    onTap: _openLocationPicker,
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
          maxLines: 4,
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
                              suffix: Icon(
                                Icons.expand_more,
                                size: 14,
                                color: AppColors.textHint,
                              ),
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
          onToggle: () {
            setState(() {
              _warrantyOn = !_warrantyOn;
              if (_warrantyOn && _warrantyDateController.text.isEmpty) {
                // 默认保修期 1 年（购买日期 + 365 天）
                DateTime purchaseDate = DateTime.now();
                if (_buyDateController.text.isNotEmpty) {
                  try {
                    purchaseDate = DateTime.parse(_buyDateController.text);
                  } catch (_) {}
                }
                final defaultWarrantyEnd = purchaseDate.add(
                  const Duration(days: 365),
                );
                _warrantyDate = defaultWarrantyEnd;
                _warrantyDateController.text =
                    '${defaultWarrantyEnd.year}-${defaultWarrantyEnd.month.toString().padLeft(2, '0')}-${defaultWarrantyEnd.day.toString().padLeft(2, '0')}';
              }
            });
          },
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
                              suffix: Icon(
                                Icons.expand_more,
                                size: 14,
                                color: AppColors.textHint,
                              ),
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
    return AppDropdownButton<String>(
      value: _maintainCycle,
      items: const [
        DropdownOption('每月', '每月'),
        DropdownOption('每季度', '每季度'),
        DropdownOption('每半年', '每半年'),
        DropdownOption('每年', '每年'),
      ],
      onChanged: (v) => setState(() => _maintainCycle = v ?? '每半年'),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
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
                color: isOn ? AppColors.primary : AppColors.border,
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
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
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
          colors: [
            AppColors.background,
            AppColors.background.withValues(alpha: 0),
          ],
          stops: const [0.6, 1.0],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Row(
        children: [
          // 保存入库 / 保存修改
          Expanded(
            child: GestureDetector(
              onTap: () => _saveItem(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.warning],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _isEdit ? '保存修改' : '保存入库',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 新增模式才显示“保存并继续新增”
          if (!_isEdit) ...[
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _saveItem(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppColors.cardBg,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '保存并继续新增',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== 成功弹窗 ====================
  Widget _buildSuccessOverlay() {
    return Container(
      color: AppColors.background.withValues(alpha: 0.96),
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
                gradient: LinearGradient(
                  colors: [AppColors.successLight, AppColors.success],
                ),
              ),
              child: const Icon(Icons.check, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              _successTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _successSub,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _successBtnAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.warning],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _successBtnText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        if (required)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              '*',
              style: TextStyle(fontSize: 10, color: AppColors.danger),
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
          color: AppColors.background,
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
          style: TextStyle(fontSize: fontSize, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: fontSize),
            contentPadding:
                padding ??
                //const EdgeInsets.fromLTRB(14, 11, 4, 11),
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.border.withValues(alpha: 0.3)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: disabled
                ? AppColors.border.withValues(alpha: 0.5)
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: disabled
                      ? AppColors.textSecondary
                      : (hasValue ? AppColors.textPrimary : AppColors.textHint),
                ),
              ),
            ),
            Icon(
              disabled ? Icons.lock_outline : Icons.expand_more,
              size: 14,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
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
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
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
              Icon(icon, size: 16, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 14, color: AppColors.textHint),
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
                      color: isSelected
                          ? const Color(0xFFFFF3CC)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        EmojiText(emoji: item.emoji, fontSize: 24),
                        const SizedBox(height: 6),
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
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

// ==================== 收纳位置选择弹窗 ====================
class _LocationPickerSheet extends StatelessWidget {
  final List<StorageLocationNode> nodes;
  final bool isLoading;
  final StorageLocationNode? selectedNode;
  final ValueChanged<StorageLocationNode> onPick;
  final VoidCallback onClear;

  const _LocationPickerSheet({
    required this.nodes,
    required this.isLoading,
    required this.selectedNode,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheetHeight = screenHeight * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部把手
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 标题行
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '选择收纳位置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.refresh,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: '清除选择',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // 列表
          Flexible(
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: AppColors.accentGold,
                      ),
                    ),
                  )
                : nodes.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        '暂无可用格子区域\n请先在收纳页面添加柜体和格子',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: nodes.length,
                    itemBuilder: (ctx, i) {
                      final node = nodes[i];
                      final isSelected =
                          selectedNode?.id == node.id &&
                          selectedNode?.isSlot == node.isSlot;
                      return _LocationTile(
                        node: node,
                        isSelected: isSelected,
                        onTap: () => onPick(node),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final StorageLocationNode node;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationTile({
    required this.node,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF8E7) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentGold : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // 层级图标
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: node.isSlot
                    ? const Color(0xFFE8F0FE)
                    : const Color(0xFFFFF3CC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: EmojiText(emoji: node.emoji, fontSize: 18)),
            ),
            const SizedBox(width: 12),
            // 路径信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    node.pathLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 选中标记
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.accentGold,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ==================== 照片缩略图组件 ====================
class _PhotoThumb extends StatelessWidget {
  final PhotoEntry entry;
  final bool isCover;
  final VoidCallback onRemove;
  final VoidCallback? onRetry;

  const _PhotoThumb({
    required this.entry,
    required this.isCover,
    required this.onRemove,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final failed = entry.status == PhotoStatus.failed;
    final uploading = entry.status == PhotoStatus.uploading;
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 图片
          Image.file(
            File(entry.path),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.border,
              child: const Icon(Icons.broken_image, color: AppColors.textHint),
            ),
          ),
          // 上传中遮罩
          if (uploading)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // 失败遮罩
          if (failed)
            GestureDetector(
              onTap: onRetry,
              child: Container(
                color: Colors.black.withValues(alpha: 0.55),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 22),
                    SizedBox(height: 2),
                    Text(
                      '点击重试',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 删除按钮
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
          // 封面标签
          if (isCover)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.warning],
                  ),
                ),
                child: const Text(
                  '封面',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
