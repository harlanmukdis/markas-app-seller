import '../../../utils/json_parse.dart';
import '../shipment/shipment.dart';

/// The three-layer structure that governs this whole app (API doc 4):
///
/// ```
/// Order       — the buyer's PAYMENT unit, may span several stores
///   Sub-order — THIS STORE'S PART; the thing you confirm or reject
///     Shipment— the PHYSICAL unit: delivery note, POD, and PAYOUT
/// ```
///
/// So the "Pesanan Masuk" screen lists sub-orders, not orders, and money is
/// released per shipment, not per order.
class OrderModel {
  const OrderModel({
    required this.id,
    this.orderNo,
    this.buyerId,
    this.buyerSegmentSnapshot,
    this.status,
    this.subtotal = 0,
    this.discountTotal = 0,
    this.shippingTotal = 0,
    this.taxTotal = 0,
    this.serviceFee = 0,
    this.grandTotal = 0,
    this.paymentDeadline,
    this.rfqContractId,
    this.createdAt,
    this.subOrders = const <SubOrder>[],
  });

  final int id;
  final String? orderNo;
  final int? buyerId;
  final String? buyerSegmentSnapshot;
  final String? status;
  final int subtotal;
  final int discountTotal;
  final int shippingTotal;
  final int taxTotal;
  final int serviceFee;
  final int grandTotal;
  final DateTime? paymentDeadline;
  final int? rfqContractId;
  final DateTime? createdAt;
  final List<SubOrder> subOrders;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: asInt(json['id']),
        orderNo: asStringOrNull(json['order_no']),
        buyerId: asIntOrNull(json['buyer_id']),
        buyerSegmentSnapshot: asStringOrNull(json['buyer_segment_snapshot']),
        status: asStringOrNull(json['status']),
        subtotal: asInt(json['subtotal']),
        discountTotal: asInt(json['discount_total']),
        shippingTotal: asInt(json['shipping_total']),
        taxTotal: asInt(json['tax_total']),
        serviceFee: asInt(json['service_fee']),
        grandTotal: asInt(json['grand_total']),
        paymentDeadline: asDateTime(json['payment_deadline']),
        rfqContractId: asIntOrNull(json['rfq_contract_id']),
        createdAt: asDateTime(json['created_at']),
        subOrders: asModelList(json['sub_orders'], SubOrder.fromJson),
      );
}

class SubOrder {
  const SubOrder({
    required this.id,
    this.subOrderNo,
    this.orderId,
    this.sellerId,
    this.status,
    this.sellerConfirmDeadline,
    this.fleetHandoverWarnAt,
    this.fleetHandoverCancelAt,
    this.subtotal = 0,
    this.discountSeller = 0,
    this.discountPlatform = 0,
    this.shippingTotal = 0,
    this.taxTotal = 0,
    this.total = 0,
    this.sellerPkpStatusSnapshot,
    this.cancelReason,
    this.cancelledBy,
    this.hasCustomItem = false,
    this.createdAt,
    this.items = const <SubOrderItem>[],
    this.shipments = const <Shipment>[],
    this.idIsAmbiguous = false,
  });

  final int id;
  final String? subOrderNo;
  final int? orderId;
  final int? sellerId;
  final String? status;

  /// Deadlines are in *working hours* and skip weekends and holidays, so they
  /// must never be recomputed client-side — these server values are the truth
  /// (API doc 1.7).
  final DateTime? sellerConfirmDeadline;
  final DateTime? fleetHandoverWarnAt;
  final DateTime? fleetHandoverCancelAt;

  final int subtotal;
  final int discountSeller;
  final int discountPlatform;
  final int shippingTotal;
  final int taxTotal;
  final int total;
  final String? sellerPkpStatusSnapshot;
  final String? cancelReason;
  final String? cancelledBy;

