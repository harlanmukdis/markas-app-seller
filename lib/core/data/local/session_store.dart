import '../../domain/model/auth/auth_session.dart';
import '../../utils/constant.dart';
import '../../utils/json_parse.dart';
import '../../utils/local_network.dart';

/// Everything the app remembers about the logged-in store, backed by
/// SharedPreferences (which on web is `localStorage`).
///
/// `seller_id` lives here because it is needed in the URL of nearly every
/// onboarding call. That is *not* the same as it being an identity: the backend
/// takes the store's identity from the JWT claim and rejects a `{id}` that does
/// not match with 403 (API doc 2). The stored copy just saves a round trip.
class SessionStore {
  // Read through the tolerant parsers rather than casting: a value written by
  // an older build (or a hand-edited localStorage entry in the browser) can be
  // a String where an int is expected, and a hard cast would crash on boot.
  String? get accessToken => asStringOrNull(CachedHelper.getData(kAccessToken));

  String? get refreshToken =>
      asStringOrNull(CachedHelper.getData(kRefreshToken));

  int? get sellerId => asIntOrNull(CachedHelper.getData(kSellerId));

  int? get userId => asIntOrNull(CachedHelper.getData(kUserId));

  String? get role => asStringOrNull(CachedHelper.getData(kUserRole));

  String? get fullName => asStringOrNull(CachedHelper.getData(kUserFullName));

  String? get phone => asStringOrNull(CachedHelper.getData(kUserPhone));

  bool get isLoggedIn => (accessToken ?? '').isNotEmpty;

  bool get hasSellerContext => sellerId != null;

  /// Persists a session.
  ///
  /// Fields absent from the response are left untouched rather than cleared:
  /// `refresh` returns no `seller_id`, and `register` returns no
  /// `refresh_token` (API doc 1.4). Overwriting with null on either would log
  /// the store out sideways.
  Future<void> save(AuthSession session) async {
    await CachedHelper.saveData(kAccessToken, session.accessToken);

    final refresh = session.refreshToken;
    if (refresh != null && refresh.isNotEmpty) {
      await CachedHelper.saveData(kRefreshToken, refresh);
    }

    final sellerId = session.sellerId;
    if (sellerId != null) {
      await CachedHelper.saveData(kSellerId, sellerId);
    }

    final userId = session.userId;
    if (userId != null) {
      await CachedHelper.saveData(kUserId, userId);
    }

    final role = session.role;
    if (role != null) {
      await CachedHelper.saveData(kUserRole, role);
    }
  }

  Future<void> saveAccessToken(String token) =>
      CachedHelper.saveData(kAccessToken, token);

  Future<void> saveProfile({String? fullName, String? phone}) async {
    if (fullName != null) await CachedHelper.saveData(kUserFullName, fullName);
    if (phone != null) await CachedHelper.saveData(kUserPhone, phone);
  }

  Future<void> clear() async {
    await CachedHelper.removeData(kAccessToken);
    await CachedHelper.removeData(kRefreshToken);
    await CachedHelper.removeData(kSellerId);
    await CachedHelper.removeData(kUserId);
    await CachedHelper.removeData(kUserRole);
    await CachedHelper.removeData(kUserFullName);
    await CachedHelper.removeData(kUserPhone);
    await CachedHelper.removeData(kKycSubmittedDocTypes);
  }

  /// Client-side note of which KYC doc types have been sent. The API has no
  /// endpoint to read documents back, so without this the upload screen is
  /// blind and stores re-send the same file. Local only — it says nothing about
  /// whether an admin approved anything.
  List<String> get submittedKycDocTypes {
    final stored = CachedHelper.getData(kKycSubmittedDocTypes);
    if (stored is List<String>) return stored;
    return const <String>[];
  }

  Future<void> markKycDocTypeSubmitted(String docType) async {
    final current = submittedKycDocTypes.toList();
    if (current.contains(docType)) return;
    current.add(docType);
    await CachedHelper.saveData(kKycSubmittedDocTypes, current);
  }
}
