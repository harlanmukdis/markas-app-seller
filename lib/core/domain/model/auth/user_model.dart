import '../../../utils/json_parse.dart';

/// `GET /auth/me`. The exact column set is not pinned down in the API doc, so
/// unknown fields are kept in [raw] rather than dropped.
class UserModel {
  const UserModel({
    required this.id,
    required this.phone,
    required this.fullName,
    this.email,
    this.role,
    this.status,
    this.createdAt,
    this.raw = const <String, dynamic>{},
  });

  final int id;
  final String phone;
  final String fullName;
  final String? email;
  final String? role;
  final String? status;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: asInt(json['id']),
        phone: asString(json['phone']),
        fullName: asString(json['full_name']),
        email: asStringOrNull(json['email']),
        role: asStringOrNull(json['role']),
        status: asStringOrNull(json['status']),
        createdAt: asDateTime(json['created_at']),
        raw: json,
      );

  bool get isSeller => role == 'SEL';
}
