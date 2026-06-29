/// AI 模型供应商类型
///
/// 参考 OpenCode 的多 provider 架构，每个供应商对应一个独立的 Provider 实现。
/// 新增供应商时只需：
/// 1. 在本枚举添加项
/// 2. 在 [aiProviderMetas] 添加展示元数据
/// 3. 在 [AiProviderRegistry._registerAll] 注册实现
enum AiProviderType {
  /// Google Gemini（默认，免费额度高）
  gemini,

  /// OpenAI GPT 系列（GPT-4o 等多模态）
  openai,

  /// Azure OpenAI（企业版，需 endpoint + deployment name + api-version）
  azure,

  /// Anthropic Claude（Claude 3.5 Sonnet 等）
  claude,

  /// 阿里通义千问（Qwen-VL 系列，DashScope OpenAI 兼容）
  qianwen,

  /// 百度文心一言（ERNIE VL 系列，需 API Key + Secret Key）
  wenxin,

  /// 智谱 AI（GLM-4V 系列，OpenAI 兼容）
  zhipu,

  /// 字节豆包（火山方舟，OpenAI 兼容，使用 endpoint id 作为模型名）
  doubao,

  /// DeepSeek（OpenAI 兼容）
  deepseek,

  /// 硅基流动 SiliconFlow（OpenAI 兼容聚合，支持多种开源 VL 模型）
  siliconflow,

  /// 小米 MiMo（OpenAI 兼容，可通过硅基流动/ModelScope 调用）
  mimo,

  /// 月之暗面 Kimi（OpenAI 兼容，长上下文）
  moonshot,

  /// 零一万物 Yi（OpenAI 兼容，Yi-VL 多模态）
  yi,

  /// MiniMax（OpenAI 兼容，自研大模型）
  minimax,

  /// 讯飞星火 Spark（OpenAI 兼容接口，Bearer APIPassword 鉴权）
  spark,

  /// 腾讯混元 Hunyuan（自定义 TC3-HMAC-SHA256 鉴权）
  hunyuan,

  /// NVIDIA（OpenAI 兼容，通过 integrate.api.nvidia.com 调用多模型）
  nvidia,
}

/// 供应商元数据：用于设置页展示
class AiProviderMeta {
  final String displayName;
  final String description;
  final String defaultModel;
  final String apiKeyHint;
  final String apiKeyHelpUrl;
  final bool
  needsSecretKey; // 文心一言需要 API Key + Secret Key；Azure 用此字段填 api-version
  final String secretKeyHint; // Secret Key 字段的提示文案
  final bool supportsCustomBaseUrl;

  const AiProviderMeta({
    required this.displayName,
    required this.description,
    required this.defaultModel,
    required this.apiKeyHint,
    required this.apiKeyHelpUrl,
    this.needsSecretKey = false,
    this.secretKeyHint = '文心一言控制台的 Secret Key',
    this.supportsCustomBaseUrl = true,
  });
}

