import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';
import 'package:shi_wu_ji/providers/profile_provider.dart';
import 'package:shi_wu_ji/services/ai/ai_models.dart';
import 'package:shi_wu_ji/services/ai/ai_provider_registry.dart';
import 'package:shi_wu_ji/services/ai/ai_provider_type.dart';
import 'package:shi_wu_ji/widgets/toast_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AiSettingsPage extends ConsumerStatefulWidget {
  const AiSettingsPage({super.key});

  @override
  ConsumerState<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends ConsumerState<AiSettingsPage> {
  AiProviderType _selectedProviderType = AiProviderType.gemini;
  String? _editingModelId;
  final _apiKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _modelNameController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _displayNameController = TextEditingController();

  List<AiProviderConfig> _savedConfigs = [];
  String? _activeModelId;
  bool _initialized = false;
  bool _testing = false;
  bool _saving = false;
  bool _loadingSaved = true;
  final Map<String, bool> _savedTesting = {};
  final Map<String, bool> _switching = {};

  /// 测试连接记录（最新在前）
  final List<_TestLogEntry> _testLogs = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _secretKeyController.dispose();
    _modelNameController.dispose();
    _baseUrlController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(aiConfigManagerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: configAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => Center(child: Text('加载失败：$e')),
          data: (config) {
            if (!_initialized) {
              _selectedProviderType = config.type;
              _activeModelId = config.id;
              _initialized = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _refreshSavedConfigs();
              });
            }
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 12),
                      _buildProviderPicker(),
                      const SizedBox(height: 16),
                      _buildSavedModelsSection(),
                      const SizedBox(height: 16),
                      _buildProviderConfigCard(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                      const SizedBox(height: 16),
                      _buildTestLogsSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _refreshSavedConfigs() async {
    setState(() => _loadingSaved = true);
    try {
      final configs = await ref
          .read(aiConfigManagerProvider.notifier)
          .loadAllSavedConfigs();
      final currentConfig = ref.read(aiConfigManagerProvider).value;
      if (mounted) {
        setState(() {
          _savedConfigs = configs;
          _activeModelId = currentConfig?.id;
          _loadingSaved = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSaved = false);
        ToastUtils.show(context, '加载已保存模型失败：$e');
      }
    }
  }

  void _clearForm() {
    _apiKeyController.clear();
    _secretKeyController.clear();
    _modelNameController.clear();
    _baseUrlController.clear();
    _displayNameController.clear();
    setState(() => _editingModelId = null);
  }

  void _loadModelToForm(AiProviderConfig config) {
    setState(() {
      _selectedProviderType = config.type;
      _editingModelId = config.id;
      _apiKeyController.text = config.apiKey;
      _secretKeyController.text = config.secretKey ?? '';
      _modelNameController.text = config.modelName ?? '';
      _baseUrlController.text = config.baseUrl ?? '';
      _displayNameController.text = config.displayName ?? '';
    });
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 20, 0),
      child: Row(
        children: [
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
          const Text(
            'AI 模型设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            '选择 AI 供应商',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AiProviderType.values.map((type) {
                  final meta = aiProviderMetas[type]!;
                  final selected = type == _selectedProviderType;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedProviderType = type;
                        _editingModelId = null;
                        _clearForm();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border.withValues(alpha: 0.3),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        meta.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedModelsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.save_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '已保存模型',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '选择当前使用模型，管理配置',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loadingSaved)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else if (_savedConfigs.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '暂无已保存模型，请在下方配置后保存',
                  style: TextStyle(fontSize: 13, color: AppColors.textHint),
                ),
              ),
            )
          else

           ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                children: _savedConfigs.map(_buildSavedModelItem).toList()))),
        ],
      ),
    );
  }

  Widget _buildSavedModelItem(AiProviderConfig config) {
    final meta = aiProviderMetas[config.type]!;
    final modelName = (config.modelName?.trim().isNotEmpty == true)
        ? config.modelName!
        : meta.defaultModel;
    final isTesting = _savedTesting[config.id] == true;
    final isSwitching = _switching[config.id] == true;
    final isActive = config.id == _activeModelId;
    final isEditing = config.id == _editingModelId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.08)
            : isEditing
            ? AppColors.primary.withValues(alpha: 0.04)
            : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              )
            : isEditing
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              )
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isActive
                      ? Icons.radio_button_checked
                      : Icons.smart_toy_outlined,
                  size: isActive ? 22 : 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            config.effectiveDisplayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '当前使用',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${meta.displayName} · $modelName',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: (isTesting || isSwitching || isActive)
                      ? null
                      : () => _setActiveModel(config),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isSwitching
                        ? const Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              isActive ? '已选中' : '设为当前',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? AppColors.primary.withValues(alpha: 0.7)
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: isTesting || isSwitching
                      ? null
                      : () => _editModel(config),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isEditing
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.border.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        isEditing ? '编辑中' : '编辑',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isEditing
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: isTesting || isSwitching
                      ? null
                      : () => _testSavedConnection(config),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.4),
                      ),
                    ),
                    child: isTesting
                        ? const Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : const Center(
                            child: Text(
                              '测试',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: isSwitching ? null : () => _deleteSavedModel(config),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '删除',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _setActiveModel(AiProviderConfig config) async {
    if (config.id == _activeModelId) return;

    setState(() => _switching[config.id] = true);
    try {
      await ref
          .read(aiConfigManagerProvider.notifier)
          .setActiveModel(config.id);
      await _refreshSavedConfigs();
      if (mounted) {
        ToastUtils.show(context, '已切换为 ${config.effectiveDisplayName}');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.show(context, '切换失败：$e');
      }
    } finally {
      if (mounted) setState(() => _switching[config.id] = false);
    }
  }

  void _editModel(AiProviderConfig config) {
    _loadModelToForm(config);
    ToastUtils.show(context, '正在编辑 ${config.effectiveDisplayName}');
  }

  Future<void> _testSavedConnection(AiProviderConfig config) async {
    setState(() => _savedTesting[config.id] = true);
    final meta = aiProviderMetas[config.type]!;
    final modelName = (config.modelName?.trim().isNotEmpty == true)
        ? config.modelName!
        : meta.defaultModel;
    final sw = Stopwatch()..start();
    try {
      final provider = AiProviderRegistry.instance.get(config.type);
      await provider.testConnection(config.toCallConfig());
      sw.stop();
      _addTestLog(
        name: config.effectiveDisplayName,
        provider: meta.displayName,
        model: modelName,
        success: true,
        elapsedMs: sw.elapsedMilliseconds,
      );
      if (!mounted) return;
      ToastUtils.show(context, '${config.effectiveDisplayName} 连接正常');
    } on AiException catch (e) {
      sw.stop();
      _addTestLog(
        name: config.effectiveDisplayName,
        provider: meta.displayName,
        model: modelName,
        success: false,
        elapsedMs: sw.elapsedMilliseconds,
        error: e.message,
      );
      if (!mounted) return;
      ToastUtils.show(context, '连接失败：${e.message}');
    } catch (e) {
      sw.stop();
      _addTestLog(
        name: config.effectiveDisplayName,
        provider: meta.displayName,
        model: modelName,
        success: false,
        elapsedMs: sw.elapsedMilliseconds,
        error: e.toString(),
      );
      if (!mounted) return;
      ToastUtils.show(context, '连接失败：$e');
    } finally {
      if (mounted) setState(() => _savedTesting[config.id] = false);
    }
  }

  Future<void> _deleteSavedModel(AiProviderConfig config) async {
    final isActive = config.id == _activeModelId;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '删除 ${config.effectiveDisplayName}？',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          isActive ? '该模型当前正在使用，删除后将自动切换到其他可用模型。' : '删除后该模型配置将被永久清除。',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              '取消',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(aiConfigManagerProvider.notifier).deleteModel(config.id);
        if (_editingModelId == config.id) {
          _clearForm();
        }
        await _refreshSavedConfigs();
        if (mounted) {
          ToastUtils.show(context, '已删除 ${config.effectiveDisplayName}');
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.show(context, '删除失败：$e');
        }
      }
    }
  }

  Widget _buildProviderConfigCard() {
    final meta = aiProviderMetas[_selectedProviderType]!;
    final isEditing = _editingModelId != null;

    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isEditing ? Icons.edit_outlined : Icons.add_circle_outline,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isEditing
                              ? '编辑 ${meta.displayName} 模型'
                              : '添加 ${meta.displayName} 模型',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (isEditing) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _clearForm,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '取消编辑',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: '自定义名称（可选，用于区分同一供应商不同模型）',
            controller: _displayNameController,
            hint: '例如：硅基流动 v4 Flash',
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'API Key',
            controller: _apiKeyController,
            hint: meta.apiKeyHint,
            obscure: true,
          ),
          if (meta.needsSecretKey) ...[
            const SizedBox(height: 14),
            _buildTextField(
              label: 'Secret Key',
              controller: _secretKeyController,
              hint: meta.secretKeyHint,
              obscure: true,
            ),
          ],
          const SizedBox(height: 14),
          _buildTextField(
            label: '模型名（可选，留空用默认）',
            controller: _modelNameController,
            hint: meta.defaultModel,
          ),
          if (meta.supportsCustomBaseUrl) ...[
            const SizedBox(height: 14),
            _buildTextField(
              label: 'BaseURL（可选，用于代理/中转）',
              controller: _baseUrlController,
              hint: AiProviderRegistry.instance
                  .get(_selectedProviderType)
                  .defaultBaseUrl,
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _launchUrl(meta.apiKeyHelpUrl),
            child: Row(
              children: [
                const Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '前往 ${meta.displayName} 获取 API Key →',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppColors.textHint.withValues(alpha: 0.7),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildButton(
            label: _saving
                ? '保存中…'
                : (_editingModelId != null ? '保存修改' : '保存模型'),
            icon: Icons.check,
            primary: true,
            onTap: _saving || _testing ? null : _save,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildButton(
            label: _testing ? '测试中…' : '测试连接',
            icon: Icons.bolt_outlined,
            primary: false,
            onTap: _testing || _saving ? null : _testConnection,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required bool primary,
    required VoidCallback? onTap,
  }) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: disabled
              ? (primary
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.cardBg.withValues(alpha: 0.6))
              : (primary ? AppColors.primary : AppColors.cardBg),
          borderRadius: BorderRadius.circular(14),
          border: primary
              ? null
              : Border.all(
                  color: AppColors.border.withValues(
                    alpha: disabled ? 0.2 : 0.4,
                  ),
                ),
          boxShadow: primary && !disabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: primary
                  ? Colors.white
                  : (disabled ? AppColors.textHint : AppColors.textSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: primary
                    ? Colors.white
                    : (disabled ? AppColors.textHint : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_apiKeyController.text.trim().isEmpty) {
      ToastUtils.show(context, '请先填写 API Key');
      return;
    }

    setState(() => _saving = true);
    try {
      final callConfig = AiCallConfig(
        apiKey: _apiKeyController.text,
        secretKey: _secretKeyController.text.isEmpty
            ? null
            : _secretKeyController.text,
        modelName: _modelNameController.text.isEmpty
            ? null
            : _modelNameController.text,
        baseUrl: _baseUrlController.text.isEmpty
            ? null
            : _baseUrlController.text,
      );

      final provider = AiProviderRegistry.instance.get(_selectedProviderType);
      await provider.testConnection(callConfig);

      await ref
          .read(aiConfigManagerProvider.notifier)
          .saveConfig(
            type: _selectedProviderType,
            apiKey: _apiKeyController.text,
            secretKey: _secretKeyController.text,
            modelName: _modelNameController.text,
            baseUrl: _baseUrlController.text,
            displayName: _displayNameController.text,
            existingId: _editingModelId,
            setAsActive: true,
          );

      _clearForm();
      await _refreshSavedConfigs();

      if (!mounted) return;
      ToastUtils.show(context, '保存成功，敏感信息已清除');
    } on AiException catch (e) {
      if (!mounted) return;
      ToastUtils.show(context, '连接失败，未保存：${e.message}');
    } catch (e) {
      if (!mounted) return;
      ToastUtils.show(context, '保存失败：$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _testConnection() async {
    if (_apiKeyController.text.trim().isEmpty) {
      ToastUtils.show(context, '请先填写 API Key');
      return;
    }

    setState(() => _testing = true);
    final meta = aiProviderMetas[_selectedProviderType]!;
    final modelName = _modelNameController.text.trim().isNotEmpty
        ? _modelNameController.text.trim()
        : meta.defaultModel;
    final displayName = _displayNameController.text.trim().isNotEmpty
        ? _displayNameController.text.trim()
        : '${meta.displayName} ($modelName)';
    final sw = Stopwatch()..start();
    try {
      final provider = AiProviderRegistry.instance.get(_selectedProviderType);
      await provider.testConnection(
        AiCallConfig(
          apiKey: _apiKeyController.text,
          secretKey: _secretKeyController.text.isEmpty
              ? null
              : _secretKeyController.text,
          modelName: _modelNameController.text.isEmpty
              ? null
              : _modelNameController.text,
          baseUrl: _baseUrlController.text.isEmpty
              ? null
              : _baseUrlController.text,
        ),
      );
      sw.stop();
      _addTestLog(
        name: displayName,
        provider: meta.displayName,
        model: modelName,
        success: true,
        elapsedMs: sw.elapsedMilliseconds,
      );
      if (!mounted) return;
      ToastUtils.show(context, '${meta.displayName} 连接正常');
    } on AiException catch (e) {
      sw.stop();
      _addTestLog(
        name: displayName,
        provider: meta.displayName,
        model: modelName,
        success: false,
        elapsedMs: sw.elapsedMilliseconds,
        error: e.message,
      );
      if (!mounted) return;
      ToastUtils.show(context, '连接失败：${e.message}');
    } catch (e) {
      sw.stop();
      _addTestLog(
        name: displayName,
        provider: meta.displayName,
        model: modelName,
        success: false,
        elapsedMs: sw.elapsedMilliseconds,
        error: e.toString(),
      );
      if (!mounted) return;
      ToastUtils.show(context, '连接失败：$e');
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// 添加一条测试记录（插入到列表头部，最多保留 20 条）
  void _addTestLog({
    required String name,
    required String provider,
    required String model,
    required bool success,
    required int elapsedMs,
    String? error,
  }) {
    setState(() {
      _testLogs.insert(
        0,
        _TestLogEntry(
          name: name,
          provider: provider,
          model: model,
          success: success,
          elapsedMs: elapsedMs,
          error: error,
          time: DateTime.now(),
        ),
      );
      if (_testLogs.length > 20) {
        _testLogs.removeLast();
      }
    });
  }

  /// 清空测试记录
  void _clearTestLogs() {
    setState(() => _testLogs.clear());
  }

  Widget _buildTestLogsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '测试记录',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '记录每次连接测试的结果',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_testLogs.isNotEmpty)
                GestureDetector(
                  onTap: _clearTestLogs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '清空',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_testLogs.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '暂无测试记录',
                  style: TextStyle(fontSize: 13, color: AppColors.textHint),
                ),
              ),
            )
          else
             ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Column(
                children: _testLogs.map(_buildTestLogItem).toList()))),
        ],
      ),
    );
  }

  Widget _buildTestLogItem(_TestLogEntry entry) {
    final timeStr =
        '${entry.time.hour.toString().padLeft(2, '0')}:'
        '${entry.time.minute.toString().padLeft(2, '0')}:'
        '${entry.time.second.toString().padLeft(2, '0')}';
    final successColor = entry.success ? Colors.green : Colors.red;
    final successIcon = entry.success ? Icons.check_circle : Icons.cancel;
    final successText = entry.success ? '成功' : '失败';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: successColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(successIcon, size: 18, color: successColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  successText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: successColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${entry.provider} · ${entry.model}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$timeStr · ${entry.elapsedMs}ms',
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ),
          if (!entry.success && entry.error != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                entry.error!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.withValues(alpha: 0.8),
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 测试连接记录条目
class _TestLogEntry {
  final String name;
  final String provider;
  final String model;
  final bool success;
  final int elapsedMs;
  final String? error;
  final DateTime time;

  const _TestLogEntry({
    required this.name,
    required this.provider,
    required this.model,
    required this.success,
    required this.elapsedMs,
    this.error,
    required this.time,
  });
}
