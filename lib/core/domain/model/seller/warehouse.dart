import '../../../utils/json_parse.dart';

/// A store must have at least one warehouse.
///
/// This is *not* one of the four activation gates, but a buyer's checkout fails
/// with `409 NO_WAREHOUSE` without it — even for a fully `VERIFIED` store. The
/// app has to check for it separately (API doc 5.2).
class Warehouse {
  const Warehouse({
    required this.id,
    required this.name,
    this.addressId,
  });

  final int id;
  final String name;
  final int? addressId;

  factory Warehouse.fromJson(Map<String, dynamic> json) => Warehouse(
        id: asInt(json['id'] ?? json['warehouse_id']),
        name: asString(json['name']),
        addressId: asIntOrNull(json['address_id']),
      );
}