  /// A confirmed sub-order containing a custom item cannot be rejected —
  /// `409 CUSTOM_ITEM_LOCKED` (ORD-11). Rebar already cut to length cannot be
  /// sold to anyone else.
  final bool hasCustomItem;

  final DateTime? createdAt;
  final List<SubOrderItem> items;
  final List<Shipment> shipments;

  /// True when this came from the flat `GET /orders` row, where [id] may be
  /// the parent order's id rather than this sub-order's. Resolve through
  /// [orderId] and [subOrderNo] before acting on it.
  final bool idIsAmbiguous;

  factory SubOrder.fromJson(
    Map<String, dynamic> json, {
    bool idIsAmbiguous = false,
  }) =>
      SubOrder(
        id: asInt(json['id']),
        subOrderNo: asStringOrNull(json['sub_order_no']),
        orderId: asIntOrNull(json['order_id']),
        sellerId: asIntOrNull(json['seller_id']),
        status: asStringOrNull(json['status']),
        sellerConfirmDeadline: asDateTime(json['seller_confirm_deadline']),
        fleetHandoverWarnAt: asDateTime(json['fleet_handover_warn_at']),
        fleetHandoverCancelAt: asDateTime(json['fleet_handover_cancel_at']),
        subtotal: asInt(json['subtotal']),
        discountSeller: asInt(json['discount_seller']),
        discountPlatform: asInt(json['discount_platform']),
        shippingTotal: asInt(json['shipping_total']),
        taxTotal: asInt(json['tax_total']),
        total: asInt(json['total']),
        sellerPkpStatusSnapshot:
            asStringOrNull(json['seller_pkp_status_snapshot']),
        cancelReason: asStringOrNull(json['cancel_reason']),
        cancelledBy: asStringOrNull(json['cancelled_by']),
        hasCustomItem: asBool(json['has_custom_item']),
        createdAt: asDateTime(json['created_at']),
        items: asModelList(json['items'], SubOrderItem.fromJson),
        shipments: asModelList(json['shipments'], Shipment.fromJson),
        idIsAmbiguous: idIsAmbiguous,
      );

  /// Parses a row from `GET /orders`, which for a `SEL` token is **not** an
  /// order with nested `sub_orders[]` but a flat join of order and sub-order.
  ///
  /// **`id` on that row is not trustworthy.** Order and sub-order both have an
  /// `id` column, and which one survives the join is not observable from the
  /// data: in every row on this backend `id == order_id`, because each order
  /// happens to carry exactly one sub-order. The backend's own feature map
  /// calls these "order rows"; the payload looks like `SELECT o.*, so.*`.
  /// Rather than bet on either reading, [idIsAmbiguous] is set and callers must
  /// resolve the real sub-order through the parent order before acting —
  /// confirming or rejecting the wrong row is not a recoverable mistake.
  ///
  /// [orderId] and [subOrderNo] *are* unambiguous: both exist only on the
  /// sub-order side of the join.
  ///
  /// The row also carries no `items`, so a detail read is needed to ship.
  factory SubOrder.fromFlatOrderRow(Map<String, dynamic> json) =>
      SubOrder.fromJson(json, idIsAmbiguous: true);

  bool get awaitingConfirmation =>
      status == SubOrderStatus.menungguKonfirmasi;

  bool get isConfirmed => status == SubOrderStatus.dikonfirmasi;

  bool get isRunning => status == SubOrderStatus.berjalan;

  /// Valid from MENUNGGU_KONFIRMASI or DIKONFIRMASI, except when a confirmed
  /// sub-order carries a custom item.
  bool get canReject =>
      (awaitingConfirmation || (isConfirmed && !hasCustomItem));

  /// `ready_to_ship` must be called before a shipment can be created.
  bool get canMarkReady => isConfirmed;

  bool get canCreateShipment => isRunning;

  /// The deadline that matters right now, if any.
  DateTime? get activeDeadline {
    if (awaitingConfirmation) return sellerConfirmDeadline;
    if (isConfirmed || isRunning) return fleetHandoverCancelAt;
    return null;
  }
}

