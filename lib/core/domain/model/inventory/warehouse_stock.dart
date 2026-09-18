import '../../../utils/json_parse.dart';

/// One row of `GET /warehouses/{id}/stocks`.
///
/// The endpoint already joins what a stock screen needs — SKU, product name and
/// the variant's options — so listing stock costs one request rather than one
/// per row.
class WarehouseStock {
  const WarehouseStock({
    required this.id,
    required this.productVariantId,
    this.warehouseId,
    this.quantityOnHand = 0,
    this.quantityReserved = 0,
    this.quantityAvailable = 0,
    this.reorderPoint = 0,
    this.sku,
    this.productName,
    this.options = const <String, dynamic>{},
    this.updatedAt,
  });

  final int id;
  final int productVariantId;
  final int? warehouseId;

  /// What is physically there.
  final int quantityOnHand;

  /// Held by checkout sessions that have not expired. `stock-out` refuses to
  /// cut into this, which is why a rejection can look wrong to a seller who is
  /// reading [quantityOnHand].
  final int quantityReserved;

  /// `on_hand - reserved`, computed by the server.
  final int quantityAvailable;

  final int reorderPoint;
  final String? sku;
  final String? productName;

  /// Joined from the variant, and a **JSON string** on the wire like everywhere
  /// else this column appears.
  final Map<String, dynamic> options;

  final DateTime? updatedAt;

  factory WarehouseStock.fromJson(Map<String, dynamic> json) => WarehouseStock(
        id: asInt(json['id']),
        productVariantId: asInt(json['product_variant_id']),
        warehouseId: asIntOrNull(json['warehouse_id']),
        quantityOnHand: asInt(json['quantity_on_hand']),
        quantityReserved: asInt(json['quantity_reserved']),
        quantityAvailable: asInt(json['quantity_available']),
        reorderPoint: asInt(json['reorder_point']),
        sku: asStringOrNull(json['sku']),
        productName: asStringOrNull(json['product_name']),
        options: asEncodedMap(json['variant_options']),
        updatedAt: asModifiedDate(json),
      );

  /// `{color: red, size: L}` -> `red · L`; empty for a product's generated
  /// default variant, which carries no options.
  String get optionsLabel => options.values.map((value) => '$value').join(' · ');

  /// Worth flagging in the list. `reorderPoint` is 0 until someone sets it, and
  /// a zero threshold should not make every row look urgent.
  bool get isLow => reorderPoint > 0 && quantityAvailable <= reorderPoint;

  bool get isOutOfStock => quantityAvailable <= 0;
}
