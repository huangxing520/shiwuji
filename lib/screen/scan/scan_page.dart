import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/constants/app_text_styles.dart';
import 'package:shi_wu_ji/providers/profile_provider.dart';
import 'package:shi_wu_ji/screen/add_item_page.dart';
import 'package:shi_wu_ji/services/ai/ai_models.dart';
import 'package:shi_wu_ji/services/ai/ai_provider_registry.dart';
import 'package:shi_wu_ji/services/ai/ai_provider_type.dart';
import 'package:shi_wu_ji/services/photo_service.dart';
import 'package:shi_wu_ji/services/prompt_service.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  bool _isAnalyzing = false;
  String? _capturedImagePath;
  AiVisionResult? _result;
  String? _errorMessage;
  AiProviderConfig? _selectedConfig;

  Future<void> _onTakePhoto() async {
    if (_isAnalyzing) return;
    try {
      final result = await PhotoService.instance.pickFromCamera();
      if (result.error != null) {
        setState(() {
          _errorMessage = result.error;
        });
        return;
      }
      if (result.entries.isEmpty) return;

      setState(() {
        _capturedImagePath = result.entries.first.path;
        _isAnalyzing = true;
        _errorMessage = null;
        _result = null;
      });
      await _analyzeWithAI();
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = '拍照失败：$e';
      });
    }
  }

  Future<void> _onPickFromGallery() async {
    if (_isAnalyzing) return;
    try {
      debugPrint('[ScanPage] 开始从相册选图...');
      final result = await PhotoService.instance.pickFromGallery(remaining: 1);
      if (result.error != null) {
        debugPrint('[ScanPage] 选图校验失败: ${result.error}');
        setState(() {
          _errorMessage = result.error;
        });
        return;
      }
      if (result.entries.isEmpty) {
        debugPrint('[ScanPage] 用户取消选图');
        return;
      }

      debugPrint('[ScanPage] 选图成功: ${result.entries.first.path}');
      setState(() {
        _capturedImagePath = result.entries.first.path;
        _isAnalyzing = true;
        _errorMessage = null;
        _result = null;
      });
      await _analyzeWithAI();
    } catch (e, stack) {
      debugPrint('[ScanPage] 选图异常: $e\n$stack');
      setState(() {
        _isAnalyzing = false;
        _errorMessage = '选择图片失败：$e';
      });
    }
  }

  Future<void> _analyzeWithAI() async {
    if (_capturedImagePath == null) return;
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final configAsync = ref.read(aiConfigManagerProvider);
      AiProviderConfig? config;
      if (_selectedConfig != null) {
        config = _selectedConfig;
      } else if (configAsync.hasValue) {
        config = configAsync.value;
      } else {
        final manager = await ref.read(aiConfigManagerProvider.future);
        config = manager;
      }

      if (config == null) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = '未找到可用的 AI 模型配置，请先在「我的 > AI模型设置」中配置模型。';
        });
        return;
      }
      final activeConfig = config;
      _selectedConfig = activeConfig;

      if (!activeConfig.isConfigured) {
        final typeName =
            aiProviderMetas[activeConfig.type]?.displayName ??
            activeConfig.type.name;
        setState(() {
          _isAnalyzing = false;
          _errorMessage = '当前模型「$typeName」未完成配置，请先在设置中填写 API Key。';
        });
        return;
      }

      final provider = AiProviderRegistry.instance.get(activeConfig.type);
      final prompt = await PromptService.instance.loadRecognitionPrompt();
      final result = await provider.recognizeImage(
        imagePath: _capturedImagePath!,
        config: activeConfig.toCallConfig(),
        prompt: prompt,
      );

      final logs = ref.read(aiCallLogsProvider.notifier);
      logs.record(
        AiCallLog(
          provider: activeConfig.type,
          model: result.model,
          success: true,
          elapsedMs: result.elapsedMs,
          timestamp: DateTime.now(),
        ),
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      final logs = ref.read(aiCallLogsProvider.notifier);
      AiProviderType providerType = AiProviderType.gemini;
      if (_selectedConfig != null) {
        providerType = _selectedConfig!.type;
      }
      logs.record(
        AiCallLog(
          provider: providerType,
          model: _selectedConfig?.modelName ?? '',
          success: false,
          elapsedMs: 0,
          error: e.toString(),
          timestamp: DateTime.now(),
        ),
      );

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _switchModel(AiProviderConfig config) async {
    setState(() {
      _selectedConfig = config;
      _result = null;
    });
    final notifier = ref.read(aiConfigManagerProvider.notifier);
    await notifier.setActiveModel(config.id);
    await _analyzeWithAI();
  }

  void _reset() {
    setState(() {
      _isAnalyzing = false;
      _capturedImagePath = null;
      _result = null;
      _errorMessage = null;
    });
  }

  Future<void> _addToLibrary() async {
    if (_result == null || _capturedImagePath == null) return;

    final result = _result!;
    // 不直接入库，而是携带识别结果跳转到新建物品页，由用户确认/补充后保存
    if (mounted) {
      context.push(
        '/add_item',
        extra: AddItemInitialValues(
          name: result.name,
          category: result.category,
          brand: result.brand,
          description: result.description,
          photoPath: _capturedImagePath,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedConfigsAsync = ref.watch(savedAiConfigsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: AppBar(
      //   title: const Text('扫一扫', style: AppTextStyles.titleLarge),
      //   backgroundColor: AppColors.background,
      //   foregroundColor: AppColors.textPrimary,
      //   elevation: 0,
      //   leading: _capturedImagePath != null
      //       ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _reset)
      //       : null,
      //   actions: [
      //     if (_capturedImagePath != null && _result != null)
      //       TextButton.icon(
      //         icon: const Icon(Icons.refresh, size: 18),
      //         label: const Text('重新识别'),
      //         onPressed: _analyzeWithAI,
      //       ),
      //   ],
      // ),
      body: _capturedImagePath == null
          ? _buildCameraView(savedConfigsAsync)
          : _buildResultView(savedConfigsAsync),
    );
  }

  Widget _buildCameraView(
    AsyncValue<List<AiProviderConfig>> savedConfigsAsync,
  ) {
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Column(
          children: [
            _buildTopModelBar(savedConfigsAsync),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.danger,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _errorMessage = null),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.danger,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '拍照或选择图片识别物品',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(left: 20, top: 20, child: _buildCorner()),
                    Positioned(
                      right: 20,
                      top: 20,
                      child: _buildCorner(isLeft: false),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: _buildCorner(isTop: false),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: _buildCorner(isLeft: false, isTop: false),
                    ),
                  ],
                ),
              ),
            ),
            _buildCameraActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner({bool isLeft = true, bool isTop = true}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          left: isLeft
              ? const BorderSide(color: AppColors.primary, width: 3)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: AppColors.primary, width: 3)
              : BorderSide.none,
          top: isTop
              ? const BorderSide(color: AppColors.primary, width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: AppColors.primary, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTopModelBar(
    AsyncValue<List<AiProviderConfig>> savedConfigsAsync,
  ) {
    return savedConfigsAsync.when(
      data: (configs) {
        if (configs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: () => context.push('/me'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '未配置AI模型，点击去设置',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        AiProviderConfig active;
        if (_selectedConfig != null) {
          active = _selectedConfig!;
        } else {
          active = configs.first;
        }
        final meta = aiProviderMetas[active.type];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GestureDetector(
            onTap: () => _showModelPicker(configs),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.smart_toy_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    meta?.displayName ?? active.type.name,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 51),
      error: (_, _) => const SizedBox(height: 51),
    );
  }

  Widget _buildCameraActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleAction(
            icon: Icons.photo_library_outlined,
            label: '相册',
            onTap: _onPickFromGallery,
          ),
          GestureDetector(
            onTap: _onTakePhoto,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: Colors.white24,
              ),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          _buildCircleAction(
            icon: Icons.close,
            label: '关闭',
            onTap: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(
    AsyncValue<List<AiProviderConfig>> savedConfigsAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModelSelector(savedConfigsAsync),
          const SizedBox(height: 16),
          _buildImagePreview(),
          const SizedBox(height: 16),
          if (_isAnalyzing) _buildLoadingView(),
          if (_errorMessage != null && !_isAnalyzing) _buildErrorView(),
          if (_result != null && !_isAnalyzing) _buildResultCard(),
          if (_result != null && !_isAnalyzing) ...[
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildModelSelector(
    AsyncValue<List<AiProviderConfig>> savedConfigsAsync,
  ) {
    return savedConfigsAsync.when(
      data: (configs) {
        if (configs.isEmpty) {
          return _buildNoModelCard();
        }
        AiProviderConfig current;
        if (_selectedConfig != null) {
          current = _selectedConfig!;
        } else {
          current = configs.first;
        }
        return _buildModelCard(current, configs);
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '加载模型失败：$e',
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      ),
    );
  }

  Widget _buildNoModelCard() {
    return Card(
      color: AppColors.warningLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 12),
            const Expanded(child: Text('尚未配置 AI 模型，请先设置')),
            TextButton(
              onPressed: () => context.push('/me'),
              child: const Text('去设置'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelCard(
    AiProviderConfig current,
    List<AiProviderConfig> configs,
  ) {
    final meta = aiProviderMetas[current.type];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.smart_toy_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  '识别模型',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showModelPicker(configs),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meta?.displayName ?? current.type.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (current.modelName != null &&
                              current.modelName!.isNotEmpty)
                            Text(
                              current.modelName!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModelPicker(List<AiProviderConfig> configs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '选择识别模型',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: configs.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (ctx, i) {
                    final config = configs[i];
                    final meta = aiProviderMetas[config.type];
                    final isSelected =
                        _selectedConfig?.id == config.id ||
                        (_selectedConfig == null && i == 0);
                    return ListTile(
                      leading: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            )
                          : Icon(
                              Icons.radio_button_unchecked,
                              color: AppColors.textHint,
                            ),
                      title: Text(
                        meta?.displayName ?? config.type.name,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle:
                          (config.modelName != null &&
                              config.modelName!.isNotEmpty)
                          ? Text(config.modelName!)
                          : null,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _switchModel(config);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    if (_capturedImagePath == null) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(_capturedImagePath!),
        height: 280,
        width: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildLoadingView() {
    final meta = _selectedConfig != null
        ? aiProviderMetas[_selectedConfig!.type]
        : null;
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '正在识别中...',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                meta != null ? '使用 ${meta.displayName} 分析图片' : '正在分析图片内容',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Card(
      color: AppColors.dangerLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.error_outline, color: AppColors.danger),
                SizedBox(width: 8),
                Text(
                  '识别失败',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _analyzeWithAI,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('重试'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _reset, child: const Text('重新拍照')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final r = _result!;
    final meta = _selectedConfig != null
        ? aiProviderMetas[_selectedConfig!.type]
        : null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.name,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (meta != null || r.model.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.smart_toy_outlined,
                    size: 14,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    meta?.displayName ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                  if (r.model.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '· ${r.model}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Text(
                    '· ${r.elapsedMs}ms',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            if (r.category != null && r.category!.isNotEmpty)
              _buildInfoRow(Icons.category_outlined, '类别', r.category!),
            if (r.brand.isNotEmpty)
              _buildInfoRow(Icons.branding_watermark_outlined, '品牌', r.brand),
            if (r.color.isNotEmpty) _buildColorRow(r.color),
            if (r.material.isNotEmpty)
              _buildInfoRow(Icons.inventory_2_outlined, '材质', r.material),
            if (r.condition.isNotEmpty && r.condition != '无法判断')
              _buildInfoRow(Icons.star_outline, '成色', r.condition),
            if (r.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                '物品描述',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                r.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
            if (r.features.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                '主要特征',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                r.features,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
            if (r.suggestedTags.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                '推荐标签',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: r.suggestedTags.map((t) => _buildTagChip(t)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(String color) {
    Color? chipColor = _parseColor(color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.palette_outlined,
            size: 16,
            color: AppColors.textHint,
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 48,
            child: Text(
              '颜色',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          if (chipColor != null) ...[
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(right: 8, top: 1),
              decoration: BoxDecoration(
                color: chipColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
            ),
          ],
          Expanded(
            child: Text(
              color,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color? _parseColor(String colorName) {
    final map = <String, Color>{
      '红': Colors.red,
      '橙': Colors.orange,
      'orange': Colors.orange,
      '黄': const Color(0xFFE6C200),
      'yellow': const Color(0xFFE6C200),
      '绿': Colors.green,
      'green': Colors.green,
      '蓝': Colors.blue,
      'blue': Colors.blue,
      '紫': Colors.purple,
      'purple': Colors.purple,
      '粉': Colors.pink,
      'pink': Colors.pink,
      '黑': Colors.black,
      'black': Colors.black,
      '白': Colors.white,
      'white': Colors.white,
      '灰': Colors.grey,
      'gray': Colors.grey,
      '棕': Colors.brown,
      'brown': Colors.brown,
      '米白': const Color(0xFFF5F5DC),
      'beige': const Color(0xFFF5F5DC),
      '金': const Color(0xFFFFD700),
      'gold': const Color(0xFFFFD700),
      '银': const Color(0xFFC0C0C0),
      'silver': const Color(0xFFC0C0C0),
    };
    for (final entry in map.entries) {
      if (colorName.contains(entry.key)) return entry.value;
    }
    return null;
  }

  Widget _buildTagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '#$text',
        style: const TextStyle(fontSize: 12, color: AppColors.accentGold),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(
                '重新识别',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _addToLibrary,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.add_box_outlined),
              label: const Text(
                '添加',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
