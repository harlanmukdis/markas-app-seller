import '../../../utils/json_parse.dart';

/// One of a store's warehouses.
///
/// Stock is held per warehouse **and** per product variant, so a store needs at
/// least one of these before anything it sells can have stock.
class Warehouse {
  const Warehouse({
    required this.id,
    required this.name,
    this.storeId,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.status = WarehouseStatus.active,
    this.createdAt,
  });

  final int id;
  final String name;
  final int? storeId;
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  /// Decided by the server, not the client: the first warehouse a store creates
  /// becomes the default and every later one does not, whatever the request
  /// asked for.
  final bool isDefault;

  final String status;
  final DateTime? createdAt;

  factory Warehouse.fromJson(Map<String, dynamic> json) => Warehouse(
        id: asInt(json['id']),
        name: asString(json['name']),
        storeId: asIntOrNull(json['store_id']),
        address: asStringOrNull(json['address']),
        city: asStringOrNull(json['city']),
        province: asStringOrNull(json['province']),
        postalCode: asStringOrNull(json['postal_code']),
        latitude: asDoubleOrNull(json['latitude']),
        longitude: asDoubleOrNull(json['longitude']),
        isDefault: asBool(json['is_default']),
        status: asString(json['status'], fallback: WarehouseStatus.active),
        createdAt: asCreatedDate(json),
      );

  bool get isActive => status == WarehouseStatus.active;

  String get shortAddress => <String?>[city, province]
      .where((part) => part != null && part.isNotEmpty)
      .join(', ');
}

abstract class WarehouseStatus {
  static const String active = 'active';
  static const String inactive = 'inactive';

  static const List<String> all = <String>[active, inactive];

  static String label(String? status) => switch (status) {
        active => 'Aktif',
        inactive => 'Nonaktif',
        _ => status ?? '-',
      };
}