/// 各供应商的展示元数据
const Map<AiProviderType, AiProviderMeta> aiProviderMetas = {
  AiProviderType.gemini: AiProviderMeta(
    displayName: 'Google Gemini',
    description: '多模态，免费额度高，速度快',
    defaultModel: 'gemini-2.5-flash',
    apiKeyHint: 'AIza...',
    apiKeyHelpUrl: 'https://aistudio.google.com/apikey',
  ),
  AiProviderType.openai: AiProviderMeta(
    displayName: 'OpenAI',
    description: 'GPT-4o 系列，识别质量高',
    defaultModel: 'gpt-4o-mini',
    apiKeyHint: 'sk-...',
    apiKeyHelpUrl: 'https://platform.openai.com/api-keys',
  ),
  AiProviderType.azure: AiProviderMeta(
    displayName: 'Azure OpenAI',
    description: '企业版，需 endpoint + deployment + api-version',
    defaultModel: 'gpt-4o',
    apiKeyHint: 'Azure Key',
    apiKeyHelpUrl:
        'https://portal.azure.com/#view/Microsoft_Azure_ProjectOxford/CognitiveServicesHub/~/OpenAI',
    needsSecretKey: true,
    secretKeyHint: 'API 版本，如 2024-08-01-preview（留空用默认）',
  ),
  AiProviderType.claude: AiProviderMeta(
    displayName: 'Anthropic Claude',
    description: 'Claude 3.5 Sonnet，细节描述丰富',
    defaultModel: 'claude-3-5-sonnet-20241022',
    apiKeyHint: 'sk-ant-...',
    apiKeyHelpUrl: 'https://console.anthropic.com/settings/keys',
  ),
  AiProviderType.qianwen: AiProviderMeta(
    displayName: '阿里通义千问',
    description: 'Qwen-VL 系列，国内访问稳定',
    defaultModel: 'qwen-vl-max',
    apiKeyHint: 'sk-...',
    apiKeyHelpUrl: 'https://dashscope.console.aliyun.com/apiKey',
  ),
  AiProviderType.wenxin: AiProviderMeta(
    displayName: '百度文心一言',
    description: '国内访问稳定，中文识别优秀',
    defaultModel: 'ernie-4.5-vl-preview',
    apiKeyHint: 'API Key',
    apiKeyHelpUrl:
        'https://console.bce.baidu.com/qianfan/ais/console/applicationConsole/application',
    needsSecretKey: true,
    supportsCustomBaseUrl: false,
  ),
  AiProviderType.zhipu: AiProviderMeta(
    displayName: '智谱 AI',
    description: 'GLM-4V 系列，中文场景优秀',
    defaultModel: 'glm-4v-plus',
    apiKeyHint: 'xxx.xxx',
    apiKeyHelpUrl: 'https://open.bigmodel.cn/usercenter/apikeys',
  ),
  AiProviderType.doubao: AiProviderMeta(
    displayName: '字节豆包',
    description: '火山方舟，使用接入点 ID 作为模型名',
    defaultModel: 'ep-xxxxxxxx',
    apiKeyHint: '火山 Key',
    apiKeyHelpUrl:
        'https://console.volcengine.com/ark/region:ark+cn-beijing/apiKey',
  ),
  AiProviderType.deepseek: AiProviderMeta(
    displayName: 'DeepSeek',
    description: '高性价比，兼容 OpenAI 接口',
    defaultModel: 'deepseek-chat',
    apiKeyHint: 'sk-...',
    apiKeyHelpUrl: 'https://platform.deepseek.com/api_keys',
  ),
  AiProviderType.siliconflow: AiProviderMeta(
    displayName: '硅基流动',
    description: '聚合平台，支持 Qwen-VL / InternVL 等开源模型',
    defaultModel: 'Qwen/Qwen2.5-VL-72B-Instruct',
    apiKeyHint: 'sk-...',
    apiKeyHelpUrl: 'https://cloud.siliconflow.cn/account/ak',
  ),
  AiProviderType.mimo: AiProviderMeta(
    displayName: '小米 MiMo',
    description: '小米 MiMo-VL，通过硅基流动 / ModelScope 调用',
    defaultModel: 'XiaomiMiMo/MiMo-VL-7B-Instruct',
    apiKeyHint: 'sk-...',
    apiKeyHelpUrl: 'https://cloud.siliconflow.cn/account/ak',
  ),
  AiProviderType.moonshot: AiProviderMeta(
    displayName: '月之暗面 Kimi',
    description: '长上下文模型，兼容 OpenAI 接口',
    defaultModel: 'moonshot-v1-8k-vision-preview',
    apiKeyHint: 'sk-...',
    apiKeyHelpUrl: 'https://platform.moonshot.cn/console/api-keys',
  ),
  AiProviderType.yi: AiProviderMeta(
    displayName: '零一万物 Yi',
    description: 'Yi-VL 多模态，兼容 OpenAI 接口',
    defaultModel: 'yi-vl-plus',
    apiKeyHint: 'sk-...',
    apiKeyHelpUrl: 'https://platform.lingyiwanwu.com/apikeys',
  ),
  AiProviderType.minimax: AiProviderMeta(
    displayName: 'MiniMax',
    description: '自研大模型，兼容 OpenAI 接口',
    defaultModel: 'MiniMax-Text-01',
    apiKeyHint: 'eyJ...',
    apiKeyHelpUrl:
        'https://platform.minimaxi.com/user-center/basic-information/interface-key',
  ),
  AiProviderType.spark: AiProviderMeta(
    displayName: '讯飞星火',
    description: 'Spark 4.0 Ultra 多模态，OpenAI 兼容接口',
    defaultModel: '4.0Ultra',
    apiKeyHint: 'APIPassword',
    apiKeyHelpUrl: 'https://console.xfyun.cn/services/bm4',
    supportsCustomBaseUrl: false,
  ),
  AiProviderType.hunyuan: AiProviderMeta(
    displayName: '腾讯混元',
    description: 'Hunyuan-vision 多模态，需腾讯云签名',
    defaultModel: 'hunyuan-vision',
    apiKeyHint: 'SecretId',
    apiKeyHelpUrl: 'https://console.cloud.tencent.com/cam/capi',
    needsSecretKey: true,
    secretKeyHint: 'SecretKey（与 SecretId 配对使用）',
    supportsCustomBaseUrl: false,
  ),
  AiProviderType.nvidia: AiProviderMeta(
    displayName: 'NVIDIA',
    description: 'NVIDIA NIM 平台，支持多模型聚合调用',
    defaultModel: 'minimaxai/minimax-m3',
    apiKeyHint: 'nvapi-...',
    apiKeyHelpUrl: 'https://build.nvidia.com/explore/discover',
  ),
};
