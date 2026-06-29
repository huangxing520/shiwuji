import '../ai_provider_type.dart';
import 'openai_compatible_provider.dart';

/// 字节豆包 Provider 实现（火山方舟）
///
/// 官方文档：https://www.volcengine.com/docs/82379
/// 端点：https://ark.cn-beijing.volces.com/api/v3/chat/completions
/// 鉴权：`Authorization: Bearer {apiKey}`
///
/// 注意：火山方舟用「接入点 ID（ep-xxxx）」作为 model 字段，用户需在
/// 火山方舟控制台创建接入点并在设置页填入。
///
/// 默认模型：ep-xxxxxxxx（占位，实际需用户填入自己的接入点 ID）
class DoubaoProvider extends OpenAiCompatibleProvider {
  @override
  AiProviderType get type => AiProviderType.doubao;

  @override
  String get defaultBaseUrl => 'https://ark.cn-beijing.volces.com/api/v3';

  /// 火山方舟 v3 接口路径与 OpenAI 标准不同：
  /// 完整端点为 `https://ark.cn-beijing.volces.com/api/v3/chat/completions`，
  /// 不能使用基类默认的 `/v1/chat/completions`（否则会拼成 `/api/v3/v1/chat/completions` 导致 404）。
  @override
  String get chatCompletionsPath => '/chat/completions';

  // 火山方舟不支持 response_format，关闭以避免 400
  @override
  bool get supportsResponseFormat => false;
}
