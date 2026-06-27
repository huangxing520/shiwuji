import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 统一 API 响应结构
///
/// 后端约定：HTTP 200 + body 包含 code/message/data 三段。
/// 业务成功时 code == 0；非 0 视为业务失败，抛出 [ApiException]。
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({required this.code, required this.message, this.data});

  bool get isSuccess => code == 0;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromData,
  }) {
    return ApiResponse<T>(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : json['data'] as T?,
    );
  }
}

/// 业务异常
class ApiException implements Exception {
  final int code;
  final String message;
  ApiException(this.code, this.message);

  @override
  String toString() => 'ApiException($code): $message';
}

/// 网络错误类型
enum NetErrorType {
  network, // 无网络 / 超时 / DNS 失败
  badResponse, // HTTP 状态码非 2xx
  business, // 业务 code 非 0
  cancel, // 请求被取消
  unknown,
}

/// HTTP 服务封装（单例）
///
/// 使用方式：
/// ```dart
/// final res = await HttpService.instance.get<Map<String, dynamic>>(
///   '/check-update',
///   fromData: (d) => d as Map<String, dynamic>,
/// );
/// if (res.isSuccess) {
///   final info = res.data!;
/// }
/// ```
class HttpService {
  HttpService._internal();
  static final HttpService instance = HttpService._internal();

  late Dio _dio = _buildDio();

  /// Base URL：TODO 替换为真实服务器地址
  static const String baseUrl = 'https://api.example.com';

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    // ─── 拦截器：日志（仅 debug）──────────────
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (o) => debugPrint('[HTTP] $o'),
        ),
      );
    }

    // ─── 拦截器：统一错误转换 ─────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) {
          // 可在此处统一上报错误、刷新 token 等
          handler.next(e);
        },
      ),
    );

    return dio;
  }

  // ─── 便捷方法：自动解析 ApiResponse ──────────

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic)? fromData,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _request<T>(
      () => _dio.get(
        path,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
      ),
      fromData: fromData,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    T Function(dynamic)? fromData,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _request<T>(
      () => _dio.post(
        path,
        data: body,
        options: options,
        cancelToken: cancelToken,
      ),
      fromData: fromData,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    T Function(dynamic)? fromData,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _request<T>(
      () => _dio.put(
        path,
        data: body,
        options: options,
        cancelToken: cancelToken,
      ),
      fromData: fromData,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic)? fromData,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _request<T>(
      () => _dio.delete(
        path,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
      ),
      fromData: fromData,
    );
  }

  // ─── 内部：发请求 + 解析响应 ────────────────

  Future<ApiResponse<T>> _request<T>(
    Future<Response<dynamic>> Function() send, {
    T Function(dynamic)? fromData,
  }) async {
    try {
      final response = await send();
      final json = response.data;

      // 兼容后端返回纯 JSON 或 String
      final Map<String, dynamic> map;
      if (json is Map<String, dynamic>) {
        map = json;
      } else if (json is String) {
        // 极少情况下后端返回 JSON 字符串
        final decoded = jsonDecode(json);
        if (decoded is Map<String, dynamic>) {
          map = decoded;
        } else {
          return ApiResponse<T>(code: -1, message: '响应格式异常');
        }
      } else {
        return ApiResponse<T>(code: -1, message: '响应格式异常');
      }

      final ApiResponse<T> apiRes = ApiResponse.fromJson(
        map,
        fromData: fromData,
      );
      if (!apiRes.isSuccess) {
        throw ApiException(apiRes.code, apiRes.message);
      }
      return apiRes;
    } on DioException catch (e) {
      throw _wrapDioError(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(-1, '未知错误：$e');
    }
  }

  ApiException _wrapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(-1, '网络请求超时');
      case DioExceptionType.connectionError:
        return ApiException(-1, '网络连接失败，请检查网络');
      case DioExceptionType.cancel:
        return ApiException(-1, '请求已取消');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? -1;
        return ApiException(code, '服务器错误（${e.response?.statusCode}）');
      case DioExceptionType.badCertificate:
        return ApiException(-1, '证书校验失败');
      case DioExceptionType.unknown:
        return ApiException(-1, e.message ?? '未知网络错误');
    }
  }

  // ─── 原始响应方法（第三方 API，如 GitHub）─────
  //
  // 不经过 ApiResponse 包装，直接返回 Response.data，
  // 但仍享受日志拦截器、超时、统一错误转换（抛 ApiException）。

  Future<Response<T>> getRaw<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _requestRaw<T>(
      () => _dio.get<T>(
        path,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> postRaw<T>(
    String path, {
    dynamic body,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _requestRaw<T>(
      () => _dio.post<T>(
        path,
        data: body,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> _requestRaw<T>(
    Future<Response<T>> Function() send,
  ) async {
    try {
      return await send();
    } on DioException catch (e) {
      throw _wrapDioError(e);
    }
  }

  // ─── 原始 Dio 访问（特殊场景使用）────────────

  Dio get rawDio => _dio;

  /// 测试用：替换底层 Dio 实例
  @visibleForTesting
  void setDioForTesting(Dio dio) => _dio = dio;
}
