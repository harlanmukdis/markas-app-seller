import '../../../utils/json_parse.dart';

/// A shipping company.
///
/// Two endpoints return these and they are **not the same shape**:
/// `GET /couriers` is the platform's master list and carries `is_active`;
/// `GET /stores/{id}/couriers` returns only `code` and `name` for the ones a
/// store has enabled. Reading the latter leaves [isActive] at its default,
/// which is correct — a courier listed for a store is by definition enabled.
class Courier {
  const Courier({
    required this.code,
    required this.name,
    this.isActive = true,
  });

  /// The identifier every other endpoint uses — `jne`, `jnt`, `sicepat`. Also
  /// what `GET /products?courier=` filters on and what an order's `ship` call
  /// expects as `courier_code`.
  final String code;

  final String name;
  final bool isActive;

  factory Courier.fromJson(Map<String, dynamic> json) => Courier(
        code: asString(json['code']),
        name: asString(json['name']),
        isActive: asBool(json['is_active'], fallback: true),
      );
}
