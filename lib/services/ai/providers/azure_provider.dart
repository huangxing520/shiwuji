import 'package:dio/dio.dart';
import '../ai_models.dart';
import '../ai_provider.dart';
import '../ai_provider_type.dart';

/// Azure OpenAI Provider 实现
///
/// 与标准 OpenAI 不同：
/// - URL 形如 `{endpoint}/openai/deployments/{deployment}/chat/completions?api-version=xxx`
///   其中 endpoint 是 Azure 资源地址（如 https://xxx.openai.azure.com），
///   deployment 是用户在 Azure 上创建的部署名
/// - 鉴权 header 为 `api-key: {apiKey}`（不是 Bearer）
/// - 请求体不传 `model` 字段（模型由 deployment 决定）
///
/// 约定：
/// - `config.baseUrl` 填 Azure 资源 endpoint，如 `https://myres.openai.azure.com`
/// - `config.modelName` 填 deployment name（如 `gpt-4o-deploy`）
/// - Secret Key 字段复用为 `api-version`，如 `2024-08-01-preview`（缺省时用默认值）
class AzureProvider extends AiProvider {
  final Dio _dio;

  AzureProvider([Dio? dio]) : _dio = dio ?? Dio();

  @override
  AiProviderType get type => AiProviderType.azure;

  @override
  String get defaultBaseUrl => 'https://YOUR-RESOURCE.openai.azure.com';

  /// Azure API 版本（用户可在 SecretKey 字段填入覆盖）
  static const _defaultApiVersion = '2024-08-01-preview';

  @override
  Future<AiVisionResult> recognizeImage({
    required String imagePath,
    required AiCallConfig config,
    String? prompt,
  }) async {
    if (config.apiKey.trim().isEmpty) {
      throw AiException('未配置 Azure OpenAI API Key', providerId: type.name);
    }

    final deployment = config.modelName?.trim().isNotEmpty == true
        ? config.modelName!.trim()
        : defaultModel;
    final endpoint =
        (config.baseUrl?.trim().isNotEmpty == true
                ? config.baseUrl!.trim()
                : defaultBaseUrl)
            .replaceAll(RegExp(r'/+$'), '');
    final apiVersion = (config.secretKey?.trim().isNotEmpty == true
        ? config.secretKey!.trim()
        : _defaultApiVersion);

    final image = await readImageAsBase64(imagePath);
    final dataUri = 'data:${image.mimeType};base64,${image.base64}';
    final effectivePrompt = prompt?.trim().isNotEmpty == true
        ? prompt!.trim()
        : kAiVisionPrompt;

    AiDebugLog.request(
      provider: type.name,
      model: deployment,
      endpoint: '$endpoint/openai/deployments/$deployment/chat/completions',
      apiKey: config.apiKey,
      imageSizeBytes: image.bytesLength,
      prompt: effectivePrompt,
      extra: {'apiVersion': apiVersion},
    );

    // Azure 不传 model 字段
    final payload = {
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

    final url =
        '$endpoint/openai/deployments/$deployment/chat/completions?api-version=$apiVersion';

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.post(
        url,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'api-key': config.apiKey,
          },
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      stopwatch.stop();

      final text = _extractContent(response.data);
      AiDebugLog.response(
        provider: type.name,
        model: deployment,
        statusCode: response.statusCode ?? 0,
        elapsedMs: stopwatch.elapsedMilliseconds,
        rawBody: text,
      );

      if (text.isEmpty) {
        throw AiException('Azure 返回空响应', providerId: type.name);
      }

      final json = parseJsonFromResponse(text);
      return buildVisionResultFromJson(
        json,
        model: deployment,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
    } on DioException catch (e) {
      AiDebugLog.error(
        provider: type.name,
        model: deployment,
        error: e,
        statusCode: e.response?.statusCode,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      throw wrapDioError(e);
    } on AiException catch (e) {
      AiDebugLog.error(
        provider: type.name,
        model: deployment,
        error: e,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      rethrow;
    } catch (e) {
      AiDebugLog.error(
        provider: type.name,
        model: deployment,
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
      throw AiException('未配置 Azure OpenAI API Key', providerId: type.name);
    }

    final deployment = config.modelName?.trim().isNotEmpty == true
        ? config.modelName!.trim()
        : defaultModel;
    final endpoint =
        (config.baseUrl?.trim().isNotEmpty == true
                ? config.baseUrl!.trim()
                : defaultBaseUrl)
            .replaceAll(RegExp(r'/+$'), '');
    final apiVersion = (config.secretKey?.trim().isNotEmpty == true
        ? config.secretKey!.trim()
        : _defaultApiVersion);

    final payload = {
      'messages': [
        {'role': 'user', 'content': 'hi'},
      ],
      'max_tokens': 1,
    };

    final url =
        '$endpoint/openai/deployments/$deployment/chat/completions?api-version=$apiVersion';

    AiDebugLog.request(
      provider: type.name,
      model: deployment,
      endpoint: url,
      apiKey: config.apiKey,
      prompt: '[test] hi',
      extra: {'apiVersion': apiVersion, 'deployment': deployment},
    );

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.post(
        url,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'api-key': config.apiKey,
          },
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      stopwatch.stop();

      AiDebugLog.response(
        provider: type.name,
        model: deployment,
        statusCode: response.statusCode ?? 0,
        elapsedMs: stopwatch.elapsedMilliseconds,
        rawBody: '[test ok] chat completions succeeded',
      );
    } on DioException catch (e) {
      AiDebugLog.error(
        provider: type.name,
        model: deployment,
        error: e,
        statusCode: e.response?.statusCode,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      throw wrapDioError(e);
    } catch (e) {
      AiDebugLog.error(
        provider: type.name,
        model: deployment,
        error: e,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      rethrow;
    }
  }
}
