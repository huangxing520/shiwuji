import 'package:dio/dio.dart';
import '../ai_models.dart';
import '../ai_provider.dart';
import '../ai_provider_type.dart';

/// Anthropic Claude Provider 实现（Claude 3.5 Sonnet 等多模态模型）
///
/// 官方文档：https://docs.anthropic.com/en/api/messages
/// 端点：{base}/v1/messages
/// 鉴权：Header `x-api-key: {apiKey}` + `anthropic-version: 2023-06-01`
///
/// 默认模型：claude-3-5-sonnet-20241022
class ClaudeProvider extends AiProvider {
  final Dio _dio;

  ClaudeProvider([Dio? dio]) : _dio = dio ?? Dio();

  @override
  AiProviderType get type => AiProviderType.claude;

  @override
  String get defaultBaseUrl => 'https://api.anthropic.com';

  @override
  Future<AiVisionResult> recognizeImage({
    required String imagePath,
    required AiCallConfig config,
    String? prompt,
  }) async {
    if (config.apiKey.trim().isEmpty) {
      throw AiException('未配置 Claude API Key', providerId: type.name);
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
    final effectivePrompt = prompt?.trim().isNotEmpty == true
        ? prompt!.trim()
        : kAiVisionPrompt;

    final endpoint = '$base/v1/messages';
    AiDebugLog.request(
      provider: type.name,
      model: model,
      endpoint: endpoint,
      apiKey: config.apiKey,
      imageSizeBytes: image.bytesLength,
      prompt: effectivePrompt,
    );

    // Claude 的图片以 base64 source 形式放入 content blocks
    final payload = {
      'model': model,
      'max_tokens': 800,
      'temperature': 0.1,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': image.mimeType,
                'data': image.base64,
              },
            },
            {'type': 'text', 'text': effectivePrompt},
          ],
        },
      ],
    };

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.post(
        endpoint,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': config.apiKey,
            'anthropic-version': '2023-06-01',
          },
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      stopwatch.stop();

      final text = _extractText(response.data);
      AiDebugLog.response(
        provider: type.name,
        model: model,
        statusCode: response.statusCode ?? 0,
        elapsedMs: stopwatch.elapsedMilliseconds,
        rawBody: text,
      );

      if (text.isEmpty) {
        throw AiException('Claude 返回空响应', providerId: type.name);
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

  String _extractText(dynamic data) {
    // ignore: avoid_dynamic_calls
    final content = data?['content'] as List<dynamic>?;
    if (content == null || content.isEmpty) return '';
    return content
        // ignore: avoid_dynamic_calls
        .where((b) => b['type'] == 'text')
        // ignore: avoid_dynamic_calls
        .map((b) => b['text']?.toString() ?? '')
        .join();
  }

  @override
  Future<void> testConnection(AiCallConfig config) async {
    if (config.apiKey.trim().isEmpty) {
      throw AiException('未配置 Claude API Key', providerId: type.name);
    }

    final model = config.modelName?.trim().isNotEmpty == true
        ? config.modelName!.trim()
        : defaultModel;
    final base =
        (config.baseUrl?.trim().isNotEmpty == true
                ? config.baseUrl!.trim()
                : defaultBaseUrl)
            .replaceAll(RegExp(r'/+$'), '');
    final endpoint = '$base/v1/messages';

    final payload = {
      'model': model,
      'max_tokens': 1,
      'messages': [
        {'role': 'user', 'content': 'hi'},
      ],
    };

    AiDebugLog.request(
      provider: type.name,
      model: model,
      endpoint: endpoint,
      apiKey: config.apiKey,
      prompt: '[test] hi',
      extra: {'anthropicVersion': '2023-06-01'},
    );

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.post(
        endpoint,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': config.apiKey,
            'anthropic-version': '2023-06-01',
          },
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
        rawBody: '[test ok] messages succeeded',
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
