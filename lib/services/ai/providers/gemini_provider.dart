import 'package:dio/dio.dart';
import '../ai_models.dart';
import '../ai_provider.dart';
import '../ai_provider_type.dart';

/// Google Gemini Provider 实现
///
/// 官方文档：https://ai.google.dev/api/generate-content
/// 端点：{base}/v1beta/models/{model}:generateContent?key={apiKey}
///
/// 默认模型：gemini-2.5-flash
class GeminiProvider extends AiProvider {
  final Dio _dio;

  GeminiProvider([Dio? dio]) : _dio = dio ?? Dio();

  @override
  AiProviderType get type => AiProviderType.gemini;

  @override
  String get defaultBaseUrl => 'https://generativelanguage.googleapis.com';

  @override
  Future<AiVisionResult> recognizeImage({
    required String imagePath,
    required AiCallConfig config,
    String? prompt,
  }) async {
    if (config.apiKey.trim().isEmpty) {
      throw AiException('未配置 Gemini API Key', providerId: type.name);
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

    final endpoint = '$base/v1beta/models/$model:generateContent';
    AiDebugLog.request(
      provider: type.name,
      model: model,
      endpoint: endpoint,
      apiKey: config.apiKey,
      imageSizeBytes: image.bytesLength,
      prompt: effectivePrompt,
    );

    final payload = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': effectivePrompt},
            {
              'inline_data': {
                'mime_type': image.mimeType,
                'data': image.base64,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'topP': 0.95,
        'maxOutputTokens': 800,
        'responseMimeType': 'application/json',
      },
    };

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.post(
        '$endpoint?key=${config.apiKey}',
        data: payload,
        options: Options(
          headers: {'Content-Type': 'application/json'},
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
        throw AiException('Gemini 返回空响应', providerId: type.name);
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
    final candidates = data?['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return '';
    // ignore: avoid_dynamic_calls
    final content = candidates[0]?['content'];
    // ignore: avoid_dynamic_calls
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) return '';
    return parts
        // ignore: avoid_dynamic_calls
        .map((p) => p['text']?.toString() ?? '')
        .join();
  }

  @override
  Future<void> testConnection(AiCallConfig config) async {
    if (config.apiKey.trim().isEmpty) {
      throw AiException('未配置 Gemini API Key', providerId: type.name);
    }

    final model = config.modelName?.trim().isNotEmpty == true
        ? config.modelName!.trim()
        : defaultModel;
    final base =
        (config.baseUrl?.trim().isNotEmpty == true
                ? config.baseUrl!.trim()
                : defaultBaseUrl)
            .replaceAll(RegExp(r'/+$'), '');
    final endpoint = '$base/v1beta/models';

    AiDebugLog.request(
      provider: type.name,
      model: model,
      endpoint: endpoint,
      apiKey: config.apiKey,
      prompt: '[test] list models',
    );

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.get(
        '$base/v1beta/models?key=${config.apiKey}',
        options: Options(
          headers: {'Content-Type': 'application/json'},
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
        rawBody: '[test ok] list models succeeded',
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
