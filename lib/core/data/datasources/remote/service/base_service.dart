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

  /// [receiveTimeout] overrides the client-wide budget for this one call.
  ///
  /// Needed by the chat long-poll, which deliberately holds the connection
  /// open for up to 25 seconds before answering. The default 30-second budget
  /// technically covers that, but with so little margin that ordinary latency
  /// would surface as a connection failure rather than an empty result.
  Future<ApiEnvelope> getRequest(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    Duration? receiveTimeout,
  }) =>
      _send(() => dio.get<dynamic>(
            path,
            queryParameters: _clean(query),
            options: receiveTimeout == null
                ? _options(headers)
                : (_options(headers) ?? Options())
                    .copyWith(receiveTimeout: receiveTimeout),
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

  /// A **form-encoded** POST, for the handful of endpoints that read their
  /// fields with the REST library's `post()` helper.
  ///
  /// That helper only ever reads `$_POST`, which PHP populates from a form body
  /// and never from JSON — so those endpoints see an empty request when sent
  /// JSON. The damage is silent rather than loud: `POST /orders/{id}/ship` still
  /// moves the order to `shipped`, it just stores a null AWB. Known members of
  /// this group: `orders/{id}/ship`, `orders/{id}/cancel`,
  /// `orders/{id}/refund-request`, `admin/verifications/{id}/reject`,
  /// `vouchers/claim`. Everything else on this API wants JSON.
  Future<ApiEnvelope> postFormRequest(
    String path, {
    required Map<String, String> fields,
    Map<String, dynamic>? headers,
  }) =>
      _send(() => dio.post<dynamic>(
            path,
            data: fields,
            options: (_options(headers) ?? Options()).copyWith(
              contentType: Headers.formUrlEncodedContentType,
            ),
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
