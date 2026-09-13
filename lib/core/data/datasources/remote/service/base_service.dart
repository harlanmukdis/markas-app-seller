import 'package:dio/dio.dart';

import '../../../../../config/network/api_envelope.dart';
import '../../../../../config/network/api_exception.dart';

/// Shared plumbing for every `*Service`.
///
/// Services are the layer that owns raw HTTP: they catch [DioException] and
/// rethrow a plain [ApiException] carrying the backend's own error code, so
/// nothing above this line ever imports Dio (CLAUDE.md, "Services own caching
/// and raw HTTP errors").
abstract class BaseService {
  const BaseService(this.dio);

  final Dio dio;

  Future<ApiEnvelope> getRequest(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) =>
      _send(() => dio.get<dynamic>(
            path,
            queryParameters: _clean(query),
            options: _options(headers),
          ));

  /// [body] is cleaned of nulls and sent as JSON. [data] is passed through
  /// untouched, which is how a `FormData` upload gets past the cleaner.
  Future<ApiEnvelope> postRequest(
    String path, {
    Map<String, dynamic>? body,
    Object? data,
    Map<String, dynamic>? headers,
  }) =>
      _send(() => dio.post<dynamic>(
            path,
            data: data ?? _clean(body),
            options: _options(headers),
          ));

  Future<ApiEnvelope> putRequest(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) =>
      _send(() => dio.put<dynamic>(
            path,
            data: _clean(body),
            options: _options(headers),
          ));

  Future<ApiEnvelope> patchRequest(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) =>
      _send(() => dio.patch<dynamic>(
            path,
            data: _clean(body),
            options: _options(headers),
          ));

  Future<ApiEnvelope> deleteRequest(
    String path, {
    Map<String, dynamic>? headers,
  }) =>
      _send(() => dio.delete<dynamic>(path, options: _options(headers)));

  Options? _options(Map<String, dynamic>? headers) =>
      headers == null ? null : Options(headers: headers);

  Future<ApiEnvelope> _send(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      return ApiEnvelope.from(await call());
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// Drops null entries so an optional field is genuinely absent rather than
  /// sent as `null` — several endpoints treat an explicit null as "clear this".
  Map<String, dynamic>? _clean(Map<String, dynamic>? input) {
    if (input == null) return null;
    final cleaned = <String, dynamic>{};
    input.forEach((key, value) {
      if (value != null) cleaned[key] = value;
    });
    return cleaned;
  }
}
