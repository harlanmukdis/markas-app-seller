import '../../../utils/json_parse.dart';

/// `GET /fleet-types` — MOTOR, PICKUP, CDE, CDD, FUSO, TRONTON.
class FleetType {
  const FleetType({
    required this.code,
    required this.name,
    this.capacityDescription,
  });

  final String code;
  final String name;

  /// The server sends capacity as prose, not a number: `"± 5 ton"`,
  /// `"< 20 kg"` (field `capacity_kg_desc`). It is display-only — never parse
  /// it into a weight limit, because "± 5 ton" is an approximation and the
  /// real limit lives in the handling rules.
  final String? capacityDescription;

  factory FleetType.fromJson(Map<String, dynamic> json) => FleetType(
        code: asString(json['code'] ?? json['fleet_type_code']),
        name: asString(json['name'], fallback: asString(json['code'])),
        capacityDescription: asStringOrNull(
          json['capacity_kg_desc'] ?? json['capacity_kg'] ?? json['capacity'],
        ),
      );

  String get displayLabel =>
      capacityDescription == null ? name : '$name ($capacityDescription)';
}
