import '../../../utils/json_parse.dart';

/// One row of `GET /warehouses/{id}/movements` — the append-only stock ledger.
///
/// Nothing edits a quantity directly on this backend; every change is a row
/// here, written inside a transaction. That makes the ledger the explanation
/// for any number a seller disputes, which is why the app shows it rather than
/// just the current total.
class StockMovement {
  const StockMovement({
    required this.id,
    required this.type,
    required this.quantity,
    this.warehouseId,
    this.productVariantId,
    this.referenceType,
    this.referenceId,
    this.notes,
    this.createdBy,
    this.createdAt,
  });

  final int id;
  final String type;

  /// **Signed**: `stock_out` and outbound transfers arrive negative, so a naive
  /// `abs()` would turn a subtraction into an addition on screen.
  final int quantity;

  final int? warehouseId;
  final int? productVariantId;

  /// Set when the movement came from something else — an order, a transfer —
  /// rather than from a person pressing a button.
  final String? referenceType;
  final int? referenceId;

  final String? notes;
  final int? createdBy;
  final DateTime? createdAt;

  factory StockMovement.fromJson(Map<String, dynamic> json) => StockMovement(
        id: asInt(json['id']),
        type: asString(json['type']),
        quantity: asInt(json['quantity']),
        warehouseId: asIntOrNull(json['warehouse_id']),
        productVariantId: asIntOrNull(json['product_variant_id']),
        referenceType: asStringOrNull(json['reference_type']),
        referenceId: asIntOrNull(json['reference_id']),
        notes: asStringOrNull(json['notes']),
        createdBy: asIntOrNull(json['created_by']),
        createdAt: asCreatedDate(json),
      );

  bool get isIncoming => quantity > 0;

  /// `+50` / `-5`, which is how a ledger reads.
  String get signedQuantity => quantity > 0 ? '+$quantity' : '$quantity';
}

/// Observed on the wire: `stock_in`, `stock_out`, `adjustment`, `transfer_out`,
/// `transfer_in`. Completing an audit writes an `adjustment` for the variance
/// rather than a type of its own.
abstract class StockMovementType {
  static const String stockIn = 'stock_in';
  static const String stockOut = 'stock_out';
  static const String adjustment = 'adjustment';
  static const String transferIn = 'transfer_in';
  static const String transferOut = 'transfer_out';

  static String label(String? type) => switch (type) {
        stockIn => 'Stok masuk',
        stockOut => 'Stok keluar',
        adjustment => 'Penyesuaian',
        transferIn => 'Transfer masuk',
        transferOut => 'Transfer keluar',
        _ => type ?? '-',
      };
}
