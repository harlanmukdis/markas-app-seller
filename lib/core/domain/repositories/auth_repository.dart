import '../../data_state.dart';
import '../model/auth/auth_session.dart';
import '../model/user/app_user.dart';

abstract class AuthRepository {
  /// Creates the account. It is **not** logged in afterwards: the email has to
  /// be verified first, and a dev build returns the token to do that inline.
  Future<DataState<RegistrationResult>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  Future<DataState<bool>> verifyEmail(String token);

  Future<DataState<bool>> resendVerification(String email);

  Future<DataState<AuthSession>> login({
    required String email,
    required String password,
  });

  /// Who this is, which roles they hold, and which stores they own — the only
  /// place any of that is available, since the session carries no identity.
  Future<DataState<AppUser>> me();

  Future<DataState<bool>> forgotPassword(String email);

  Future<DataState<bool>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Revokes the refresh token server-side before clearing local state, so a
  /// stolen token cannot outlive the logout by thirty days.
  Future<void> logout();

  bool get isLoggedIn;

  int? get activeStoreId;

  Future<void> setActiveStore(int storeId);
}
