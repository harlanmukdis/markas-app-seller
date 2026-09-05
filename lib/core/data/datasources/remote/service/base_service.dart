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
  }) =>
      _send(() => dio.get<dynamic>(path, queryParameters: _clean(query)));

  Future<ApiEnvelope> postRequest(
    String path, {
    Map<String, dynamic>? body,
  }) =>
      _send(() => dio.post<dynamic>(path, data: _clean(body)));

  Future<ApiEnvelope> putRequest(
    String path, {
    Map<String, dynamic>? body,
  }) =>
      _send(() => dio.put<dynamic>(path, data: _clean(body)));

  Future<ApiEnvelope> patchRequest(
    String path, {
    Map<String, dynamic>? body,
  }) =>
      _send(() => dio.patch<dynamic>(path, data: _clean(body)));

  Future<ApiEnvelope> deleteRequest(String path) =>
      _send(() => dio.delete<dynamic>(path));

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
