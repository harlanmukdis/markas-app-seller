import '../../../utils/json_parse.dart';

/// One order placed against the store.
///
/// A checkout that spans several sellers produces **one order per store**, all
/// sharing a `checkout_session_id`. So an order here is always this store's
/// share and never the buyer's whole basket.
class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    this.storeId,
    this.buyerId,
    this.warehouseId,
    this.status = OrderStatus.pending,
    this.subtotal = 0,
    this.shippingCost = 0,
    this.discountTotal = 0,
    this.grandTotal = 0,
    this.courierCode,
    this.courierService,
    this.trackingNumber,
    this.shippingAddress = const <String, dynamic>{},
    this.paymentDeadline,
    this.createdAt,
    this.items = const <OrderItem>[],
    this.statusHistory = const <OrderStatusEvent>[],
    this.refund,
  });

  final int id;

  /// What the buyer quotes when they get in touch — show this, not [id].
  final String orderNumber;

  final int? storeId;
  final int? buyerId;
  final int? warehouseId;
  final String status;
  final int subtotal;
  final int shippingCost;
  final int discountTotal;
  final int grandTotal;
  final String? courierCode;
  final String? courierService;

  /// The AWB. Null until the order ships.
  final String? trackingNumber;

  /// A JSON snapshot taken at checkout, not a live address — it must not move
  /// under the seller after the order was placed.
  final Map<String, dynamic> shippingAddress;

  final DateTime? paymentDeadline;
  final DateTime? createdAt;

  /// Detail payload only; the list carries no items.
  final List<OrderItem> items;
  final List<OrderStatusEvent> statusHistory;

  /// The latest refund request, when there is one. This is the **only** place
  /// the seller can learn the refund id that `approve`/`reject` need.
  final OrderRefund? refund;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: asInt(json['id']),
        orderNumber: asString(json['order_number']),
        storeId: asIntOrNull(json['store_id']),
        buyerId: asIntOrNull(json['buyer_id']),
        warehouseId: asIntOrNull(json['warehouse_id']),
        status: asString(json['status'], fallback: OrderStatus.pending),
        subtotal: asInt(json['subtotal']),
        shippingCost: asInt(json['shipping_cost']),
        discountTotal: asInt(json['discount_total']),
        grandTotal: asInt(json['grand_total']),
        courierCode: asStringOrNull(json['courier_code']),
        courierService: asStringOrNull(json['courier_service']),
        trackingNumber: asStringOrNull(json['tracking_number']),
        shippingAddress: asEncodedMap(json['shipping_address_snapshot']),
        paymentDeadline: asDateTime(json['payment_deadline']),
        createdAt: asCreatedDate(json),
        items: asModelList(json['items'], OrderItem.fromJson),
        statusHistory:
            asModelList(json['status_history'], OrderStatusEvent.fromJson),
        refund: json['refund'] == null
            ? null
            : OrderRefund.fromJson(asMap(json['refund'])),
      );

  int get itemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  String get recipientName => asString(shippingAddress['recipient_name']);

  String get shippingCity => asString(shippingAddress['city']);

  /// Whether the seller may act, and how. Deliberately decided here rather than
  /// by trying: the server answers an out-of-order transition with **HTTP 200
  /// and an HTML exception page**, so an action offered at the wrong moment
  /// fails in a way nothing can present usefully.
  bool get canAccept => status == OrderStatus.paid;
  bool get canPack => status == OrderStatus.processed;
  bool get canShip => status == OrderStatus.packed;

  /// The server refuses a cancellation once the order is being worked on.
  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.paid;

  bool get canResolveRefund =>
      status == OrderStatus.refundRequested && refund != null;

  /// Waiting on the buyer's money — nothing for the seller to do yet.
  bool get isAwaitingPayment => status == OrderStatus.pending;

  /// The seller's queue: everything that needs a hand right now.
  bool get needsAction => canAccept || canPack || canShip || canResolveRefund;
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.productName,
    this.productVariantId,
    this.options = const <String, dynamic>{},
    this.price = 0,
    this.quantity = 0,
    this.subtotal = 0,
  });

  final int id;

  /// A snapshot taken at checkout. If the product was renamed since, this still
  /// says what the buyer actually ordered — which is the point.
  final String productName;

  final int? productVariantId;
  final Map<String, dynamic> options;
  final int price;
  final int quantity;
  final int subtotal;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: asInt(json['id']),
        productName: asString(json['product_name_snapshot']),
        productVariantId: asIntOrNull(json['product_variant_id']),
        options: asEncodedMap(json['variant_options_snapshot']),
        price: asInt(json['price_snapshot']),
        quantity: asInt(json['quantity']),
        subtotal: asInt(json['subtotal']),
      );

  String get optionsLabel => options.values.map((value) => '$value').join(' · ');
}

