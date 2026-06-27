import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shi_wu_ji/services/http_service.dart';

void main() {
  group('ApiResponse', () {
    test('成功响应 code=0 isSuccess=true', () {
      final res = ApiResponse<int>(code: 0, message: 'ok', data: 42);
      expect(res.isSuccess, isTrue);
      expect(res.data, 42);
      expect(res.message, 'ok');
    });

    test('失败响应 code!=0 isSuccess=false', () {
      final res = ApiResponse<int>(code: 1001, message: '参数错误', data: null);
      expect(res.isSuccess, isFalse);
      expect(res.data, isNull);
    });

    test('fromJson 解析标准结构', () {
      final json = {
        'code': 0,
        'message': 'success',
        'data': {'id': 1, 'name': 'test'},
      };
      final res = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        fromData: (d) => Map<String, dynamic>.from(d as Map),
      );
      expect(res.code, 0);
      expect(res.message, 'success');
      expect(res.isSuccess, isTrue);
      expect(res.data?['id'], 1);
      expect(res.data?['name'], 'test');
    });

    test('fromJson code 缺失默认 -1', () {
      final json = {'message': 'no code'};
      final res = ApiResponse<dynamic>.fromJson(json);
      expect(res.code, -1);
      expect(res.isSuccess, isFalse);
    });

    test('fromJson message 缺失默认空字符串', () {
      final json = {'code': 0};
      final res = ApiResponse<dynamic>.fromJson(json);
      expect(res.message, '');
    });

    test('fromJson data 为 null 时不调用 fromData', () {
      final json = {'code': 0, 'message': 'ok', 'data': null};
      var fromDataCalled = false;
      final res = ApiResponse<String>.fromJson(
        json,
        fromData: (d) {
          fromDataCalled = true;
          return d.toString();
        },
      );
      expect(fromDataCalled, isFalse);
      expect(res.data, isNull);
    });

    test('fromJson 无 fromData 时 data 原样保留', () {
      final json = {'code': 0, 'message': 'ok', 'data': 'raw-string'};
      final res = ApiResponse<String>.fromJson(json);
      expect(res.data, 'raw-string');
    });
  });

  group('ApiException', () {
    test('构造与 toString', () {
      final e = ApiException(404, 'Not Found');
      expect(e.code, 404);
      expect(e.message, 'Not Found');
      expect(e.toString(), contains('404'));
      expect(e.toString(), contains('Not Found'));
    });
  });

  group('HttpService 实例与配置', () {
    test('单例实例相同', () {
      expect(identical(HttpService.instance, HttpService.instance), isTrue);
    });

    test('baseUrl 配置正确', () {
      expect(HttpService.baseUrl, 'https://api.example.com');
    });

    test('rawDio 可访问', () {
      expect(HttpService.instance.rawDio, isA<Dio>());
    });

    test('setDioForTesting 可替换底层 Dio', () {
      final original = HttpService.instance.rawDio;
      final mockDio = Dio();
      HttpService.instance.setDioForTesting(mockDio);
      expect(identical(HttpService.instance.rawDio, mockDio), isTrue);
      // 恢复
      HttpService.instance.setDioForTesting(original);
      expect(identical(HttpService.instance.rawDio, original), isTrue);
    });
  });

  group('HttpService.getRaw - 用 DioAdapter mock 网络', () {
    late HttpService http;
    late Dio mockDio;

    setUp(() {
      http = HttpService.instance;
      mockDio = Dio(BaseOptions(baseUrl: 'https://mock.test'));
      http.setDioForTesting(mockDio);
    });

    tearDown(() {
      http.setDioForTesting(Dio(BaseOptions(baseUrl: HttpService.baseUrl)));
    });

    test('getRaw 成功返回原始 Response', () async {
      mockDio.httpClientAdapter = _FakeAdapter({
        'tag_name': 'v1.0.0',
        'name': 'release',
      });

      final res = await http.getRaw<Map<String, dynamic>>(
        'https://api.github.com/test',
      );
      expect(res.statusCode, 200);
      expect(res.data?['tag_name'], 'v1.0.0');
      expect(res.data?['name'], 'release');
    });

    test('getRaw 连接超时转换为 ApiException', () async {
      mockDio.httpClientAdapter = _FakeAdapter.error(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: 'x'),
        ),
      );
      await expectLater(
        http.getRaw<Map<String, dynamic>>('https://test.com'),
        throwsA(isA<ApiException>()),
      );
    });

    test('getRaw 连接错误转换为 ApiException（含友好提示）', () async {
      mockDio.httpClientAdapter = _FakeAdapter.error(
        DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: 'x'),
        ),
      );
      await expectLater(
        http.getRaw<Map<String, dynamic>>('https://test.com'),
        throwsA(predicate<ApiException>((e) => e.message.contains('网络连接失败'))),
      );
    });

    test('getRaw HTTP 500 错误转换为 ApiException', () async {
      mockDio.httpClientAdapter = _FakeAdapter.error(
        DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: 'https://test.com'),
          response: Response(
            requestOptions: RequestOptions(path: 'https://test.com'),
            statusCode: 500,
          ),
        ),
      );
      await expectLater(
        http.getRaw<Map<String, dynamic>>('https://test.com'),
        throwsA(predicate<ApiException>((e) => e.message.contains('服务器错误'))),
      );
    });

    test('getRaw 取消错误转换为 ApiException', () async {
      mockDio.httpClientAdapter = _FakeAdapter.error(
        DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: 'x'),
        ),
      );
      await expectLater(
        http.getRaw<Map<String, dynamic>>('https://test.com'),
        throwsA(predicate<ApiException>((e) => e.message.contains('请求已取消'))),
      );
    });

    test('postRaw 成功返回原始 Response', () async {
      mockDio.httpClientAdapter = _FakeAdapter({'created': true}, status: 201);

      final res = await http.postRaw<Map<String, dynamic>>(
        'https://api.test.com/create',
        body: {'name': 'new'},
      );
      expect(res.statusCode, 201);
      expect(res.data?['created'], isTrue);
    });
  });

  group('HttpService.get - 业务 API（{code,message,data}）', () {
    late HttpService http;
    late Dio mockDio;

    setUp(() {
      http = HttpService.instance;
      mockDio = Dio(BaseOptions(baseUrl: 'https://mock.test'));
      http.setDioForTesting(mockDio);
    });

    tearDown(() {
      http.setDioForTesting(Dio(BaseOptions(baseUrl: HttpService.baseUrl)));
    });

    test('成功响应解析为 ApiResponse', () async {
      mockDio.httpClientAdapter = _FakeAdapter({
        'code': 0,
        'message': 'ok',
        'data': {'id': 1},
      });

      final res = await http.get<Map<String, dynamic>>(
        '/users',
        fromData: (d) => Map<String, dynamic>.from(d as Map),
      );
      expect(res.isSuccess, isTrue);
      expect(res.data?['id'], 1);
    });

    test('业务失败 code!=0 抛 ApiException', () async {
      mockDio.httpClientAdapter = _FakeAdapter({
        'code': 1001,
        'message': '参数错误',
        'data': null,
      });

      await expectLater(
        http.get<dynamic>('/users'),
        throwsA(
          predicate<ApiException>((e) => e.code == 1001 && e.message == '参数错误'),
        ),
      );
    });

    test('响应格式异常（非 Map）返回 code=-1', () async {
      mockDio.httpClientAdapter = _FakeAdapter(12345);

      final res = await http.get<dynamic>('/users');
      expect(res.code, -1);
      expect(res.isSuccess, isFalse);
    });

    test('响应为 JSON 字符串时也能解析', () async {
      mockDio.httpClientAdapter = _FakeAdapter.rawString(
        '{"code":0,"message":"ok","data":{"v":1}}',
      );

      final res = await http.get<Map<String, dynamic>>(
        '/test',
        fromData: (d) => Map<String, dynamic>.from(d as Map),
      );
      expect(res.isSuccess, isTrue);
      expect(res.data?['v'], 1);
    });
  });
}

/// 极简 Mock Adapter：返回固定的 JSON 数据或抛出指定异常
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.data, {this.status = 200})
    : rawStringBody = null,
      exception = null;
  _FakeAdapter.error(this.exception)
    : data = null,
      rawStringBody = null,
      status = 200;
  _FakeAdapter.rawString(this.rawStringBody)
    : data = null,
      status = 200,
      exception = null;

  final dynamic data;
  final String? rawStringBody;
  final int status;
  final DioException? exception;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (exception != null) throw exception!;

    final String body;
    if (rawStringBody != null) {
      body = rawStringBody!;
    } else if (data != null) {
      body = jsonEncode(data);
    } else {
      body = 'null';
    }

    final bytes = utf8.encode(body);
    return ResponseBody(
      Stream.value(bytes),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
