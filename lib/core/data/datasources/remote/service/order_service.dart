import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/order/order.dart';
import 'base_service.dart';

/// The store's orders, and the actions that move them along.
///
/// Two things shape everything here.
///
/// **Transitions are strict and their failure is unreadable.** `accept`, `pack`
/// and `ship` each demand an exact starting status, and the backend throws an
/// uncaught exception when that is not met — which reaches the app as **HTTP
/// 200 carrying an HTML error page**, not a 422. So the caller must check
/// [Order.canAccept] and friends *before* calling; these methods cannot
/// recover from being invoked at the wrong moment, only report the mess.
///
/// **Nothing here returns the updated order**, so every action re-reads it.
class OrderService extends BaseService {
  const OrderService(super.dio);

  /// One page of the store's orders, newest first. Capped at 20 with no `meta`,
  /// like every other list on this backend — a short page is the end.
  ///
  /// [status] filters server-side on an exact value; there is no "needs
  /// attention" filter, so a queue view has to ask for each status it wants.
  Future<List<Order>> getStoreOrders(
    int storeId, {
    String? status,
    int page = 1,
  }) async {
    final envelope = await getRequest(
      ApiEndpoints.storeOrders(storeId),
      query: <String, dynamic>{'status': status, 'page': page},
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return envelope.list.map(Order.fromJson).toList(growable: false);
  }

  /// The full order: items, status history, and the latest refund request —
  /// the only place the refund id needed by approve/reject can be found.
  Future<Order> getOrder(int orderId) async {
    final envelope = await getRequest(ApiEndpoints.order(orderId));
    return Order.fromJson(envelope.map);
  }

  /// `paid` -> `processed`.
  Future<Order> accept(int orderId) async {
    await postRequest(ApiEndpoints.orderAccept(orderId));
    return getOrder(orderId);
  }

  /// `processed` -> `packed`.
  Future<Order> pack(int orderId) async {
    await postRequest(ApiEndpoints.orderPack(orderId));
    return getOrder(orderId);
  }

  /// `packed` -> `shipped`, recording the courier and the airway bill.
  ///
  /// Sent **form-encoded**: this endpoint reads its fields with the REST
  /// library's `post()`, which only ever looks at `$_POST` — a JSON body is
  /// parsed by nobody and the AWB would be stored as null while the order
  /// still moved to `shipped`, which is worse than an outright failure.
  ///
  /// The service type is not ours to choose; the server records `reguler`.
  Future<Order> ship(
    int orderId, {
    required String courierCode,
    required String awbNumber,
  }) async {
    await postFormRequest(
      ApiEndpoints.orderShip(orderId),
      fields: <String, String>{
        'courier_code': courierCode,
        'awb_number': awbNumber,
      },
    );
    return getOrder(orderId);
  }

  /// Only from `pending` or `paid` — once accepted, an order cannot be
  /// cancelled this way. A paid order refunds the buyer's wallet automatically.
  ///
  /// Form-encoded for the same reason as [ship]: `reason` is read with `post()`
  /// and would otherwise be lost, leaving a cancellation with no explanation in
  /// the status history.
  Future<Order> cancel(int orderId, {required String reason}) async {
    await postFormRequest(
      ApiEndpoints.orderCancel(orderId),
      fields: <String, String>{'reason': reason},
    );
    return getOrder(orderId);
  }

  /// Null until the order ships.
  Future<OrderShipment?> getTracking(int orderId) async {
    final envelope = await getRequest(ApiEndpoints.orderTracking(orderId));
    if (envelope.isNull) return null;
    return OrderShipment.fromJson(envelope.map);
  }

  /// Approving credits the buyer's wallet and moves the order to
  /// `refund_approved`.
  Future<Order> approveRefund(int orderId, int refundId) async {
    await postRequest(ApiEndpoints.refundApprove(orderId, refundId));
    return getOrder(orderId);
  }

  Future<Order> rejectRefund(int orderId, int refundId) async {
    await postRequest(ApiEndpoints.refundReject(orderId, refundId));
    return getOrder(orderId);
  }
}
