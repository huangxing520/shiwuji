import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'ai_provider_type.dart';

/// AI Provider 调用统一异常
class AiException implements Exception {
  final String message;
  final String? providerId;
  final int? statusCode;

  const AiException(this.message, {this.providerId, this.statusCode});

  @override
  String toString() => 'AiException[$providerId]($statusCode): $message';
}

/// 图片识别统一结果
class AiVisionResult {
  /// 物体名称（2-8 字中文，如「白色陶瓷马克杯」「罗技机械键盘」）
  final String name;

  /// 物品大类（如「数码电子」「厨房用品」）
  final String? category;

  /// 品牌名称，无法识别时为空字符串
  final String brand;

  /// 主要颜色描述
  final String color;

  /// 材质描述
  final String material;

  /// 核心特征描述（80字以内，包含外观特点、功能用途等）
  final String features;

  /// 简短一句话描述（20-40字）
  final String description;

  /// 新旧程度：全新/九成新/八成新/七成新/有使用痕迹/无法判断
  final String condition;

  /// 建议标签数组
  final List<String> suggestedTags;

  /// 实际使用的模型名（用于性能监控展示）
  final String model;

  /// 调用耗时（毫秒）
  final int elapsedMs;

  const AiVisionResult({
    required this.name,
    required this.description,
    required this.model,
    required this.elapsedMs,
    this.category,
    this.brand = '',
    this.color = '',
    this.material = '',
    this.features = '',
    this.condition = '无法判断',
    this.suggestedTags = const [],
  });
}

/// Provider 调用配置（由设置页注入）
class AiCallConfig {
  /// API Key（必填）
  final String apiKey;

  /// Secret Key（仅文心一言需要）
  final String? secretKey;

  /// 模型名（可选，缺省时用 provider 默认模型）
  final String? modelName;

  /// 自定义 BaseURL（可选，用于代理/中转）
  final String? baseUrl;

  const AiCallConfig({
    required this.apiKey,
    this.secretKey,
    this.modelName,
    this.baseUrl,
  });
}

/// 用户配置（持久化在 settings 表，由 [AiConfigManager] 管理）
/// 支持同一供应商下保存多个不同模型配置，通过 [id] 唯一区分
class AiProviderConfig {
  /// 配置唯一ID
  final String id;

  /// 供应商类型
  final AiProviderType type;

  /// API Key
  final String apiKey;

  /// Secret Key（仅文心一言需要）
  final String? secretKey;

  /// 模型名称
  final String? modelName;

  /// 自定义BaseURL
  final String? baseUrl;

  /// 用户自定义显示名称（可选，为空时自动生成）
  final String? displayName;

  const AiProviderConfig({
    required this.id,
    required this.type,
    required this.apiKey,
    this.secretKey,
    this.modelName,
    this.baseUrl,
    this.displayName,
  });

  /// 是否已配置（API Key 非空视为已配置）
  bool get isConfigured => apiKey.trim().isNotEmpty;

  /// 显示名称：用户自定义 > 模型名 > 默认模型名
  String get effectiveDisplayName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }
    final meta = aiProviderMetas[type]!;
    final model = modelName?.trim().isNotEmpty == true
        ? modelName!.trim()
        : meta.defaultModel;
    return '${meta.displayName} · $model';
  }

  /// 转为调用时使用的 [AiCallConfig]
  AiCallConfig toCallConfig() => AiCallConfig(
    apiKey: apiKey,
    secretKey: secretKey,
    modelName: modelName,
    baseUrl: baseUrl,
  );

  /// 创建配置副本
  AiProviderConfig copyWith({
    String? id,
    AiProviderType? type,
    String? apiKey,
    String? secretKey,
    String? modelName,
    String? baseUrl,
    String? displayName,
  }) {
    return AiProviderConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      apiKey: apiKey ?? this.apiKey,
      secretKey: secretKey ?? this.secretKey,
      modelName: modelName ?? this.modelName,
      baseUrl: baseUrl ?? this.baseUrl,
      displayName: displayName ?? this.displayName,
    );
  }
}

