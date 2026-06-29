import '../ai_provider_type.dart';
import 'openai_compatible_provider.dart';

/// 讯飞星火 Spark Provider 实现（OpenAI 兼容 HTTP 接口）
///
/// 官方文档：
///   https://www.xfyun.cn/doc/spark/HTTP%E8%B0%83%E7%94%A8%E6%96%87%E6%A1%A3.html
/// 端点：https://spark-api-open.xf-yun.com/v1/chat/completions
/// 鉴权：`Authorization: Bearer {APIPassword}`
///
/// 约定：
/// - `config.apiKey` 填讯飞控制台的 APIPassword（在「星火大模型」服务页一键生成）
/// - `config.modelName` 填模型版本：`4.0Ultra` / `max-32k` / `generalv3.5` / `general` 等
///
/// 默认模型：4.0Ultra
///
/// 说明：相比早期 HMAC-SHA256 URL 签名方案，官方目前主推此 OpenAI 兼容接口，
/// 单 Key 即可调用，无需 APIKey + APISecret 配对，也无需按版本区分 path。
class SparkProvider extends OpenAiCompatibleProvider {
  @override
  AiProviderType get type => AiProviderType.spark;

  @override
  String get defaultBaseUrl => 'https://spark-api-open.xf-yun.com';

  // 星火 OpenAI 兼容接口不支持 response_format，关闭以避免 400
  @override
  bool get supportsResponseFormat => false;
}
