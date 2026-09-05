import '../../../utils/json_parse.dart';

/// `GET /inventory/available?offer_id=`.
///
/// Available = physical − reserved. Reservations are created when a buyer
/// checks out and released when payment expires, so this number can drop with
/// no shipment in sight — that means an unpaid order is holding stock.
class StockAvailability {
  const StockAvailability({required this.offerId, required this.available});

  final int offerId;
  final double available;

  factory StockAvailability.fromJson(Map<String, dynamic> json) =>
      StockAvailability(
        offerId: asInt(json['offer_id']),
        available: asDouble(json['available']),
      );
}

/// One row of the append-only stock ledger (INV-02). Stock is never overwritten
/// — the quantity is the sum of these.
class InventoryLedgerEntry {
  const InventoryLedgerEntry({
    required this.id,
    this.offerId,
    this.warehouseId,
    this.movementType,
    this.qtyPhysicalDelta = 0,
    this.qtyReservedDelta = 0,
    this.refType,
    this.refId,
    this.note,
    this.actorType,
    this.createdAt,
  });

  final int id;
  final int? offerId;
  final int? warehouseId;
  final String? movementType;
  final double qtyPhysicalDelta;
  final double qtyReservedDelta;
  final String? refType;
  final String? refId;
  final String? note;
  final String? actorType;
  final DateTime? createdAt;

  factory InventoryLedgerEntry.fromJson(Map<String, dynamic> json) =>
      InventoryLedgerEntry(
        id: asInt(json['id']),
        offerId: asIntOrNull(json['offer_id']),
        warehouseId: asIntOrNull(json['warehouse_id']),
        movementType: asStringOrNull(json['movement_type']),
        qtyPhysicalDelta: asDouble(json['qty_physical_delta']),
        qtyReservedDelta: asDouble(json['qty_reserved_delta']),
        refType: asStringOrNull(json['ref_type']),
        refId: asStringOrNull(json['ref_id']),
        note: asStringOrNull(json['note']),
        actorType: asStringOrNull(json['actor_type']),
        createdAt: asDateTime(json['created_at']),
      );

  bool get isInbound => qtyPhysicalDelta > 0;
}

/// `POST /inventory/stock_in` and `/inventory/adjust`.
class StockMovementResult {
  const StockMovementResult({
    required this.ledgerId,
    this.available,
    this.flaggedForReview = false,
  });

  final int ledgerId;
  final double? available;

  /// Set when |qty_delta| exceeds the review threshold (default 1000). Today
  /// this is only a marker — the adjustment is recorded either way and there
  /// is no approval flow behind it (API doc 5.6).
  final bool flaggedForReview;

  factory StockMovementResult.fromJson(Map<String, dynamic> json) =>
      StockMovementResult(
        ledgerId: asInt(json['ledger_id']),
        available: asDoubleOrNull(json['available']),
        flaggedForReview: asBool(json['flagged_for_review']),
      );
}
