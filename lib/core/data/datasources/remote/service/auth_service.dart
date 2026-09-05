import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/auth/auth_session.dart';
import '../../../../domain/model/auth/user_model.dart';
import '../../../../domain/model/enums.dart';
import 'base_service.dart';

class AuthService extends BaseService {
  const AuthService(super.dio);

  /// Creates a store account.
  ///
  /// The store is born `DRAFT` with `trial_started_at` set. A `seller_type`
  /// outside TOKO/DISTRIBUTOR is silently coerced to TOKO by the backend, so
  /// the picker only offers those two.
  ///
  /// Returns **no refresh token** (API doc 1.4) — the caller is expected to
  /// follow up with [login] if it wants a long-lived session.
  Future<AuthSession> register({
    required String phone,
    required String password,
    required String fullName,
    required String tokoName,
    String sellerType = SellerType.toko,
    String? email,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.register,
      body: <String, dynamic>{
        'phone': phone,
        'password': password,
        'full_name': fullName,
        'role': UserRole.seller,
        'toko_name': tokoName,
        'seller_type': sellerType,
        'email': email,
      },
    );
    return AuthSession.fromJson(envelope.map);
  }

  Future<AuthSession> login({
    required String phone,
    required String password,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.login,
      body: <String, dynamic>{'phone': phone, 'password': password},
    );
    return AuthSession.fromJson(envelope.map);
  }

  Future<UserModel> me() async {
    final envelope = await getRequest(ApiEndpoints.me);
    return UserModel.fromJson(envelope.map);
  }
}
