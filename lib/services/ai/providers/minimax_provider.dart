import '../ai_provider_type.dart';
import 'openai_compatible_provider.dart';

/// MiniMax Provider 实现
///
/// 官方文档：https://platform.minimaxi.com/document/ChatCompletion
/// 端点：https://api.minimax.chat/v1/chat/completions（OpenAI 兼容 v2）
/// 鉴权：`Authorization: Bearer {apiKey}`
///
/// 默认模型：MiniMax-Text-01
///
/// 注意：MiniMax-Text-01 主要是文本模型，需视觉能力可在
/// 设置页改模型为 `MiniMax-VL-01`（如平台提供）。
class MinimaxProvider extends OpenAiCompatibleProvider {
  @override
  AiProviderType get type => AiProviderType.minimax;

  @override
  String get defaultBaseUrl => 'https://api.minimax.chat';

  // MiniMax 不支持 response_format: json_object
  @override
  bool get supportsResponseFormat => false;
}
