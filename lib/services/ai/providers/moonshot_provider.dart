import '../ai_provider_type.dart';
import 'openai_compatible_provider.dart';

/// 月之暗面 Kimi Provider 实现
///
/// 官方文档：https://platform.moonshot.cn/docs
/// 端点：https://api.moonshot.cn/v1/chat/completions
/// 鉴权：`Authorization: Bearer {apiKey}`
///
/// 默认模型：moonshot-v1-8k-vision-preview（支持视觉）
class MoonshotProvider extends OpenAiCompatibleProvider {
  @override
  AiProviderType get type => AiProviderType.moonshot;

  @override
  String get defaultBaseUrl => 'https://api.moonshot.cn';

  // Kimi 视觉预览版不支持 response_format，关闭以保证兼容
  @override
  bool get supportsResponseFormat => false;
}
