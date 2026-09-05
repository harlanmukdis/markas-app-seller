import 'package:dio/dio.dart';

import '../../core/data_state.dart';
import '../../core/utils/json_parse.dart';

/// The single exception type the service layer throws.
///
/// Services catch [DioException] and rethrow this with the envelope's real
/// `error.code` / `error.message` attached (CLAUDE.md, "Services own caching
/// and raw HTTP errors"). Repositories then turn it into a [DataError].
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
  });

  final String code;
  final String message;
  final Map<String, dynamic>? details;
  final int? statusCode;

  DataError toDataError() => DataError(
        code: code,
        message: message,
        details: details,
        statusCode: statusCode,
      );

  /// Translates a [DioException] into an [ApiException], preferring the
  /// backend's own envelope over Dio's generic message.
  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final body = asMapOrNull(response?.data);
    final envelopeError = asMapOrNull(body?['error']);

    if (envelopeError != null) {
      return ApiException(
        code: asString(envelopeError['code'],
            fallback: DataErrorCode.unexpected),
        message: asString(
          envelopeError['message'],
          fallback: 'Permintaan gagal diproses server.',
        ),
        details: asMapOrNull(envelopeError['details']),
        statusCode: response?.statusCode,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          code: DataErrorCode.timeout,
          message: 'Server tidak merespons tepat waktu. Coba lagi.',
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return ApiException(
          code: DataErrorCode.network,
          message: _connectionMessage(error),
          statusCode: response?.statusCode,
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          code: DataErrorCode.network,
          message: 'Sertifikat server ditolak.',
        );
      case DioExceptionType.cancel:
        return const ApiException(
          code: DataErrorCode.network,
          message: 'Permintaan dibatalkan.',
        );
      case DioExceptionType.badResponse:
        return ApiException(
          code: DataErrorCode.unexpected,
          message: _plainBodyMessage(response),
          statusCode: response?.statusCode,
        );
    }
  }

  /// On web a blocked CORS preflight and a server that is simply not running
  /// are indistinguishable from Dart — the browser refuses to tell us which.
  /// Say so, because "connection error" alone sends people hunting the wrong
  /// problem for an hour.
  static String _connectionMessage(DioException error) {
    return 'Tidak bisa menghubungi server di ${error.requestOptions.baseUrl}. '
        'Periksa server berjalan, dan bila dijalankan di Chrome pastikan CORS '
        'mengizinkan origin aplikasi.';
  }

  static String _plainBodyMessage(Response<dynamic>? response) {
    final status = response?.statusCode;
    final data = response?.data;

    if (data is String && data.trim().isNotEmpty) {
      final body = data.trim();

      // An unhandled PHP/database error escapes CodeIgniter as a full HTML
      // error page instead of the JSON envelope. Rendering that verbatim would
      // put a whole document into a snackbar, so it is summarised instead.
      // Seen for real: POST /sellers/{id}/warehouses with an address_id that
      // does not exist returns a "Database Error" page.
      if (_looksLikeHtml(body)) {
        final title = _htmlTitle(body);
        return 'Server mengalami kesalahan internal (HTTP $status'
            '${title == null ? '' : ': $title'}). '
            'Periksa log backend — respons ini bukan JSON.';
      }

      // A short plain-text body is genuinely useful: an unrouted path answers
      // with a bare "Endpoint not found".
      if (body.length <= 200) return body;
      return '${body.substring(0, 200)}…';
    }

    return 'Server membalas dengan status $status.';
  }

  static bool _looksLikeHtml(String body) {
    final head = body.trimLeft().toLowerCase();
    return head.startsWith('<!doctype html') || head.startsWith('<html');
  }

  static String? _htmlTitle(String body) {
    final match =
        RegExp(r'<title>(.*?)</title>', caseSensitive: false, dotAll: true)
            .firstMatch(body);
    final title = match?.group(1)?.trim();
    return (title == null || title.isEmpty) ? null : title;
  }

  @override
  String toString() => 'ApiException($code, $message)';
}
