import '../ai_provider_type.dart';
import 'openai_compatible_provider.dart';

/// OpenAI Provider 实现（GPT-4o 等多模态模型）
///
/// 官方文档：https://platform.openai.com/docs/api-reference/chat
/// 端点：https://api.openai.com/v1/chat/completions
/// 鉴权：`Authorization: Bearer {apiKey}`
///
/// 默认模型：gpt-4o-mini
class OpenAiProvider extends OpenAiCompatibleProvider {
  @override
  AiProviderType get type => AiProviderType.openai;

  @override
  String get defaultBaseUrl => 'https://api.openai.com';
}
