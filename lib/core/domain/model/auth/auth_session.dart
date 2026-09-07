import '../../../utils/json_parse.dart';

/// What `register`, `login` and `refresh` hand back.
///
/// Two asymmetries from API doc 1.4 that the app has to live with:
/// `register` returns **no** `refresh_token` (so a fresh signup must log in
/// again for a long-lived session), and `refresh` returns no `seller_id`
/// (so a refresh must not overwrite the stored one with null).
class AuthSession {
  const AuthSession({
    required this.accessToken,
    this.refreshToken,
    this.userId,
    this.sellerId,
    this.role,
    this.actorType,
    this.tokenType = 'Bearer',
    this.expiresIn = 7200,
  });

  final String accessToken;
  final String? refreshToken;
  final int? userId;
  final int? sellerId;
  final String? role;

  /// v2.2 addition: `MEMBER`, `MERCHANT` or `ADMIN`. Useful for the very first
  /// routing decision, but [role] is still what decides what a store can do —
  /// `actorType` does not distinguish TOKO from DISTRIBUTOR, or a retail buyer
  /// from a B2B one.
  final String? actorType;

  final String tokenType;

  /// Seconds. 7200 (2 hours) for the access token.
  final int expiresIn;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: asString(json['access_token']),
        refreshToken: asStringOrNull(json['refresh_token']),
        userId: asIntOrNull(json['user_id']),
        sellerId: asIntOrNull(json['seller_id']),
        role: asStringOrNull(json['role']),
        actorType: asStringOrNull(json['actor_type']),
        tokenType: asString(json['token_type'], fallback: 'Bearer'),
        expiresIn: asInt(json['expires_in'], fallback: 7200),
      );

  bool get hasSellerContext => sellerId != null;

  bool get isMerchant => actorType == ActorType.merchant;
}

abstract class ActorType {
  static const String member = 'MEMBER';
  static const String merchant = 'MERCHANT';
  static const String admin = 'ADMIN';
}