/// 共享图片识别 prompt（默认回退版本，当本地提示词文件读取失败时使用）
///
/// 要求模型以严格 JSON 输出，便于在 [AiProvider] 实现中统一解析。
const String kAiVisionPrompt = '''
请识别图片中的主要物体，仔细观察其外观、品牌标识、材质和特征。以严格 JSON 格式返回结果（不要包含 ```json 标记或任何其他文字，只返回纯JSON）。

JSON 字段说明：
- name：物体名称，2-8 个中文字（如"白色陶瓷马克杯"、"罗技机械键盘"），尽量包含颜色、品牌等关键信息
- category：物品大类，必须严格从以下选项中选择最合适的一个（必须使用原词，禁止改写、扩展或添加任何后缀）：
  "数码"、"家电"、"护肤"、"厨房"、"衣物"、"书籍"、"收纳"、"玩具"、"运动"、"文具"、"钥匙"、"工具"
- brand：品牌名称，若无法识别则返回空字符串
- color：主要颜色描述
- material：材质描述，无法判断则返回空字符串
- features：物品核心特征描述，80字以内
- description：简短一句话描述，20-40字
- condition：物品新旧程度，从以下选项选择："全新"、"九成新"、"八成新"、"七成新"、"有使用痕迹"、"无法判断"
- suggestedTags：建议标签数组，2-4个关键词标签

分类选择指南：
- 数码：手机、电脑、耳机、相机、充电器、数据线等电子产品及配件
- 家电：电视、冰箱、洗衣机、吸尘器、电饭煲等家用电器
- 护肤：精华、面霜、乳液、化妆品等护肤美妆用品
- 厨房：锅具、餐具、刀具、烹饪用具等厨房用品
- 衣物：衣服、裤子、鞋子、帽子、箱包等穿戴用品
- 书籍：图书、杂志、音像制品等
- 收纳：收纳箱、储物盒、整理架等收纳用品
- 玩具：玩偶、积木、模型、桌游等玩具
- 运动：健身器材、球类、运动护具等运动用品
- 文具：笔、本、尺、剪刀、胶带等文具办公用品
- 钥匙：各类钥匙、门禁卡等
- 工具：螺丝刀、锤子、扳手、量具等工具

只返回 JSON，例如：
{"name":"白色陶瓷马克杯","category":"厨房","brand":"","color":"白色","material":"陶瓷","features":"圆柱形杯身，带蓝色把手","description":"简约白色陶瓷马克杯，带蓝色把手","condition":"九成新","suggestedTags":["日常用品","饮水器具"]}
''';

/// 从模型响应文本中提取 JSON 对象
///
/// 处理常见情况：模型在 JSON 外包了 ```json ... ``` 标记、包含额外文字等。
Map<String, dynamic> parseJsonFromResponse(String text) {
  var s = text.trim();

  // 去除 ```json ... ``` 或 ``` ... ``` 包裹
  if (s.startsWith('```')) {
    final firstNewline = s.indexOf('\n');
    if (firstNewline > 0) s = s.substring(firstNewline + 1);
    if (s.endsWith('```')) s = s.substring(0, s.length - 3);
    s = s.trim();
  }

  // 提取第一个 {...}
  final start = s.indexOf('{');
  final end = s.lastIndexOf('}');
  if (start >= 0 && end > start) {
    s = s.substring(start, end + 1);
  }

  // 去除尾随逗号
  s = s.replaceAll(RegExp(r',\s*}'), '}').replaceAll(RegExp(r',\s*]'), ']');

  final decoded = jsonDecode(s);
  if (decoded is Map<String, dynamic>) return decoded;
  throw FormatException('响应不是 JSON 对象: $s');
}

