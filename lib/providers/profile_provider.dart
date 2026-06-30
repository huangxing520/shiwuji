import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../daos/settings_dao.dart';
import '../services/ai/ai_models.dart';
import '../services/ai/ai_provider.dart';
import '../services/ai/ai_provider_registry.dart';
import '../services/ai/ai_provider_type.dart';
import '../services/encryption_service.dart';
import 'database_provider.dart';
import 'item_providers.dart';
import 'storage_providers.dart';
import 'category_provider.dart';

part 'generated/profile_provider.g.dart';

String _encryptValue(String value) {
  if (value.isEmpty) return '';
  return 'enc:${EncryptionService.instance.encrypt(value)}';
}

String _decryptValue(String? encrypted) {
  if (encrypted == null || encrypted.isEmpty) return '';
  if (encrypted.startsWith('enc:')) {
    return EncryptionService.instance.decrypt(encrypted.substring(4));
  }
  return encrypted;
}

/// 用户资料（昵称 + 头像 emoji）
@riverpod
class ProfileManager extends _$ProfileManager {
  @override
  Future<Map<String, String>> build() async {
    final dao = ref.watch(settingsDaoProvider);
    final all = await dao.getAllSettings();
    return {
      'nickname': all['nickname'] ?? '小橘',
      'avatar_emoji': all['avatar_emoji'] ?? '🧑',
    };
  }

  SettingsDao get _dao => ref.read(settingsDaoProvider);

  Future<void> updateNickname(String nickname) async {
    await _dao.setValue('nickname', nickname);
    ref.invalidateSelf();
  }

  Future<void> updateAvatarEmoji(String emoji) async {
    await _dao.setValue('avatar_emoji', emoji);
    ref.invalidateSelf();
  }
}

/// 个人中心数据统计
///
/// 通过监听 itemsProvider / roomsProvider / categoryManagerProvider，
/// 使「数据概览」随数据库变化实时刷新，避免展示过期或空数据。
/// 物品数量与总价值直接复用 [itemCountProvider] / [totalValueProvider]
/// （派生自内存中的 itemsProvider，免去额外 SQL，并与首页口径一致）。
@riverpod
Future<Map<String, dynamic>> profileStats(Ref ref) async {
  final itemCount = ref.watch(itemCountProvider);
  final totalValue = ref.watch(totalValueProvider);
  final rooms = await ref.watch(roomsProvider.future);
  final categories = await ref.watch(categoryManagerProvider.future);

  return {
    'itemCount': itemCount,
    'totalValue': totalValue.toDouble(),
    'roomCount': rooms.length,
    'categoryCount': categories.length,
  };
}

/// 多 AI Provider 配置管理
///
/// 支持同一供应商下保存多个不同模型配置，每个配置有唯一ID
/// 所有敏感配置（API Key、Secret Key、模型名、BaseURL）均使用 AES-256-CBC 加密存储
/// 加密前缀 enc: 区分加密数据与旧版明文数据（自动兼容迁移）
@riverpod
class AiConfigManager extends _$AiConfigManager {
  static const _activeModelIdKey = 'ai_active_model_id';
  static const _modelIdsKey = 'ai_model_ids';
  static const _modelPrefix = 'ai_model_';
  static const _typeSuffix = '_type';
  static const _apiKeySuffix = '_apiKey';
  static const _secretKeySuffix = '_secretKey';
  static const _modelNameSuffix = '_modelName';
  static const _baseUrlSuffix = '_baseUrl';
  static const _displayNameSuffix = '_displayName';

  @override
  Future<AiProviderConfig> build() async {
    final dao = ref.read(settingsDaoProvider);
    await _migrateLegacyData(dao);
    final activeId = _decryptValue(await dao.getValue(_activeModelIdKey));
    if (activeId.isNotEmpty) {
      final loaded = await _loadConfigById(dao, activeId);
      if (loaded != null) return loaded;
    }
    return _createDefaultConfig();
  }

  SettingsDao get _dao => ref.read(settingsDaoProvider);

  AiProviderConfig _createDefaultConfig() {
    return AiProviderConfig(
      id: _generateId(),
      type: AiProviderType.gemini,
      apiKey: '',
    );
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final random = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    return 'm_${timestamp}_$random';
  }

  AiProviderType _parseType(String? s) {
    if (s == null || s.isEmpty) return AiProviderType.gemini;
    return AiProviderType.values.firstWhere(
      (t) => t.name == s,
      orElse: () => AiProviderType.gemini,
    );
  }

  String _modelKey(String id, String suffix) => '$_modelPrefix${id}_$suffix';

