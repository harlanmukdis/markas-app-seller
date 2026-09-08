import '../../../utils/json_parse.dart';

/// `GET /fleet-types`.
///
/// Until v2.4 this carried only [capacityKgDesc], a display string like
/// "± 5 ton" or "< 20 kg" that cannot be compared against anything. v2.4 added
/// the real numbers, so the app can now check a load before submitting it —
/// which is the point of the rule: protecting the store from an overloaded
/// vehicle it would be liable for.
///
/// These values are still DRAFT on the backend, so read them, never hardcode.
class FleetType {
  const FleetType({
    required this.code,
    required this.name,
    this.maxPayloadKg,
    this.sizeRank,
    this.capacityKgDesc,
  });

  final String code;
  final String name;

  /// Hard limit the server enforces on `POST /shipments` (OPS-01).
  final double? maxPayloadKg;

  /// 1 (MOTOR) to 6 (TRONTON). Compared against an address's declared access
  /// type to block a vehicle that cannot physically reach the site (FLD-02).
  final int? sizeRank;

  /// Prose, for display only — never parse a weight out of it.
  final String? capacityKgDesc;

  factory FleetType.fromJson(Map<String, dynamic> json) => FleetType(
        code: asString(json['code'] ?? json['fleet_type_code']),
        name: asString(json['name'], fallback: asString(json['code'])),
        maxPayloadKg: asDoubleOrNull(json['max_payload_kg']),
        sizeRank: asIntOrNull(json['size_rank']),
        capacityKgDesc: asStringOrNull(json['capacity_kg_desc']),
      );

  /// Label for a picker: name plus the real limit when the backend supplies it.
  String get pickerLabel {
    final payload = maxPayloadKg;
    if (payload == null) {
      return capacityKgDesc == null ? name : '$name ($capacityKgDesc)';
    }
    return '$name (maks ${_formatKg(payload)})';
  }

  bool canCarry(double totalWeightKg) {
    final payload = maxPayloadKg;
    return payload == null || totalWeightKg <= payload;
  }

  double? remainingCapacity(double totalWeightKg) {
    final payload = maxPayloadKg;
    return payload == null ? null : payload - totalWeightKg;
  }

  static String _formatKg(double kg) {
    if (kg >= 1000) {
      final tons = kg / 1000;
      final trimmed = tons == tons.roundToDouble()
          ? tons.round().toString()
          : tons.toStringAsFixed(1).replaceAll('.', ',');
      return '$trimmed ton';
    }
    return '${kg.round()} kg';
  }
}

/// How much vehicle an address can physically take (FLD-02).
///
/// The column exists and the backend enforces it, but no address endpoint
/// accepts it yet, so in practice it is always null — meaning no restriction.
/// Handled here so the error does not need new code when that lands.
abstract class AddressAccessType {
  static const String gangSempit = 'GANG_SEMPIT_LT_2M';
  static const String pickupOnly = 'PICKUP_ONLY';
  static const String cddOk = 'CDD_OK';

  /// Largest [FleetType.sizeRank] an address of this type admits.
  static int? maxSizeRank(String? accessType) => switch (accessType) {
        gangSempit => 1,
        pickupOnly => 2,
        cddOk => 4,
        _ => null,
      };

  static String label(String? accessType) => switch (accessType) {
        gangSempit => 'Gang sempit (< 2 m) — hanya motor',
        pickupOnly => 'Hanya pickup',
        cddOk => 'Sampai CDD',
        _ => 'Tanpa batasan',
      };
}
