import '../ai_provider_type.dart';
import 'openai_compatible_provider.dart';

/// 硅基流动 SiliconFlow Provider 实现
///
/// 官方文档：https://docs.siliconflow.cn/api-reference
/// 端点：https://api.siliconflow.cn/v1/chat/completions
/// 鉴权：`Authorization: Bearer {apiKey}`
///
/// 硅基流动是聚合推理平台，一个 API Key 可调用多种开源 VL 模型：
/// - Qwen/Qwen2.5-VL-72B-Instruct（默认，效果最好）
/// - OpenGVLab/InternVL2-Llama3-76B
/// - deepseek-ai/deepseek-vl2
/// - XiaomiMiMo/MiMo-VL-7B-Instruct
/// - 等等
///
/// 默认模型：Qwen/Qwen2.5-VL-72B-Instruct
class SiliconflowProvider extends OpenAiCompatibleProvider {
  @override
  AiProviderType get type => AiProviderType.siliconflow;

  @override
  String get defaultBaseUrl => 'https://api.siliconflow.cn';

  // 硅基流动部分模型支持 response_format，但开源 VL 模型多不支持，关闭以保证兼容
  @override
  bool get supportsResponseFormat => false;
}
