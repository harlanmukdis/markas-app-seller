import '../../../utils/json_parse.dart';

/// What `login` and `refresh` hand back.
///
/// Unlike the previous backend, this one carries **no identity at all** in the
/// session response — no user id, no store id, no role. Those come from
/// `GET /me`, which also lists the stores the account owns. A session is
/// therefore only a pair of tokens plus how long the short one lasts.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 900,
    this.requiresReconsent = false,
  });

  final String accessToken;

  /// Absent from `refresh` on some paths, so saving a session must never clear
  /// a refresh token it did not receive.
  final String? refreshToken;

  final String tokenType;

  /// Seconds. **900** — fifteen minutes, not the two hours the old API gave.
  /// Short enough that refresh is a normal part of every session rather than
  /// an edge case, which is why the interceptor queues rather than retries.
  final int expiresIn;

  /// Set when the account must re-accept a legal document before it can act
  /// (UU PDP consent). The tokens are valid; the account is not free to use
  /// them yet.
  final bool requiresReconsent;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: asString(json['access_token']),
        refreshToken: asStringOrNull(json['refresh_token']),
        tokenType: asString(json['token_type'], fallback: 'Bearer'),
        expiresIn: asInt(json['expires_in'], fallback: 900),
        requiresReconsent: asBool(json['requires_reconsent']),
      );
}

/// `POST /auth/register`.
///
/// Creates the account but does **not** log it in: there is no token here, and
/// the email must be verified first. In a dev build the server hands back the
/// verification token directly so the flow can be completed without a mailbox.
class RegistrationResult {
  const RegistrationResult({required this.userId, this.devVerificationToken});

  final int userId;
  final String? devVerificationToken;

  factory RegistrationResult.fromJson(Map<String, dynamic> json) =>
      RegistrationResult(
        userId: asInt(json['user_id']),
        devVerificationToken:
            asStringOrNull(json['dev_verification_token']),
      );

  bool get canSelfVerify => (devVerificationToken ?? '').isNotEmpty;
}
