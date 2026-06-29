import '../ai_provider_type.dart';
import 'openai_compatible_provider.dart';

/// DeepSeek Provider 实现
///
/// 官方文档：https://api-docs.deepseek.com/
/// 端点：https://api.deepseek.com/v1/chat/completions
/// 鉴权：`Authorization: Bearer {apiKey}`
///
/// 默认模型：deepseek-chat（纯文本）
///
/// 注意：DeepSeek 官方 API 目前主要是文本模型。若需视觉识别，可在
/// 设置页 BaseURL 切换到第三方中转 / 硅基流动等平台，并填入对应的
/// DeepSeek-VL 模型名（如 `deepseek-ai/deepseek-vl2`）。
class DeepSeekProvider extends OpenAiCompatibleProvider {
  @override
  AiProviderType get type => AiProviderType.deepseek;

  @override
  String get defaultBaseUrl => 'https://api.deepseek.com';

  // DeepSeek 支持 response_format，开启以稳定 JSON 输出
  @override
  bool get supportsResponseFormat => true;
}