/// 从解析后的 JSON 对象构建 AiVisionResult
AiVisionResult buildVisionResultFromJson(
  Map<String, dynamic> json, {
  required String model,
  required int elapsedMs,
}) {
  List<String> parseTags(dynamic tags) {
    if (tags is List) {
      return tags
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  return AiVisionResult(
    name: (json['name'] ?? '未知物体').toString().trim(),
    category: json['category']?.toString().trim(),
    brand: (json['brand'] ?? '').toString().trim(),
    color: (json['color'] ?? '').toString().trim(),
    material: (json['material'] ?? '').toString().trim(),
    features: (json['features'] ?? '').toString().trim(),
    description: (json['description'] ?? '').toString().trim(),
    condition: (json['condition'] ?? '无法判断').toString().trim(),
    suggestedTags: parseTags(json['suggestedTags']),
    model: model,
    elapsedMs: elapsedMs,
  );
}

/// AI 调用 Debug 日志工具
///
/// 仅在 debug 模式（kDebugMode）下输出，release 模式下自动静默。
/// 敏感信息（API Key）自动打码。
class AiDebugLog {
  AiDebugLog._();

  /// 全局开关（debug 模式默认开启，可通过设置关闭）
  static bool enabled = kDebugMode;

  static const _tag = '[AI]';

  /// 打码 API Key：仅保留前 4 位和后 4 位
  static String maskKey(String? key) {
    if (key == null || key.isEmpty) return '(empty)';
    if (key.length <= 8) return '****';
    return '${key.substring(0, 4)}****${key.substring(key.length - 4)}';
  }

  static void _log(String msg) {
    if (enabled) debugPrint('$_tag $msg');
  }

  /// 发起请求
  static void request({
    required String provider,
    required String model,
    required String endpoint,
    required String apiKey,
    int? imageSizeBytes,
    String? prompt,
    Map<String, dynamic>? extra,
  }) {
    final buf = StringBuffer()
      ..writeln('→ 请求 [$provider] model=$model')
      ..writeln('  endpoint: $endpoint')
      ..writeln('  apiKey: ${maskKey(apiKey)}');
    if (imageSizeBytes != null) {
      buf.writeln(
        '  imageSize: ${(imageSizeBytes / 1024).toStringAsFixed(1)} KB',
      );
    }
    if (prompt != null) {
      final preview = prompt.length > 200
          ? '${prompt.substring(0, 200)}...'
          : prompt;
      buf.writeln('  prompt: $preview');
    }
    if (extra != null && extra.isNotEmpty) {
      extra.forEach((k, v) => buf.writeln('  $k: $v'));
    }
    _log(buf.toString().trimRight());
  }

  /// 收到响应
  static void response({
    required String provider,
    required String model,
    required int statusCode,
    required int elapsedMs,
    String? rawBody,
    Map<String, dynamic>? parsed,
  }) {
    final buf = StringBuffer()
      ..writeln('← 响应 [$provider] model=$model')
      ..writeln('  status: $statusCode, elapsed: ${elapsedMs}ms');
    if (rawBody != null) {
      final preview = rawBody.length > 500
          ? '${rawBody.substring(0, 500)}...'
          : rawBody;
      buf.writeln('  body: $preview');
    }
    if (parsed != null && parsed.isNotEmpty) {
      buf.writeln('  parsed: ${jsonEncode(parsed)}');
    }
    _log(buf.toString().trimRight());
  }

  /// 请求出错
  static void error({
    required String provider,
    required String model,
    required Object error,
    int? statusCode,
    int? elapsedMs,
  }) {
    final buf = StringBuffer()
      ..writeln('✗ 错误 [$provider] model=$model')
      ..writeln('  error: $error');
    if (statusCode != null) buf.writeln('  status: $statusCode');
    if (elapsedMs != null) buf.writeln('  elapsed: ${elapsedMs}ms');
    _log(buf.toString().trimRight());
  }
}
