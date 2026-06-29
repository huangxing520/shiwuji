import '../ai_provider_type.dart';
import 'openai_compatible_provider.dart';

/// NVIDIA NIM Provider 实现
///
/// 官方文档：https://docs.api.nvidia.com/
/// 端点：https://integrate.api.nvidia.com/v1/chat/completions
/// 鉴权：`Authorization: Bearer nvapi-...`
///
/// 支持多模态模型，例如：
/// - minimaxai/minimax-m3（多模态）
/// - 其他视觉模型可在设置页自行配置
///
/// 图片以 base64 data URI 形式发送，与 OpenAI 视觉接口格式一致。
class NvidiaProvider extends OpenAiCompatibleProvider {
  @override
  AiProviderType get type => AiProviderType.nvidia;

  @override
  String get defaultBaseUrl => 'https://integrate.api.nvidia.com';
}
