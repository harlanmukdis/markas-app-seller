import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/auth/auth_session.dart';
import '../../../../domain/model/user/app_user.dart';
import 'base_service.dart';

class AuthService extends BaseService {
  const AuthService(super.dio);

  /// Creates the account. Every account starts as a **buyer**; it becomes a
  /// seller by creating a store.
  ///
  /// No token comes back and the account cannot log in until its email is
  /// verified — but a dev build returns the verification token inline, which
  /// is what makes the signup flow completable without a mailbox.
  Future<RegistrationResult> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.register,
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone': phone,
      },
    );
    return RegistrationResult.fromJson(envelope.map);
  }

  Future<void> verifyEmail(String token) async {
    await postRequest(
      ApiEndpoints.verifyEmail,
      body: <String, dynamic>{'token': token},
    );
  }

  Future<void> resendVerification(String email) async {
    await postRequest(
      ApiEndpoints.resendVerification,
      body: <String, dynamic>{'email': email},
    );
  }

  /// Identity is by **email**, not phone — the previous backend's login field.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.login,
      body: <String, dynamic>{'email': email, 'password': password},
    );
    return AuthSession.fromJson(envelope.map);
  }

  /// Revokes the refresh token server-side. Without this a "logout" only
  /// forgets the tokens locally and they stay valid for 30 days.
  Future<void> logout(String refreshToken) async {
    await postRequest(
      ApiEndpoints.logout,
      body: <String, dynamic>{'refresh_token': refreshToken},
    );
  }

  Future<void> forgotPassword(String email) async {
    await postRequest(
      ApiEndpoints.forgotPassword,
      body: <String, dynamic>{'email': email},
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await postRequest(
      ApiEndpoints.resetPassword,
      body: <String, dynamic>{'token': token, 'new_password': newPassword},
    );
  }

  /// The only source of identity: who this is, which roles they hold, and
  /// which stores they own. The session response carries none of it.
  Future<AppUser> me() async {
    final envelope = await getRequest(ApiEndpoints.me);
    return AppUser.fromJson(envelope.map);
  }

  Future<AppUser> updateProfile({String? fullName, String? avatarUrl}) async {
    final envelope = await patchRequest(
      ApiEndpoints.me,
      body: <String, dynamic>{
        'full_name': fullName,
        'avatar_url': avatarUrl,
      },
    );
    return AppUser.fromJson(envelope.map);
  }
}
