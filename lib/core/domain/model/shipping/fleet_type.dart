import '../../../utils/json_parse.dart';

/// `GET /fleet-types` — MOTOR, PICKUP, CDE, CDD, FUSO, TRONTON + capacity.
class FleetType {
  const FleetType({
    required this.code,
    required this.name,
    this.capacityKg,
    this.description,
  });

  final String code;
  final String name;
  final double? capacityKg;
  final String? description;

  factory FleetType.fromJson(Map<String, dynamic> json) => FleetType(
        code: asString(json['code'] ?? json['fleet_type_code']),
        name: asString(json['name'], fallback: asString(json['code'])),
        capacityKg: asDoubleOrNull(json['capacity_kg'] ?? json['capacity']),
        description: asStringOrNull(json['description']),
      );
}
