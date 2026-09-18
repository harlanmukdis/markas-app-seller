import 'package:dio/dio.dart';

import '../../core/data_state.dart';
import '../../core/utils/json_parse.dart';
import 'api_exception.dart';

/// Every successful response shares one shape (`docs/03-api-documentation.md`,
/// "Format response standar"):
///
/// ```jsonc
/// { "success": true, "data": <anything>, "error": null }
/// { "success": true, "data": [...], "error": null, "meta": { "page": 1, "per_page": 20, "total": 100 } }
/// ```
///
/// Services unwrap through this rather than reaching into `response.data`
/// directly, so a malformed body fails in one place with a useful message —
/// including the raw HTML error page the backend returns instead of JSON when a
/// query hits a constraint (an unknown `product_variant_id` on `/stock-in`, for
/// one), which arrives as a 500 with no envelope at all.
///
/// **`meta` is not universal.** Only a few list endpoints send it: `GET
/// /products` does (with an extra `facets` block), while the store-scoped
/// `GET /stores/{id}/products`, `/warehouses/{id}/movements`,
/// `/stores/{id}/orders` and `/stores/{id}/ratings` all return a bare array and
/// accept `page` without reporting a total. Treat [page] and friends as
/// nullable everywhere rather than assuming a paginated contract.
class ApiEnvelope {
  const ApiEnvelope({this.data, this.meta});

  final dynamic data;
  final Map<String, dynamic>? meta;

  factory ApiEnvelope.from(Response<dynamic> response) {
    final body = asMapOrNull(response.data);

    if (body == null) {
      throw ApiException(
        code: DataErrorCode.parse,
        message: _uncaughtExceptionMessage(response.data) ??
            'Server membalas dengan format yang tidak dikenali.',
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

  /// CodeIgniter renders an uncaught exception as an HTML fragment and still
  /// sends it with **HTTP 200**, so it arrives here rather than as a Dio error.
  /// The one useful thing in it is the exception message — for an order that is
  /// in the wrong state, that message is the whole explanation — so it is
  /// lifted out instead of being replaced by "unrecognised format".
  ///
  /// Order actions are the common case: `POST /orders/{id}/accept` on an order
  /// that is not `paid` answers 200 with
  /// `Message: Order berstatus 'pending', tidak bisa transisi ke 'processed'`.
  static String? _uncaughtExceptionMessage(dynamic data) {
    if (data is! String) return null;
    final match = RegExp(
      r'<p>Message:\s*(.*?)</p>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(data);
    final message = match?.group(1)?.trim();
    if (message == null || message.isEmpty) return null;
    return '$message (server membalas dengan halaman error, bukan JSON)';
  }

  int? get page => asIntOrNull(meta?['page']);

  int? get perPage => asIntOrNull(meta?['per_page']);

  int? get total => asIntOrNull(meta?['total']);

  /// `GET /products` returns a `facets` block inside `meta` — rating buckets and
  /// price ranges for the filter UI. Absent from every other list endpoint.
  Map<String, dynamic>? get facets => asMapOrNull(meta?['facets']);
}
