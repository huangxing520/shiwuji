import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../ai_models.dart';
import '../ai_provider.dart';
import '../ai_provider_type.dart';

/// 腾讯混元 Hunyuan Provider 实现
///
/// 官方文档：https://cloud.tencent.com/document/product/1729/111007
/// 端点：https://hunyuan.tencentcloudapi.com
/// 鉴权：腾讯云 V3 签名（TC3-HMAC-SHA256）
///
/// 约定：
/// - `config.apiKey` 填腾讯云 SecretId
/// - `config.secretKey` 填腾讯云 SecretKey
/// - `config.modelName` 填模型名，如 `hunyuan-vision` / `hunyuan-pro` 等
///
/// 默认模型：hunyuan-vision
class HunyuanProvider extends AiProvider {
  final Dio _dio;

  HunyuanProvider([Dio? dio]) : _dio = dio ?? Dio();

  @override
  AiProviderType get type => AiProviderType.hunyuan;

  @override
  String get defaultBaseUrl => 'https://hunyuan.tencentcloudapi.com';

  @override
  Future<AiVisionResult> recognizeImage({
    required String imagePath,
    required AiCallConfig config,
    String? prompt,
  }) async {
    if (config.apiKey.trim().isEmpty ||
        config.secretKey?.trim().isEmpty == true) {
      throw AiException('未配置腾讯云 SecretId / SecretKey', providerId: type.name);
    }

    final model = config.modelName?.trim().isNotEmpty == true
        ? config.modelName!.trim()
        : defaultModel;

    final image = await readImageAsBase64(imagePath);
    final effectivePrompt = prompt?.trim().isNotEmpty == true
        ? prompt!.trim()
        : kAiVisionPrompt;

    final payload = {
      'Model': model,
      'Messages': [
        {
          'Role': 'user',
          'Contents': [
            {'Type': 'text', 'Text': effectivePrompt},
            {
              'Type': 'image_url',
              'ImageUrl': {
                'Url': 'data:${image.mimeType};base64,${image.base64}',
              },
            },
          ],
        },
      ],
      'Temperature': 0.1,
    };
    final body = jsonEncode(payload);

    AiDebugLog.request(
      provider: type.name,
      model: model,
      endpoint: defaultBaseUrl,
      apiKey: config.apiKey,
      imageSizeBytes: image.bytesLength,
      prompt: effectivePrompt,
      extra: {'auth': 'TC3-HMAC-SHA256'},
    );

    final stopwatch = Stopwatch()..start();
    try {
      final headers = _sign(
        secretId: config.apiKey,
        secretKey: config.secretKey!,
        body: body,
      );

      final response = await _dio.post(
        defaultBaseUrl,
        data: body,
        options: Options(
          headers: headers,
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      stopwatch.stop();

      // ignore: avoid_dynamic_calls
      final resp = response.data?['Response'];
      // ignore: avoid_dynamic_calls
      if (resp?['Error'] != null) {
        // ignore: avoid_dynamic_calls
        final err = resp!['Error'];
        // ignore: avoid_dynamic_calls
        final errMsg = '腾讯混元调用失败：[${err['Code']}] ${err['Message']}';
        AiDebugLog.error(
          provider: type.name,
          model: model,
          error: errMsg,
          elapsedMs: stopwatch.elapsedMilliseconds,
        );
        throw AiException(errMsg, providerId: type.name);
      }
      // ignore: avoid_dynamic_calls
      final choices = resp?['Choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw AiException('腾讯混元返回空响应', providerId: type.name);
      }
      // ignore: avoid_dynamic_calls
      final message = choices[0]?['Message'];
      // ignore: avoid_dynamic_calls
      final text = message?['Content']?.toString() ?? '';

      AiDebugLog.response(
        provider: type.name,
        model: model,
        statusCode: response.statusCode ?? 0,
        elapsedMs: stopwatch.elapsedMilliseconds,
        rawBody: text,
      );

      if (text.isEmpty) {
        throw AiException('腾讯混元返回空响应', providerId: type.name);
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

  /// 腾讯云 V3 签名（TC3-HMAC-SHA256）
  ///
  /// 参考官方文档：https://cloud.tencent.com/document/api/1729/101943
  Map<String, String> _sign({
    required String secretId,
    required String secretKey,
    required String body,
  }) {
    final service = 'hunyuan';
    final host = 'hunyuan.tencentcloudapi.com';
    final utc = DateTime.now().toUtc();
    final timestamp = utc.millisecondsSinceEpoch ~/ 1000;
    final date =
        '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}';

    // 1. 拼接规范请求串
    final httpRequestMethod = 'POST';
    final canonicalUri = '/';
    final canonicalQueryString = '';
    final canonicalHeaders =
        'content-type:application/json; charset=utf-8\nhost:$host\nx-tc-action:chatcompletions\n';
    final signedHeaders = 'content-type;host;x-tc-action';
    final hashedRequestPayload = sha256.convert(utf8.encode(body)).toString();
    final canonicalRequest =
        '$httpRequestMethod\n'
        '$canonicalUri\n'
        '$canonicalQueryString\n'
        '$canonicalHeaders\n'
        '$signedHeaders\n'
        '$hashedRequestPayload';

    // 2. 拼接待签名串
    final algorithm = 'TC3-HMAC-SHA256';
    final hashedCanonicalRequest = sha256
        .convert(utf8.encode(canonicalRequest))
        .toString();
    final credentialScope = '$date/$service/tc3_request';
    final stringToSign =
        '$algorithm\n'
        '$timestamp\n'
        '$credentialScope\n'
        '$hashedCanonicalRequest';

    // 3. 计算签名
    final secretDate = Hmac(
      sha256,
      utf8.encode('TC3$secretKey'),
    ).convert(utf8.encode(date)).bytes;
    final secretService = Hmac(
      sha256,
      secretDate,
    ).convert(utf8.encode(service)).bytes;
    final secretSigning = Hmac(
      sha256,
      secretService,
    ).convert(utf8.encode('tc3_request')).bytes;
    final signature = Hmac(
      sha256,
      secretSigning,
    ).convert(utf8.encode(stringToSign)).toString();

    // 4. 拼接 Authorization
    final authorization =
        '$algorithm '
        'Credential=$secretId/$credentialScope, '
        'SignedHeaders=$signedHeaders, '
        'Signature=$signature';

    return {
      'Authorization': authorization,
      'Content-Type': 'application/json; charset=utf-8',
      'Host': host,
      'X-TC-Action': 'ChatCompletions',
      'X-TC-Version': '2023-09-01',
      'X-TC-Timestamp': timestamp.toString(),
    };
  }

  @override
  Future<void> testConnection(AiCallConfig config) async {
    if (config.apiKey.trim().isEmpty ||
        config.secretKey?.trim().isEmpty == true) {
      throw AiException('未配置腾讯云 SecretId / SecretKey', providerId: type.name);
    }

    final model = config.modelName?.trim().isNotEmpty == true
        ? config.modelName!.trim()
        : defaultModel;

    final payload = {
      'Model': model,
      'Messages': [
        {
          'Role': 'user',
          'Contents': [
            {'Type': 'text', 'Text': 'hi'},
          ],
        },
      ],
    };
    final body = jsonEncode(payload);

    AiDebugLog.request(
      provider: type.name,
      model: model,
      endpoint: defaultBaseUrl,
      apiKey: config.apiKey,
      prompt: '[test] hi',
      extra: {
        'auth': 'TC3-HMAC-SHA256',
        'secretKey': AiDebugLog.maskKey(config.secretKey),
      },
    );

    final stopwatch = Stopwatch()..start();
    try {
      final headers = _sign(
        secretId: config.apiKey,
        secretKey: config.secretKey!,
        body: body,
      );

      final response = await _dio.post(
        defaultBaseUrl,
        data: body,
        options: Options(
          headers: headers,
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      stopwatch.stop();

      // ignore: avoid_dynamic_calls
      final resp = response.data?['Response'];
      // ignore: avoid_dynamic_calls
      if (resp?['Error'] != null) {
        // ignore: avoid_dynamic_calls
        final err = resp!['Error'];
        // ignore: avoid_dynamic_calls
        final errMsg = '腾讯混元调用失败：[${err['Code']}] ${err['Message']}';
        AiDebugLog.error(
          provider: type.name,
          model: model,
          error: errMsg,
          elapsedMs: stopwatch.elapsedMilliseconds,
        );
        throw AiException(errMsg, providerId: type.name);
      }

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
