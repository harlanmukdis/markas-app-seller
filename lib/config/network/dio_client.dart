import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/data/local/session_store.dart';
import '../env/app_config.dart';
import 'auth_interceptor.dart';

/// Builds the HTTP clients.
///
/// One named `"api"` Dio singleton is registered in `lib/di/injector.dart` and
/// handed to every service. A feature domain that talks to a *different* base
/// URL later should register its own named singleton here rather than mutating
/// this one.
abstract class DioClient {
  /// The instance name used with `get_it`.
  static const String apiInstanceName = 'api';

  static BaseOptions _baseOptions() => BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        // The backend reads `php://input` and parses it as JSON. form-data and
        // x-www-form-urlencoded are not read at all and surface as a confusing
        // 422 VALIDATION_ERROR (API doc 1.2), so the content type is pinned
        // here rather than left to each call site.
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: <String, dynamic>{'Accept': 'application/json'},
      );

  /// The authenticated client every service uses.
  static Dio create({
    required SessionStore sessionStore,
    void Function()? onSessionExpired,
  }) {
    final dio = Dio(_baseOptions());

    dio.interceptors.add(
      AuthInterceptor(
        sessionStore: sessionStore,
        refreshDio: createBare(),
        onSessionExpired: onSessionExpired,
      ),
    );

    if (kDebugMode && AppConfig.logHttp) {
      dio.interceptors.add(_CompactLogInterceptor());
    }

    return dio;
  }

  /// No interceptors. Used for the token refresh call and for replaying a
  /// request after a refresh — both of which would recurse through
  /// [AuthInterceptor] otherwise.
  static Dio createBare() => Dio(_baseOptions());
}

/// One line per request and per outcome. Dio's own LogInterceptor prints whole
/// bodies, which in this app means access tokens and KYC document URLs in the
/// browser console.
class _CompactLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Written out rather than as a chain of null-aware operators: inside a
    // ternary branch, `?[` parses as a nested conditional with a list literal
    // and the whole expression stops compiling.
    String? code;
    final body = err.response?.data;
    if (body is Map) {
      final envelopeError = body['error'];
      if (envelopeError is Map) code = envelopeError['code']?.toString();
    }

    final status = err.response?.statusCode ?? err.type.name;
    final suffix = code == null ? '' : ' ($code)';
    debugPrint(
      '✗ $status ${err.requestOptions.method} '
      '${err.requestOptions.uri.path}$suffix',
    );
    handler.next(err);
  }
}
