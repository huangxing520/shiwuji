import 'package:dio/dio.dart';
import '../ai_models.dart';
import '../ai_provider.dart';
import '../ai_provider_type.dart';

/// 百度文心一言 Provider 实现（ERNIE 4.5 VL 等）
///
/// 官方文档：https://cloud.baidu.com/doc/WENXINWORKSHOP/index.html
/// 流程：先用 API Key + Secret Key 换取 access_token（30 天有效），
///   再带着 access_token 调用模型接口。
///
/// 端点：
///   换 token：https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials
///   调模型：https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/{model-path}?access_token={token}
///
/// 默认模型：ernie-4.5-vl-preview（多模态）
///   对应 model-path：multimodal-dialog/ernie-4.5-vl-preview
///
/// 不同模型的 path 前缀不同，这里用一个简单的映射维护。
class WenxinProvider extends AiProvider {
  final Dio _dio;

  WenxinProvider([Dio? dio]) : _dio = dio ?? Dio();

  @override
  AiProviderType get type => AiProviderType.wenxin;

  @override
  String get defaultBaseUrl => 'https://aip.baidubce.com';

  @override
  Future<AiVisionResult> recognizeImage({
    required String imagePath,
    required AiCallConfig config,
    String? prompt,
  }) async {
    if (config.apiKey.trim().isEmpty) {
      throw AiException('未配置文心 API Key', providerId: type.name);
    }
    if (config.secretKey == null || config.secretKey!.trim().isEmpty) {
      throw AiException('文心一言需要 Secret Key', providerId: type.name);
    }

    final model = config.modelName?.trim().isNotEmpty == true
        ? config.modelName!.trim()
        : defaultModel;
    final base =
        (config.baseUrl?.trim().isNotEmpty == true
                ? config.baseUrl!.trim()
                : defaultBaseUrl)
            .replaceAll(RegExp(r'/+$'), '');

    final modelPath = _mapModelPath(model);
    final effectivePrompt = prompt?.trim().isNotEmpty == true
        ? prompt!.trim()
        : kAiVisionPrompt;

    // 1. 获取 access_token（缓存由调用方负责，每次调用都换新）
    final accessToken = await _fetchAccessToken(
      base,
      config.apiKey,
      config.secretKey!,
    );

    // 2. 读取并 base64 编码图片
    final image = await readImageAsBase64(imagePath);

    final endpoint = '$base/rpc/2.0/ai_custom/v1/wenxinworkshop/$modelPath';
    AiDebugLog.request(
      provider: type.name,
      model: model,
      endpoint: endpoint,
      apiKey: config.apiKey,
      imageSizeBytes: image.bytesLength,
      prompt: effectivePrompt,
      extra: {'modelPath': modelPath},
    );

    final payload = {
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': effectivePrompt},
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:${image.mimeType};base64,${image.base64}',
              },
            },
          ],
        },
      ],
      'temperature': 0.1,
      'max_output_tokens': 800,
    };

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.post(
        '$endpoint?access_token=$accessToken',
        data: payload,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      stopwatch.stop();

      // 文心的错误以 error_code + error_msg 返回
      // ignore: avoid_dynamic_calls
      if (response.data?['error_code'] != null) {
        // ignore: avoid_dynamic_calls
        final code = response.data['error_code'];
        // ignore: avoid_dynamic_calls
        final msg = response.data['error_msg'] ?? '未知错误';
        AiDebugLog.error(
          provider: type.name,
          model: model,
          error: '文心错误($code)：$msg',
          statusCode: int.tryParse(code.toString()),
          elapsedMs: stopwatch.elapsedMilliseconds,
        );
        throw AiException(
          '文心错误($code)：$msg',
          providerId: type.name,
          statusCode: int.tryParse(code.toString()),
        );
      }

      // ignore: avoid_dynamic_calls
      final text = response.data?['result']?.toString() ?? '';
      AiDebugLog.response(
        provider: type.name,
        model: model,
        statusCode: response.statusCode ?? 0,
        elapsedMs: stopwatch.elapsedMilliseconds,
        rawBody: text,
      );

      if (text.isEmpty) {
        throw AiException('文心返回空响应', providerId: type.name);
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

  /// 用 API Key + Secret Key 换取 access_token
  Future<String> _fetchAccessToken(
    String base,
    String apiKey,
    String secretKey,
  ) async {
    try {
      final response = await _dio.post(
        '$base/oauth/2.0/token',
        queryParameters: {
          'grant_type': 'client_credentials',
          'client_id': apiKey,
          'client_secret': secretKey,
        },
        options: Options(
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      // ignore: avoid_dynamic_calls
      final token = response.data?['access_token']?.toString();
      if (token == null || token.isEmpty) {
        // ignore: avoid_dynamic_calls
        final err =
            response.data?['error_description'] ?? 'API Key / Secret Key 错误';
        throw AiException('获取 access_token 失败：$err', providerId: type.name);
      }
      return token;
    } on DioException catch (e) {
      throw wrapDioError(e);
    }
  }

  /// 把模型名映射成 URL path（百度模型不同 path 前缀不同）
  ///
  /// 仅维护多模态对话（multimodal-dialog）类模型的映射；其余未列出的多模态
  /// 模型按默认前缀 `multimodal-dialog/{model}` 拼接。
  String _mapModelPath(String model) {
    const map = <String, String>{
      'ernie-4.5-vl-preview': 'multimodal-dialog/ernie-4.5-vl-preview',
      'ernie-4.0-vl-preview': 'multimodal-dialog/ernie-4.0-vl-preview',
    };
    return map[model] ?? 'multimodal-dialog/$model';
  }

  @override
  Future<void> testConnection(AiCallConfig config) async {
    if (config.apiKey.trim().isEmpty) {
      throw AiException('未配置文心 API Key', providerId: type.name);
    }
    if (config.secretKey == null || config.secretKey!.trim().isEmpty) {
      throw AiException('文心一言需要 Secret Key', providerId: type.name);
    }

    final model = config.modelName?.trim().isNotEmpty == true
        ? config.modelName!.trim()
        : defaultModel;
    final base =
        (config.baseUrl?.trim().isNotEmpty == true
                ? config.baseUrl!.trim()
                : defaultBaseUrl)
            .replaceAll(RegExp(r'/+$'), '');
    final tokenEndpoint =
        '$base/oauth/2.0/token?grant_type=client_credentials&client_id=${config.apiKey}&client_secret=${config.secretKey}';

    AiDebugLog.request(
      provider: type.name,
      model: model,
      endpoint: tokenEndpoint,
      apiKey: config.apiKey,
      prompt: '[test] get access_token',
      extra: {'secretKey': AiDebugLog.maskKey(config.secretKey)},
    );

    final stopwatch = Stopwatch()..start();
    try {
      final token = await _fetchAccessToken(
        base,
        config.apiKey,
        config.secretKey!,
      );
      stopwatch.stop();

      AiDebugLog.response(
        provider: type.name,
        model: model,
        statusCode: 200,
        elapsedMs: stopwatch.elapsedMilliseconds,
        rawBody: '[test ok] access_token obtained (${token.length} chars)',
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
      rethrow;
    }
  }
}
