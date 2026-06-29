import '../ai_provider_type.dart';
import 'openai_compatible_provider.dart';

/// 智谱 AI Provider 实现（GLM-4V 系列多模态模型）
///
/// 官方文档：https://open.bigmodel.cn/dev/api
/// 端点：https://open.bigmodel.cn/api/paas/v4/chat/completions
/// 鉴权：`Authorization: Bearer {apiKey}`（apiKey 形如 `{id}.{secret}`）
///
/// 默认模型：glm-4v-plus
class ZhipuProvider extends OpenAiCompatibleProvider {
  @override
  AiProviderType get type => AiProviderType.zhipu;

  @override
  String get defaultBaseUrl => 'https://open.bigmodel.cn/api/paas';

  @override
  String get chatCompletionsPath => '/v4/chat/completions';

  // 智谱老版本不支持 response_format: json_object，关闭以保证兼容
  @override
  bool get supportsResponseFormat => false;
}
