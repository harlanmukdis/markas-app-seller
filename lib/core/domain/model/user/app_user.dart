import '../../../utils/json_parse.dart';
import '../store/store.dart';

/// `GET /me` — the account, the roles it currently holds, and the stores it
/// owns.
///
/// One account can hold several roles at once (buyer, seller, affiliate, …)
/// and own several stores. That is the central difference from the previous
/// backend, where an account *was* a store and the identity came from the JWT.
class AppUser {
  const AppUser({
    required this.id,
    this.email,
    this.phone,
    this.fullName,
    this.avatarUrl,
    this.status,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.roles = const <UserRole>[],
    this.stores = const <Store>[],
    this.createdAt,
  });

  final int id;
  final String? email;
  final String? phone;
  final String? fullName;
  final String? avatarUrl;

  /// `active`, and presumably `suspended` / `banned` elsewhere.
  final String? status;

  final bool emailVerified;
  final bool phoneVerified;
  final List<UserRole> roles;
  final List<Store> stores;
  final DateTime? createdAt;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: asInt(json['id']),
        email: asStringOrNull(json['email']),
        phone: asStringOrNull(json['phone']),
        fullName: asStringOrNull(json['full_name']),
        avatarUrl: asStringOrNull(json['avatar_url']),
        status: asStringOrNull(json['status']),
        emailVerified: asBool(json['email_verified']),
        phoneVerified: asBool(json['phone_verified']),
        roles: asModelList(json['roles'], UserRole.fromJson),
        stores: asModelList(json['stores'], Store.fromJson),
        createdAt: asCreatedDate(json),
      );

  bool get isSeller => roles.any((role) => role.code == UserRoleCode.seller);

  bool get hasStore => stores.isNotEmpty;

  String get displayName =>
      (fullName ?? '').isNotEmpty ? fullName! : (email ?? 'Akun $id');
}

class UserRole {
  const UserRole({required this.code, this.name});

  final String code;
  final String? name;

  factory UserRole.fromJson(Map<String, dynamic> json) => UserRole(
        code: asString(json['code']),
        name: asStringOrNull(json['name']),
      );
}

abstract class UserRoleCode {
  static const String buyer = 'buyer';
  static const String seller = 'seller';
  static const String affiliate = 'affiliate';

  static String label(String? code) => switch (code) {
        buyer => 'Pembeli',
        seller => 'Penjual',
        affiliate => 'Afiliasi',
        _ => code ?? '-',
      };
}
