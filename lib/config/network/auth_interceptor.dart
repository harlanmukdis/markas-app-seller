import 'package:dio/dio.dart';

import '../../core/data/local/session_store.dart';
import '../../core/domain/model/auth/auth_session.dart';
import '../../core/utils/json_parse.dart';
import 'api_endpoints.dart';

/// Attaches the bearer token and transparently refreshes it once on a 401.
///
/// Extends [QueuedInterceptor] rather than [Interceptor] so requests are
/// handled one at a time. That is what stops a screen firing four parallel
/// calls with an expired token from starting four refreshes and racing each
/// other to overwrite the stored token.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.sessionStore,
    required this.refreshDio,
    this.onSessionExpired,
  });

  final SessionStore sessionStore;

  /// A bare Dio with no interceptors, used to run the refresh call and replay
  /// the original request. Reusing the main client here would recurse.
  final Dio refreshDio;

  /// Fired when the refresh token is gone or rejected, so the app can route
  /// back to login instead of leaving the user on a screen full of errors.
  final void Function()? onSessionExpired;

  /// Paths that must never carry an Authorization header, and must never
  /// trigger a refresh attempt on 401.
  static const Set<String> _anonymousPaths = <String>{
    ApiEndpoints.register,
    ApiEndpoints.login,
    ApiEndpoints.refresh,
  };

  static const String _retriedFlag = 'auth_interceptor_retried';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (!_isAnonymous(options.path)) {
      final token = sessionStore.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;

    final shouldRefresh = err.response?.statusCode == 401 &&
        !_isAnonymous(request.path) &&
        request.extra[_retriedFlag] != true &&
        (sessionStore.refreshToken ?? '').isNotEmpty;

    if (!shouldRefresh) {
      if (err.response?.statusCode == 401 && !_isAnonymous(request.path)) {
        await _expire();
      }
      return handler.next(err);
    }

    final refreshed = await _refreshAccessToken();
    if (refreshed == null) {
      await _expire();
      return handler.next(err);
    }

    try {
      final replayed = await refreshDio.fetch<dynamic>(
        request
          ..headers['Authorization'] = 'Bearer $refreshed'
          ..extra[_retriedFlag] = true,
      );
      return handler.resolve(replayed);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  bool _isAnonymous(String path) =>
      _anonymousPaths.any((anonymous) => path.endsWith(anonymous));

  /// Returns the new access token, or null if the refresh failed.
  ///
  /// The request body shape is an assumption: API doc 5.1 documents the
  /// response of `POST /auth/refresh` but not its request. `refresh_token` in
  /// the JSON body is the conventional pairing; if the backend expects it
  /// somewhere else, this is the one place to change.
  Future<String?> _refreshAccessToken() async {
    try {
      final response = await refreshDio.post<dynamic>(
        ApiEndpoints.refresh,
        data: <String, dynamic>{'refresh_token': sessionStore.refreshToken},
      );

      final body = asMapOrNull(response.data);
      if (body == null || !asBool(body['success'], fallback: true)) return null;

      final session = AuthSession.fromJson(asMap(body['data']));
      if (session.accessToken.isEmpty) return null;

      await sessionStore.save(session);
      return session.accessToken;
    } on DioException {
      return null;
    }
  }

  Future<void> _expire() async {
    await sessionStore.clear();
    onSessionExpired?.call();
  }
}
