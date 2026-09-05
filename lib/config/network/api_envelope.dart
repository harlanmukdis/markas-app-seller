import 'package:dio/dio.dart';

import '../../core/data_state.dart';
import '../../core/utils/json_parse.dart';
import 'api_exception.dart';

/// Every successful response shares one shape (API doc 1.3):
///
/// ```jsonc
/// { "success": true, "data": <anything>, "error": null }
/// { "success": true, "data": [...], "error": null, "meta": { "limit": 50, "offset": 0 } }
/// ```
///
/// Services unwrap through this rather than reaching into `response.data`
/// directly, so a malformed body fails in one place with a useful message.
class ApiEnvelope {
  const ApiEnvelope({this.data, this.meta});

  final dynamic data;
  final Map<String, dynamic>? meta;

  factory ApiEnvelope.from(Response<dynamic> response) {
    final body = asMapOrNull(response.data);

    if (body == null) {
      throw ApiException(
        code: DataErrorCode.parse,
        message: 'Server membalas dengan format yang tidak dikenali.',
        statusCode: response.statusCode,
      );
    }

    // A `success: false` body that still arrived with a 2xx status. Rare, but
    // cheaper to handle than to debug.
    if (!asBool(body['success'], fallback: true)) {
      final envelopeError = asMap(body['error']);
      throw ApiException(
        code: asString(envelopeError['code'],
            fallback: DataErrorCode.unexpected),
        message: asString(
          envelopeError['message'],
          fallback: 'Permintaan gagal diproses server.',
        ),
        details: asMapOrNull(envelopeError['details']),
        statusCode: response.statusCode,
      );
    }

    return ApiEnvelope(
      data: body['data'],
      meta: asMapOrNull(body['meta']),
    );
  }

  bool get isNull => data == null;

  Map<String, dynamic> get map => asMap(data);

  List<Map<String, dynamic>> get list => asMapList(data);

  /// Some list endpoints return the rows under a key instead of at the top
  /// level; this keeps a single call site for that.
  List<Map<String, dynamic>> listAt(String key) {
    if (data is List) return list;
    return asMapList(map[key]);
  }

  int? get limit => asIntOrNull(meta?['limit']);

  int? get offset => asIntOrNull(meta?['offset']);
}
