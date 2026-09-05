import '../../../utils/json_parse.dart';

/// `GET /zones` — a hierarchy of PROVINCE > CITY > ZONE.
class Zone {
  const Zone({
    required this.id,
    required this.name,
    this.level,
    this.parentId,
  });

  final int id;
  final String name;
  final String? level;
  final int? parentId;

  factory Zone.fromJson(Map<String, dynamic> json) => Zone(
        id: asInt(json['id'] ?? json['zone_id']),
        name: asString(json['name']),
        level: asStringOrNull(json['level'] ?? json['type']),
        parentId: asIntOrNull(json['parent_id']),
      );

  /// Only leaf zones are valid targets for a tariff row.
  bool get isLeafZone => level == 'ZONE';
}
