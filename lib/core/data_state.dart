/// Result wrapper returned by every repository method.
///
/// Repositories never throw (CLAUDE.md, "Repositories never throw") — they
/// catch, translate, and hand back one of these. Cubits pattern-match on the
/// variant instead of using try/catch for control flow.
sealed class DataState<T> {
  const DataState({this.data, this.error});

  final T? data;
  final DataError? error;
}

/// In flight. Repositories do not return this; cubits emit it before awaiting.
final class DataLoading<T> extends DataState<T> {
  const DataLoading();
}

final class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);

  T get value => data as T;
}

/// The call succeeded but there is nothing to show — an empty collection, or a
/// `200` carrying `data: null` (which several endpoints do instead of 404).
final class DataEmpty<T> extends DataState<T> {
  const DataEmpty();
}

final class DataFailed<T> extends DataState<T> {
  const DataFailed(DataError error) : super(error: error);

  DataError get failure => error!;
}

/// A failure the UI can act on.
///
/// [code] is the backend's `error.code` (`VALIDATION_ERROR`,
/// `GATES_NOT_PASSED`, …) and [details] its `error.details`, which for several
/// endpoints is the only place that says *which* field or gate failed. Both are
/// carried all the way to the screen on purpose — the API doc is explicit that
/// generic error messages are not good enough here.
class DataError {
  const DataError({
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
  });

  final String code;
  final String message;
  final Map<String, dynamic>? details;
  final int? statusCode;

  /// Last-resort wrapper for anything that is not already an [ApiException],
  /// e.g. a bug in a `fromJson`.
  factory DataError.unexpected(Object error) => DataError(
        code: DataErrorCode.unexpected,
        message: error.toString(),
      );

  bool get isUnauthenticated => code == DataErrorCode.unauthenticated;

  bool get isNoSellerContext => code == DataErrorCode.noSellerContext;

  /// `error.details.missing` on a 422, when present.
  List<String> get missingFields {
    final missing = details?['missing'];
    if (missing is List) {
      return missing.map((e) => e.toString()).toList(growable: false);
    }
    return const <String>[];
  }

  @override
  String toString() => 'DataError($code, $message)';
}

/// Error codes the app branches on. Documented in API doc 1.5; anything not
/// listed here still arrives intact in [DataError.code].
abstract class DataErrorCode {
  static const String malformedJson = 'MALFORMED_JSON';
  static const String unauthenticated = 'UNAUTHENTICATED';
  static const String forbidden = 'FORBIDDEN';
  static const String noSellerContext = 'NO_SELLER_CONTEXT';
  static const String notFound = 'NOT_FOUND';
  static const String methodNotAllowed = 'METHOD_NOT_ALLOWED';
  static const String invalidTransition = 'INVALID_TRANSITION';
  static const String invalidState = 'INVALID_STATE';
  static const String conflict = 'CONFLICT';
  static const String validationError = 'VALIDATION_ERROR';
  static const String gatesNotPassed = 'GATES_NOT_PASSED';
  static const String dbError = 'DB_ERROR';

  /// Client-side only.
  static const String network = 'NETWORK_ERROR';
  static const String timeout = 'TIMEOUT';
  static const String parse = 'PARSE_ERROR';
  static const String unexpected = 'UNEXPECTED';
}
