import '../../../utils/json_parse.dart';

/// `GET /reports/seller_performance` — the store health dashboard.
///
/// Ratios come back **null** when the denominator is zero; render a dash, not
/// "NaN%". A high cancellation or dispute-loss ratio puts the store on Admin
/// Ops' review list (DSP-10), so these are shown as an early warning rather
/// than hidden.
class SellerPerformance {
  const SellerPerformance({
    this.totalSubOrders = 0,
    this.confirmedTotal = 0,
    this.confirmedOnTime = 0,
    this.slaConfirmationRate,
    this.cancelledByToko = 0,
    this.cancellationRatio,
    this.totalDisputes = 0,
    this.disputesLostBySeller = 0,
    this.disputeLossRatio,
  });

  final int totalSubOrders;
  final int confirmedTotal;
  final int confirmedOnTime;
  final double? slaConfirmationRate;
  final int cancelledByToko;
  final double? cancellationRatio;
  final int totalDisputes;
  final int disputesLostBySeller;
  final double? disputeLossRatio;

  factory SellerPerformance.fromJson(Map<String, dynamic> json) =>
      SellerPerformance(
        totalSubOrders: asInt(json['total_sub_orders']),
        confirmedTotal: asInt(json['confirmed_total']),
        confirmedOnTime: asInt(json['confirmed_on_time']),
        slaConfirmationRate: asDoubleOrNull(json['sla_confirmation_rate']),
        cancelledByToko: asInt(json['cancelled_by_toko']),
        cancellationRatio: asDoubleOrNull(json['cancellation_ratio']),
        totalDisputes: asInt(json['total_disputes']),
        disputesLostBySeller: asInt(json['disputes_lost_by_seller']),
        disputeLossRatio: asDoubleOrNull(json['dispute_loss_ratio']),
      );

  /// `0.87` and `87` both mean 87% depending on the endpoint's convention, so
  /// values ≤ 1 are treated as fractions.
  static String percentLabel(double? ratio) {
    if (ratio == null) return '-';
    final percent = ratio <= 1 ? ratio * 100 : ratio;
    return '${percent.toStringAsFixed(0)}%';
  }
}

/// One row of `GET /reports/sales`, which is grouped per day.
class SalesReportRow {
  const SalesReportRow({
    this.day,
    this.subOrderCount = 0,
    this.grossItemValue = 0,
    this.subOrderTotal = 0,
  });

  final String? day;
  final int subOrderCount;
  final int grossItemValue;
  final int subOrderTotal;

  factory SalesReportRow.fromJson(Map<String, dynamic> json) => SalesReportRow(
        day: asStringOrNull(json['day'] ?? json['date']),
        subOrderCount: asInt(json['sub_order_count']),
        grossItemValue: asInt(json['gross_item_value']),
        subOrderTotal: asInt(json['sub_order_total']),
      );
}

/// One row of `GET /reports/pph22` — the withholding recap for tax filing.
class Pph22ReportRow {
  const Pph22ReportRow({
    this.period,
    this.bruto = 0,
    this.pph22 = 0,
    this.shipmentId,
  });

  final String? period;
  final int bruto;
  final int pph22;
  final int? shipmentId;

  factory Pph22ReportRow.fromJson(Map<String, dynamic> json) => Pph22ReportRow(
        period: asStringOrNull(json['period'] ?? json['day'] ?? json['month']),
        bruto: asInt(json['bruto']),
        pph22: asInt(json['pph22']),
        shipmentId: asIntOrNull(json['shipment_id']),
      );
}

/// One row of `GET /reports/stock`.
class StockReportRow {
  const StockReportRow({
    this.offerId,
    this.warehouseId,
    this.itemName,
    this.available = 0,
    this.physical = 0,
    this.reserved = 0,
  });

  final int? offerId;
  final int? warehouseId;
  final String? itemName;
  final double available;
  final double physical;
  final double reserved;

  factory StockReportRow.fromJson(Map<String, dynamic> json) => StockReportRow(
        offerId: asIntOrNull(json['offer_id']),
        warehouseId: asIntOrNull(json['warehouse_id']),
        itemName: asStringOrNull(json['item_name'] ?? json['name']),
        available: asDouble(json['available']),
        physical: asDouble(json['physical'] ?? json['qty_physical']),
        reserved: asDouble(json['reserved'] ?? json['qty_reserved']),
      );
}
