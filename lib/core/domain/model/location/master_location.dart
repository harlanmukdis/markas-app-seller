import '../../../utils/json_parse.dart';

/// `GET /locations/provinces` and `GET /locations/cities`, added in v1.2.0 so
/// that `warehouses.city` and `user_addresses.city` finally have a shared
/// source of truth instead of being free text.
///
/// **These two payloads do not follow the rest of the API's naming.** The name
/// is `province_name` / `city_name` rather than `name`, the flag is `active`
/// rather than `is_active`, and the timestamps are `created_date` /
/// `modified_date` rather than `created_at` / `updated_at`. Both endpoints are
/// public, unpaged, ordered by name, and already filtered to active rows.
class MasterProvince {
  const MasterProvince({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  final int id;
  final String name;
  final bool isActive;

  factory MasterProvince.fromJson(Map<String, dynamic> json) => MasterProvince(
        id: asInt(json['id']),
        name: asString(json['province_name']),
        isActive: asBool(json['active'], fallback: true),
      );
}

class MasterCity {
  const MasterCity({
    required this.id,
    required this.name,
    required this.provinceId,
    this.isActive = true,
  });

  final int id;
  final String name;
  final int provinceId;
  final bool isActive;

  factory MasterCity.fromJson(Map<String, dynamic> json) => MasterCity(
        id: asInt(json['id']),
        name: asString(json['city_name']),
        provinceId: asInt(json['province_id']),
        isActive: asBool(json['active'], fallback: true),
      );
}
