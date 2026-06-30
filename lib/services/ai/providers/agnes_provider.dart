import '../ai_provider_type.dart';
import 'openai_compatible_provider.dart';

/// Agnes AI Provider 实现
///
/// 官方文档：https://agnes-ai.com/zh-Hans/docs/overview
/// 端点：https://apihub.agnes-ai.com/v1/chat/completions
/// 鉴权：`Authorization: Bearer {apiKey}`
///
/// 默认模型：Agnes-2.0-Flash（1M 上下文，Agent/工具调用优化）
///
/// Agnes AI 由 Sapiens AI 提供，全模态（文本/图像/视频）API 无限期免费开放，
/// 完全兼容 OpenAI 接口。
class AgnesProvider extends OpenAiCompatibleProvider {
  @override
  AiProviderType get type => AiProviderType.agnes;

  @override
  String get defaultBaseUrl => 'https://apihub.agnes-ai.com';
}