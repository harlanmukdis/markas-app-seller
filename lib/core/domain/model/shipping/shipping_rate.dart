import '../../../utils/json_parse.dart';

/// One row of the store's shipping tariff, keyed by (zone, fleet type).
///
/// The platform fixes the *shape* of this form; the store fills in the numbers
/// (API doc 5.3). Creating the first row opens gate 3.
class ShippingRate {
  const ShippingRate({
    required this.id,
    required this.zoneId,
    required this.fleetTypeCode,
    required this.baseRate,
    this.sellerId,
    this.mode,
    this.kuliBongkarFee = 0,
    this.lantaiAtasFee = 0,
    this.aksesSulitFee = 0,
    this.zoneName,
  });

  final int id;
  final int zoneId;
  final String fleetTypeCode;
  final int baseRate;
  final int? sellerId;
  final String? mode;

  /// Surcharges. Every one of these must be declared here *before* the buyer
  /// pays — charging an undeclared fee on site is prohibited and lands on the
  /// store plus a score penalty (SHP-05, API doc 5.3).
  final int kuliBongkarFee;
  final int lantaiAtasFee;
  final int aksesSulitFee;

  final String? zoneName;

  factory ShippingRate.fromJson(Map<String, dynamic> json) => ShippingRate(
        id: asInt(json['id'] ?? json['shipping_rate_id']),
        zoneId: asInt(json['zone_id']),
        fleetTypeCode: asString(json['fleet_type_code']),
        baseRate: asInt(json['base_rate']),
        sellerId: asIntOrNull(json['seller_id']),
        mode: asStringOrNull(json['mode']),
        kuliBongkarFee: asInt(json['kuli_bongkar_fee']),
        lantaiAtasFee: asInt(json['lantai_atas_fee']),
        aksesSulitFee: asInt(json['akses_sulit_fee']),
        zoneName: asStringOrNull(json['zone_name']),
      );

  int get totalSurcharge => kuliBongkarFee + lantaiAtasFee + aksesSulitFee;
}
