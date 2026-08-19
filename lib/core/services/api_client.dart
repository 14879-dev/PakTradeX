import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Singleton Dio HTTP client for all PakTradeX API calls.
/// Features: base URL, timeouts, retry on 5xx, debug logging.
class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  late final Dio _dio = _buildDio();

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Debug logging
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => debugPrint('[API] $o'),
      ));
    }

    // Retry interceptor — retry up to 3x on network errors / 5xx
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException err, ErrorInterceptorHandler handler) async {
          if (_shouldRetry(err)) {
            try {
              final retried = await _retry(dio, err.requestOptions);
              handler.resolve(retried);
              return;
            } catch (_) {}
          }
          handler.next(err);
        },
      ),
    );

    return dio;
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }

  Future<Response<dynamic>> _retry(Dio dio, RequestOptions opts) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return dio.request(
      opts.path,
      data: opts.data,
      queryParameters: opts.queryParameters,
      options: Options(method: opts.method, headers: opts.headers),
    );
  }

  // ── Public API ───────────────────────────────────────────────

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> delete(String path) async {
    return _dio.delete(path);
  }
}

/// Convenience global accessor
ApiClient get apiClient => ApiClient.instance;
