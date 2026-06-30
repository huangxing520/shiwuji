import '../ai_provider_type.dart';
import 'openai_compatible_provider.dart';

/// 小米 MiMo Provider 实现（MiMo-VL 视觉模型）
///
/// 小米 MiMo-VL 是开源视觉模型，官方未提供独立公共 API 服务，推荐通过
/// 聚合平台（硅基流动 / ModelScope 等）以 OpenAI 兼容接口调用。
///
/// 默认 BaseURL 指向硅基流动，用户可自行修改为其他兼容平台。
/// 默认模型：XiaomiMiMo/MiMo-VL-7B-Instruct
class MimoProvider extends OpenAiCompatibleProvider {
  @override
  AiProviderType get type => AiProviderType.mimo;

  @override
  String get defaultBaseUrl => 'https://api.xiaomimimo.com';

  // 通过聚合平台调用，关闭 response_format 以保证开源模型兼容
  @override
  bool get supportsResponseFormat => false;
}