class SubOrderItem {
  const SubOrderItem({
    required this.id,
    this.subOrderId,
    this.offerId,
    this.itemNameSnapshot,
    this.unitNameSnapshot,
    this.qty = 0,
    this.unitPriceSnapshot = 0,
    this.lineSubtotal = 0,
    this.weightKgSnapshot,
    this.handlingClassSnapshot,
    this.warehouseId,
  });

  final int id;
  final int? subOrderId;
  final int? offerId;
  final String? itemNameSnapshot;

  /// Always the literal string `"unit"` today (API doc 8). To show sak / dus /
  /// batang, read `units[]` from `GET /sku-master/{id}`.
  final String? unitNameSnapshot;

  final double qty;
  final int unitPriceSnapshot;
  final int lineSubtotal;
  final double? weightKgSnapshot;
  final String? handlingClassSnapshot;
  final int? warehouseId;

  factory SubOrderItem.fromJson(Map<String, dynamic> json) => SubOrderItem(
        id: asInt(json['id']),
        subOrderId: asIntOrNull(json['sub_order_id']),
        offerId: asIntOrNull(json['offer_id']),
        itemNameSnapshot: asStringOrNull(json['item_name_snapshot']),
        unitNameSnapshot: asStringOrNull(json['unit_name_snapshot']),
        qty: asDouble(json['qty']),
        unitPriceSnapshot: asInt(json['unit_price_snapshot']),
        lineSubtotal: asInt(json['line_subtotal']),
        weightKgSnapshot: asDoubleOrNull(json['weight_kg_snapshot']),
        handlingClassSnapshot:
            asStringOrNull(json['handling_class_snapshot']),
        warehouseId: asIntOrNull(json['warehouse_id']),
      );

  String get qtyLabel =>
      qty == qty.roundToDouble() ? qty.round().toString() : qty.toString();
}

abstract class SubOrderStatus {
  static const String menungguKonfirmasi = 'MENUNGGU_KONFIRMASI';
  static const String dikonfirmasi = 'DIKONFIRMASI';
  static const String berjalan = 'BERJALAN';
  static const String selesai = 'SELESAI';
  static const String batalToko = 'BATAL_TOKO';
  static const String batalBuyer = 'BATAL_BUYER';
  static const String batalSistem = 'BATAL_SISTEM';
  static const String dihentikan = 'DIHENTIKAN';

  static String label(String? status) => switch (status) {
        menungguKonfirmasi => 'Menunggu konfirmasi',
        dikonfirmasi => 'Dikonfirmasi',
        berjalan => 'Berjalan',
        selesai => 'Selesai',
        batalToko => 'Dibatalkan toko',
        batalBuyer => 'Dibatalkan pembeli',
        batalSistem => 'Dibatalkan sistem',
        dihentikan => 'Dihentikan',
        _ => status ?? '-',
      };
}

/// The closed list of rejection reasons (ORD-10). Anything else is rejected
/// with `422 INVALID_REASON`, and a free-text box would just produce those —
/// the pattern of these codes is what flags a store for review.
abstract class RejectReason {
  static const String stokHabis = 'STOK_HABIS';
  static const String hargaSalah = 'HARGA_SALAH';
  static const String tidakSanggupKirim = 'TIDAK_SANGGUP_KIRIM';
  static const String barangRusakGudang = 'BARANG_RUSAK_GUDANG';

  static const List<String> all = <String>[
    stokHabis,
    hargaSalah,
    tidakSanggupKirim,
    barangRusakGudang,
  ];

  static String label(String? reason) => switch (reason) {
        stokHabis => 'Stok habis',
        hargaSalah => 'Harga salah',
        tidakSanggupKirim => 'Tidak sanggup kirim',
        barangRusakGudang => 'Barang rusak di gudang',
        _ => reason ?? '-',
      };
}
