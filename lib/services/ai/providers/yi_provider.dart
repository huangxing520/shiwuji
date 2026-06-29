import '../ai_provider_type.dart';
import 'openai_compatible_provider.dart';

/// 零一万物 Yi Provider 实现（Yi-VL 多模态）
///
/// 官方文档：https://platform.lingyiwanwu.com/docs
/// 端点：https://api.lingyiwanwu.com/v1/chat/completions
/// 鉴权：`Authorization: Bearer {apiKey}`
///
/// 默认模型：yi-vl-plus
class YiProvider extends OpenAiCompatibleProvider {
  @override
  AiProviderType get type => AiProviderType.yi;

  @override
  String get defaultBaseUrl => 'https://api.lingyiwanwu.com';

  // Yi-VL 不支持 response_format，关闭以保证兼容
  @override
  bool get supportsResponseFormat => false;
}
