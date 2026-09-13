import '../../domain/model/auth/auth_session.dart';
import '../../utils/constant.dart';
import '../../utils/json_parse.dart';
import '../../utils/local_network.dart';

/// Everything the app remembers between launches, backed by SharedPreferences
/// (which on web is `localStorage`).
///
/// The stored **active store id** is a UI choice, not an identity. An account
/// can own several stores; the server decides what the caller may do from the
/// JWT plus the `X-Store-Id` header, and answers 403 when the two disagree.
/// Losing this value logs nobody out — it just means the app has to ask which
/// store to open.
class SessionStore {
  // Read through the tolerant parsers rather than casting: a value written by
  // an older build (or a hand-edited localStorage entry in the browser) can be
  // a String where an int is expected, and a hard cast would crash on boot.
  String? get accessToken => asStringOrNull(CachedHelper.getData(kAccessToken));

  String? get refreshToken =>
      asStringOrNull(CachedHelper.getData(kRefreshToken));

  int? get activeStoreId => asIntOrNull(CachedHelper.getData(kActiveStoreId));

  int? get userId => asIntOrNull(CachedHelper.getData(kUserId));

  String? get fullName => asStringOrNull(CachedHelper.getData(kUserFullName));

  String? get email => asStringOrNull(CachedHelper.getData(kUserEmail));

  String? get phone => asStringOrNull(CachedHelper.getData(kUserPhone));

  bool get isLoggedIn => (accessToken ?? '').isNotEmpty;

  bool get hasStoreContext => activeStoreId != null;

  /// Persists a session.
  ///
  /// A refresh response may omit the refresh token; overwriting the stored one
  /// with null would end the session at the next reload.
  Future<void> save(AuthSession session) async {
    await CachedHelper.saveData(kAccessToken, session.accessToken);

    final refresh = session.refreshToken;
    if (refresh != null && refresh.isNotEmpty) {
      await CachedHelper.saveData(kRefreshToken, refresh);
    }
  }

  Future<void> saveAccessToken(String token) =>
      CachedHelper.saveData(kAccessToken, token);

  Future<void> saveProfile({
    int? userId,
    String? fullName,
    String? email,
    String? phone,
  }) async {
    if (userId != null) await CachedHelper.saveData(kUserId, userId);
    if (fullName != null) await CachedHelper.saveData(kUserFullName, fullName);
    if (email != null) await CachedHelper.saveData(kUserEmail, email);
    if (phone != null) await CachedHelper.saveData(kUserPhone, phone);
  }

  Future<void> saveActiveStore(int storeId) =>
      CachedHelper.saveData(kActiveStoreId, storeId);

  Future<void> clearActiveStore() => CachedHelper.removeData(kActiveStoreId);

  Future<void> clear() async {
    for (final key in <String>[
      kAccessToken,
      kRefreshToken,
      kActiveStoreId,
      kUserId,
      kUserFullName,
      kUserEmail,
      kUserPhone,
    ]) {
      await CachedHelper.removeData(key);
    }
  }
}
