import 'package:dio/dio.dart';
import '../ai_models.dart';
import '../ai_provider.dart';
import '../ai_provider_type.dart';

/// OpenAI Chat Completions 兼容协议的基类
///
/// 适用于一切遵循 `POST {base}/v1/chat/completions` + `Authorization: Bearer`
/// 协议的供应商：OpenAI、智谱、豆包、DeepSeek、硅基流动、mimo、通义千问等。
///
/// 子类只需重写 [type] 和 [defaultBaseUrl]，必要时重写 [authHeaders] / [extraHeaders] /
/// [supportsResponseFormat] 即可，无需重复写 HTTP/解析逻辑。
abstract class OpenAiCompatibleProvider extends AiProvider {
  final Dio _dio;

  OpenAiCompatibleProvider([Dio? dio]) : _dio = dio ?? Dio();

  /// 鉴权 header（默认 `Authorization: Bearer {apiKey}`）
  Map<String, String> authHeaders(AiCallConfig config) => {
    'Authorization': 'Bearer ${config.apiKey}',
  };

  /// 额外 header（子类可扩展，如添加特定厂商需要的 header）
  Map<String, String> extraHeaders(AiCallConfig config) => const {};

  /// 是否支持 `response_format: json_object`
  ///
  /// 部分供应商（如智谱老版本、豆包）不支持该字段，子类可重写为 false。
  bool get supportsResponseFormat => true;

  /// Chat Completions 路径（默认 `/v1/chat/completions`）
  String get chatCompletionsPath => '/v1/chat/completions';

  @override
  Future<AiVisionResult> recognizeImage({
    required String imagePath,
    required AiCallConfig config,
    String? prompt,
  }) async {
    if (config.apiKey.trim().isEmpty) {
      throw AiException(
        '未配置 ${aiProviderMetas[type]!.displayName} API Key',
        providerId: type.name,
      );
    }

    final model = config.modelName?.trim().isNotEmpty == true
        ? config.modelName!.trim()
        : defaultModel;
    final base =
        (config.baseUrl?.trim().isNotEmpty == true
                ? config.baseUrl!.trim()
                : defaultBaseUrl)
            .replaceAll(RegExp(r'/+$'), '');

    final image = await readImageAsBase64(imagePath);
    final dataUri = 'data:${image.mimeType};base64,${image.base64}';
    final effectivePrompt = prompt?.trim().isNotEmpty == true
        ? prompt!.trim()
        : kAiVisionPrompt;

    final endpoint = '$base$chatCompletionsPath';
    AiDebugLog.request(
      provider: type.name,
      model: model,
      endpoint: endpoint,
      apiKey: config.apiKey,
      imageSizeBytes: image.bytesLength,
      prompt: effectivePrompt,
      extra: supportsResponseFormat ? null : {'responseFormat': 'disabled'},
    );

    final payload = <String, dynamic>{
      'model': model,
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': effectivePrompt},
            {
              'type': 'image_url',
              'image_url': {'url': dataUri},
            },
          ],
        },
      ],
      'temperature': 0.1,
      'max_tokens': 800,
    };
    if (supportsResponseFormat) {
      payload['response_format'] = {'type': 'json_object'};
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...authHeaders(config),
      ...extraHeaders(config),
    };

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.post(
        endpoint,
        data: payload,
        options: Options(
          headers: headers,
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      stopwatch.stop();

      final text = _extractContent(response.data);
      AiDebugLog.response(
        provider: type.name,
        model: model,
        statusCode: response.statusCode ?? 0,
        elapsedMs: stopwatch.elapsedMilliseconds,
        rawBody: text,
      );

      if (text.isEmpty) {
        throw AiException(
          '${aiProviderMetas[type]!.displayName} 返回空响应',
          providerId: type.name,
        );
      }

      final json = parseJsonFromResponse(text);
      return buildVisionResultFromJson(
        json,
        model: model,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
    } on DioException catch (e) {
      AiDebugLog.error(
        provider: type.name,
        model: model,
        error: e,
        statusCode: e.response?.statusCode,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      throw wrapDioError(e);
    } on AiException catch (e) {
      AiDebugLog.error(
        provider: type.name,
        model: model,
        error: e,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      rethrow;
    } catch (e) {
      AiDebugLog.error(
        provider: type.name,
        model: model,
        error: e,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      throw AiException('解析响应失败：$e', providerId: type.name);
    }
  }

  String _extractContent(dynamic data) {
    // ignore: avoid_dynamic_calls
    final choices = data?['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return '';
    // ignore: avoid_dynamic_calls
    final message = choices[0]?['message'];
    // ignore: avoid_dynamic_calls
    return message?['content']?.toString() ?? '';
  }

  @override
  Future<void> testConnection(AiCallConfig config) async {
    if (config.apiKey.trim().isEmpty) {
      throw AiException(
        '未配置 ${aiProviderMetas[type]!.displayName} API Key',
        providerId: type.name,
      );
    }

    final model = config.modelName?.trim().isNotEmpty == true
        ? config.modelName!.trim()
        : defaultModel;
    final base =
        (config.baseUrl?.trim().isNotEmpty == true
                ? config.baseUrl!.trim()
                : defaultBaseUrl)
            .replaceAll(RegExp(r'/+$'), '');
    final endpoint = '$base$chatCompletionsPath';

    final payload = <String, dynamic>{
      'model': model,
      'messages': [
        {'role': 'user', 'content': 'hi'},
      ],
      'max_tokens': 1,
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...authHeaders(config),
      ...extraHeaders(config),
    };

    AiDebugLog.request(
      provider: type.name,
      model: model,
      endpoint: endpoint,
      apiKey: config.apiKey,
      prompt: '[test] hi',
    );

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.post(
        endpoint,
        data: payload,
        options: Options(
          headers: headers,
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      stopwatch.stop();

      AiDebugLog.response(
        provider: type.name,
        model: model,
        statusCode: response.statusCode ?? 0,
        elapsedMs: stopwatch.elapsedMilliseconds,
        rawBody: '[test ok] chat completions succeeded',
      );
    } on DioException catch (e) {
      AiDebugLog.error(
        provider: type.name,
        model: model,
        error: e,
        statusCode: e.response?.statusCode,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      throw wrapDioError(e);
    } catch (e) {
      AiDebugLog.error(
        provider: type.name,
        model: model,
        error: e,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      rethrow;
    }
  }
}