  Future<AiProviderConfig?> _loadConfigById(SettingsDao dao, String id) async {
    try {
      final typeStr = _decryptValue(
        await dao.getValue(_modelKey(id, _typeSuffix)),
      );
      if (typeStr.isEmpty) return null;
      final type = _parseType(typeStr);
      final apiKey = _decryptValue(
        await dao.getValue(_modelKey(id, _apiKeySuffix)),
      );
      if (apiKey.isEmpty) return null;
      final secretKey = _decryptValue(
        await dao.getValue(_modelKey(id, _secretKeySuffix)),
      );
      final modelName = _decryptValue(
        await dao.getValue(_modelKey(id, _modelNameSuffix)),
      );
      final baseUrl = _decryptValue(
        await dao.getValue(_modelKey(id, _baseUrlSuffix)),
      );
      final displayName = _decryptValue(
        await dao.getValue(_modelKey(id, _displayNameSuffix)),
      );
      return AiProviderConfig(
        id: id,
        type: type,
        apiKey: apiKey,
        secretKey: secretKey.isEmpty ? null : secretKey,
        modelName: modelName.isEmpty ? null : modelName,
        baseUrl: baseUrl.isEmpty ? null : baseUrl,
        displayName: displayName.isEmpty ? null : displayName,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> _getAllModelIds(SettingsDao dao) async {
    final idsStr = _decryptValue(await dao.getValue(_modelIdsKey));
    if (idsStr.isEmpty) return [];
    return idsStr.split(',').where((id) => id.trim().isNotEmpty).toList();
  }

  Future<void> _saveModelIds(SettingsDao dao, List<String> ids) async {
    await dao.setValue(_modelIdsKey, _encryptValue(ids.join(',')));
  }

  Future<void> _saveConfig(SettingsDao dao, AiProviderConfig config) async {
    await dao.setValue(
      _modelKey(config.id, _typeSuffix),
      _encryptValue(config.type.name),
    );
    await dao.setValue(
      _modelKey(config.id, _apiKeySuffix),
      _encryptValue(config.apiKey),
    );
    await dao.setValue(
      _modelKey(config.id, _secretKeySuffix),
      _encryptValue(config.secretKey ?? ''),
    );
    await dao.setValue(
      _modelKey(config.id, _modelNameSuffix),
      _encryptValue(config.modelName ?? ''),
    );
    await dao.setValue(
      _modelKey(config.id, _baseUrlSuffix),
      _encryptValue(config.baseUrl ?? ''),
    );
    await dao.setValue(
      _modelKey(config.id, _displayNameSuffix),
      _encryptValue(config.displayName ?? ''),
    );
  }

  Future<void> _deleteConfigById(SettingsDao dao, String id) async {
    for (final suffix in [
      _typeSuffix,
      _apiKeySuffix,
      _secretKeySuffix,
      _modelNameSuffix,
      _baseUrlSuffix,
      _displayNameSuffix,
    ]) {
      await dao.setValue(_modelKey(id, suffix), '');
    }
  }

  /// 旧版数据迁移：按type存储的格式迁移为按id存储
  Future<void> _migrateLegacyData(SettingsDao dao) async {
    final existingIds = await _getAllModelIds(dao);
    if (existingIds.isNotEmpty) return;

    final legacyTypeKey = 'ai_provider_type';
    final legacyApiKeyPrefix = 'ai_api_key_';
    final legacySecretKeyPrefix = 'ai_secret_key_';
    final legacyModelPrefix = 'ai_model_';
    final legacyBaseUrlPrefix = 'ai_base_url_';

    final legacyTypeStr = _decryptValue(await dao.getValue(legacyTypeKey));
    final legacyActiveType = _parseType(legacyTypeStr);
    final newIds = <String>[];
    String? activeId;

    for (final type in AiProviderType.values) {
      final apiKey = _decryptValue(
        await dao.getValue('$legacyApiKeyPrefix${type.name}'),
      );
      if (apiKey.trim().isEmpty) continue;

      final id = type.name;
      final secretKey = _decryptValue(
        await dao.getValue('$legacySecretKeyPrefix${type.name}'),
      );
      final modelName = _decryptValue(
        await dao.getValue('$legacyModelPrefix${type.name}'),
      );
      final baseUrl = _decryptValue(
        await dao.getValue('$legacyBaseUrlPrefix${type.name}'),
      );

      final config = AiProviderConfig(
        id: id,
        type: type,
        apiKey: apiKey,
        secretKey: secretKey.isEmpty ? null : secretKey,
        modelName: modelName.isEmpty ? null : modelName,
        baseUrl: baseUrl.isEmpty ? null : baseUrl,
      );

      await _saveConfig(dao, config);
      newIds.add(id);

      if (type == legacyActiveType) {
        activeId = id;
      }
    }

    if (newIds.isNotEmpty) {
      await _saveModelIds(dao, newIds);
      if (activeId != null) {
        await dao.setValue(_activeModelIdKey, _encryptValue(activeId));
      }
    }
  }

  /// 保存新模型配置或更新现有配置
  Future<AiProviderConfig> saveConfig({
    required AiProviderType type,
    required String apiKey,
    String? secretKey,
    String? modelName,
    String? baseUrl,
    String? displayName,
    String? existingId,
    bool setAsActive = true,
  }) async {
    final dao = _dao;
    final id = existingId ?? _generateId();
    final config = AiProviderConfig(
      id: id,
      type: type,
      apiKey: apiKey.trim(),
      secretKey: secretKey?.trim().isEmpty == true ? null : secretKey?.trim(),
      modelName: modelName?.trim().isEmpty == true ? null : modelName?.trim(),
      baseUrl: baseUrl?.trim().isEmpty == true ? null : baseUrl?.trim(),
      displayName: displayName?.trim().isEmpty == true
          ? null
          : displayName?.trim(),
    );

    await _saveConfig(dao, config);

    final ids = await _getAllModelIds(dao);
    if (!ids.contains(id)) {
      ids.add(id);
      await _saveModelIds(dao, ids);
    }

    if (setAsActive) {
      await dao.setValue(_activeModelIdKey, _encryptValue(id));
      state = AsyncData(config);
    }
    return config;
  }

  /// 设置指定模型为当前激活模型
  Future<void> setActiveModel(String id) async {
    final config = await _loadConfigById(_dao, id);
    if (config == null) return;
    await _dao.setValue(_activeModelIdKey, _encryptValue(id));
    state = AsyncData(config);
  }

  /// 删除指定模型配置
  Future<void> deleteModel(String id) async {
    final dao = _dao;
    final currentConfig = state.value;
    final currentActiveId = currentConfig?.id;

    await _deleteConfigById(dao, id);

    final ids = await _getAllModelIds(dao);
    ids.remove(id);
    await _saveModelIds(dao, ids);

    if (currentActiveId == id) {
      if (ids.isNotEmpty) {
        await dao.setValue(_activeModelIdKey, _encryptValue(ids.first));
        final newConfig = await _loadConfigById(dao, ids.first);
        if (newConfig != null) {
          state = AsyncData(newConfig);
        }
      } else {
        await dao.setValue(_activeModelIdKey, '');
        state = AsyncData(_createDefaultConfig());
      }
    }
  }

  /// 根据ID获取配置
  Future<AiProviderConfig?> getConfigById(String id) async {
    return _loadConfigById(_dao, id);
  }

  /// 获取所有已保存的模型配置
  Future<List<AiProviderConfig>> loadAllSavedConfigs() async {
    final dao = _dao;
    final ids = await _getAllModelIds(dao);
    final configs = <AiProviderConfig>[];
    for (final id in ids) {
      final config = await _loadConfigById(dao, id);
      if (config != null && config.apiKey.trim().isNotEmpty) {
        configs.add(config);
      }
    }
    return configs;
  }

  /// 创建新的空白配置（用于新增模型表单）
  AiProviderConfig createNewEmptyConfig(AiProviderType type) {
    return AiProviderConfig(id: '', type: type, apiKey: '');
  }
}

/// 当前生效的 [AiProvider] 实例（基于 [AiConfigManager] 配置动态解析）
@riverpod
AiProvider activeAiProvider(Ref ref) {
  final configAsync = ref.watch(aiConfigManagerProvider);
  return configAsync.when(
    data: (config) => AiProviderRegistry.instance.get(config.type),
    loading: () => AiProviderRegistry.instance.get(AiProviderType.gemini),
    error: (e, _) => AiProviderRegistry.instance.get(AiProviderType.gemini),
  );
}

/// 所有已保存的模型配置（用于扫描页模型选择器）
@riverpod
class SavedAiConfigs extends _$SavedAiConfigs {
  @override
  Future<List<AiProviderConfig>> build() async {
    final manager = ref.watch(aiConfigManagerProvider.notifier);
    return manager.loadAllSavedConfigs();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final manager = ref.read(aiConfigManagerProvider.notifier);
      return manager.loadAllSavedConfigs();
    });
  }
}

/// 一次 AI 调用的性能记录（内存中保留最近 N 次，重启清空）
@immutable
class AiCallLog {
  final AiProviderType provider;
  final String model;
  final bool success;
  final int elapsedMs;
  final String? error;
  final DateTime timestamp;

  const AiCallLog({
    required this.provider,
    required this.model,
    required this.success,
    required this.elapsedMs,
    required this.timestamp,
    this.error,
  });
}

/// 性能监控：在内存中累积最近 50 次调用记录
@riverpod
class AiCallLogs extends _$AiCallLogs {
  @override
  List<AiCallLog> build() => const [];

  void record(AiCallLog log) {
    state = [...state, log].toList(growable: false);
    if (state.length > 50) {
      state = state.sublist(state.length - 50);
    }
  }

  void clear() => state = const [];
}
