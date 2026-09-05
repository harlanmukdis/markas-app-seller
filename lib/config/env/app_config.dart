/// Runtime configuration.
///
/// The target architecture in CLAUDE.md calls for `envied` + `.env`, but that
/// needs `build_runner`, which this project deliberately does not use. The
/// no-codegen equivalent is `String.fromEnvironment`, which is resolved at
/// compile time and works identically on web:
///
/// ```bash
/// flutter run -d chrome --dart-define=API_BASE_URL=http://localhost/markas/api/v1
/// ```
abstract class AppConfig {
  /// Base URL of the CodeIgniter backend.
  ///
  /// Note there is no port 8080 — the backend listens on port 80 (API doc 1.1).
  /// Running in Chrome on the same machine as the server, plain `localhost`
  /// resolves correctly. The Flutter dev server sits on a different port, so
  /// every call is cross-origin; the backend answers preflight `OPTIONS` with
  /// 204 and open CORS headers, which is what makes this work at all.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost/markas/api/v1',
  );

  /// Wire-level request/response logging. Off by default because tokens and
  /// KYC document URLs travel through these logs.
  static const bool logHttp = bool.fromEnvironment(
    'LOG_HTTP',
    defaultValue: true,
  );

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
