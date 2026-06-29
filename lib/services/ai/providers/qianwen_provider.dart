import '../ai_provider_type.dart';
import 'openai_compatible_provider.dart';

/// 阿里通义千问 Provider 实现（Qwen-VL 系列多模态模型）
///
/// 官方文档：https://help.aliyun.com/zh/dashscope/developer-reference/api-details
/// DashScope OpenAI 兼容模式：可直接复用 OpenAI Chat Completions 格式
/// 端点：https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions
/// 鉴权：`Authorization: Bearer {apiKey}`
///
/// 默认模型：qwen-vl-max
class QianwenProvider extends OpenAiCompatibleProvider {
  @override
  AiProviderType get type => AiProviderType.qianwen;

  @override
  String get defaultBaseUrl => 'https://dashscope.aliyuncs.com';

  @override
  String get chatCompletionsPath => '/compatible-mode/v1/chat/completions';

  // DashScope 兼容模式不支持 response_format，关闭以避免 400
  @override
  bool get supportsResponseFormat => false;
}