/// One row of `order_status_history`. `fromStatus` is null for the first entry.
class OrderStatusEvent {
  const OrderStatusEvent({
    required this.id,
    required this.toStatus,
    this.fromStatus,
    this.notes,
    this.createdAt,
  });

  final int id;
  final String toStatus;
  final String? fromStatus;

  /// Carries the cancellation reason when the transition was a cancel.
  final String? notes;

  final DateTime? createdAt;

  factory OrderStatusEvent.fromJson(Map<String, dynamic> json) =>
      OrderStatusEvent(
        id: asInt(json['id']),
        toStatus: asString(json['to_status']),
        fromStatus: asStringOrNull(json['from_status']),
        notes: asStringOrNull(json['notes']),
        createdAt: asCreatedDate(json),
      );
}

class OrderRefund {
  const OrderRefund({
    required this.id,
    this.amount = 0,
    this.reason,
    this.status,
    this.createdAt,
  });

  final int id;
  final int amount;
  final String? reason;
  final String? status;
  final DateTime? createdAt;

  factory OrderRefund.fromJson(Map<String, dynamic> json) => OrderRefund(
        id: asInt(json['id']),
        amount: asInt(json['amount']),
        reason: asStringOrNull(json['reason']),
        status: asStringOrNull(json['status']),
        createdAt: asCreatedDate(json),
      );

  bool get isPending => status == 'requested' || status == 'pending';
}

/// `GET /orders/{id}/tracking` — a single `order_shipments` row, or null before
/// the order ships.
class OrderShipment {
  const OrderShipment({
    required this.id,
    this.courierCode,
    this.serviceType,
    this.awbNumber,
    this.status,
    this.shippedAt,
  });

  final int id;
  final String? courierCode;
  final String? serviceType;
  final String? awbNumber;
  final String? status;
  final DateTime? shippedAt;

  factory OrderShipment.fromJson(Map<String, dynamic> json) => OrderShipment(
        id: asInt(json['id']),
        courierCode: asStringOrNull(json['courier_code']),
        serviceType: asStringOrNull(json['service_type']),
        awbNumber: asStringOrNull(json['awb_number']),
        status: asStringOrNull(json['status']),
        shippedAt: asDateTime(json['shipped_at']),
      );
}

abstract class OrderStatus {
  static const String pending = 'pending';
  static const String paid = 'paid';
  static const String processed = 'processed';
  static const String packed = 'packed';
  static const String shipped = 'shipped';
  static const String delivered = 'delivered';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String refundRequested = 'refund_requested';
  static const String refundApproved = 'refund_approved';
  static const String refundRejected = 'refund_rejected';

  /// The order the seller actually works through. `delivered` and `completed`
  /// are the buyer's to trigger, and the refund states arrive on their own.
  static const List<String> all = <String>[
    pending,
    paid,
    processed,
    packed,
    shipped,
    delivered,
    completed,
    cancelled,
    refundRequested,
    refundApproved,
    refundRejected,
  ];

  static String label(String? status) => switch (status) {
        pending => 'Belum dibayar',
        paid => 'Perlu diproses',
        processed => 'Diproses',
        packed => 'Siap dikirim',
        shipped => 'Dikirim',
        delivered => 'Sampai tujuan',
        completed => 'Selesai',
        cancelled => 'Dibatalkan',
        refundRequested => 'Refund diajukan',
        refundApproved => 'Refund disetujui',
        refundRejected => 'Refund ditolak',
        _ => status ?? '-',
      };
}
