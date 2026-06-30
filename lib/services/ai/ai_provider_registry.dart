import 'ai_provider.dart';
import 'ai_provider_type.dart';
import 'providers/agnes_provider.dart';
import 'providers/azure_provider.dart';
import 'providers/claude_provider.dart';
import 'providers/deepseek_provider.dart';
import 'providers/doubao_provider.dart';
import 'providers/gemini_provider.dart';
import 'providers/hunyuan_provider.dart';
import 'providers/minimax_provider.dart';
import 'providers/mimo_provider.dart';
import 'providers/moonshot_provider.dart';
import 'providers/nvidia_provider.dart';
import 'providers/openai_provider.dart';
import 'providers/qianwen_provider.dart';
import 'providers/siliconflow_provider.dart';
import 'providers/spark_provider.dart';
import 'providers/wenxin_provider.dart';
import 'providers/yi_provider.dart';
import 'providers/zhipu_provider.dart';

/// AI Provider 注册中心
///
/// 单例模式，启动时注册全部内置供应商；后续可按需通过 [register] 动态扩展。
class AiProviderRegistry {
  AiProviderRegistry._() : _providers = {};

  final Map<AiProviderType, AiProvider> _providers;

  /// 全局单例
  static final AiProviderRegistry instance = AiProviderRegistry._()
    .._registerAll();

  /// 注册全部内置供应商
  void _registerAll() {
    register(AiProviderType.gemini, GeminiProvider());
    register(AiProviderType.openai, OpenAiProvider());
    register(AiProviderType.azure, AzureProvider());
    register(AiProviderType.claude, ClaudeProvider());
    register(AiProviderType.qianwen, QianwenProvider());
    register(AiProviderType.wenxin, WenxinProvider());
    register(AiProviderType.zhipu, ZhipuProvider());
    register(AiProviderType.doubao, DoubaoProvider());
    register(AiProviderType.deepseek, DeepSeekProvider());
    register(AiProviderType.siliconflow, SiliconflowProvider());
    register(AiProviderType.mimo, MimoProvider());
    register(AiProviderType.moonshot, MoonshotProvider());
    register(AiProviderType.yi, YiProvider());
    register(AiProviderType.minimax, MinimaxProvider());
    register(AiProviderType.spark, SparkProvider());
    register(AiProviderType.hunyuan, HunyuanProvider());
    register(AiProviderType.nvidia, NvidiaProvider());
    register(AiProviderType.agnes, AgnesProvider());
  }

  /// 注册新供应商（可用于运行时扩展）
  void register(AiProviderType type, AiProvider provider) {
    _providers[type] = provider;
  }

  /// 获取供应商实现
  ///
  /// 若该类型未注册，抛出 [StateError]（说明枚举与注册未对齐）
  AiProvider get(AiProviderType type) {
    final provider = _providers[type];
    if (provider == null) {
      throw StateError('未注册的 AI 供应商类型：$type');
    }
    return provider;
  }

  /// 所有已注册的供应商类型
  List<AiProviderType> get availableTypes =>
      _providers.keys.toList(growable: false);
}
