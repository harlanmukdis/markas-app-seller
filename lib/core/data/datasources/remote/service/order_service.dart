import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/order/order_model.dart';
import 'base_service.dart';

class OrderService extends BaseService {
  const OrderService(super.dio);

  /// With a `SEL` token, only orders containing this store's sub-orders.
  /// Capped at the 50 most recent, with no pagination (API doc 8).
  Future<List<OrderModel>> getOrders() async {
    final envelope = await getRequest(ApiEndpoints.orders);
    return envelope
        .listAt('orders')
        .map(OrderModel.fromJson)
        .toList(growable: false);
  }

  Future<OrderModel> getOrder(int orderId) async {
    final envelope = await getRequest(ApiEndpoints.order(orderId));
    return OrderModel.fromJson(envelope.map);
  }

  Future<SubOrder> getSubOrder(int subOrderId) async {
    final envelope = await getRequest(ApiEndpoints.subOrder(subOrderId));
    return SubOrder.fromJson(envelope.map);
  }

  /// The store's sub-orders — what the "Pesanan Masuk" screen shows.
  ///
  /// `GET /orders` returns **plain order rows**: no nested `sub_orders[]`, no
  /// `sub_order_no`, no status or deadline for the store's own line, and no
  /// status filter. (Before the v2.2 refactor it returned a flat order×
  /// sub-order join; that is gone.) So each order has to be read individually
  /// to reach the sub-order, which is the thing a store actually confirms,
  /// rejects and ships.
  ///
  /// That is N+1 by construction and the reason to ask the backend for
  /// `GET /sub-orders?status=` — this is the store's main work queue.
  ///
  /// Reads are chunked rather than fired all at once, and one failed order
  /// does not lose the rest of the queue.
  Future<List<SubOrder>> getSubOrders({int? sellerId}) async {
    final orders = await getOrders();
    final subOrders = <SubOrder>[];

    const batchSize = 5;
    for (var i = 0; i < orders.length; i += batchSize) {
      final details = await Future.wait(
        orders.skip(i).take(batchSize).map((order) async {
          try {
            return await getOrder(order.id);
          } catch (_) {
            return null;
          }
        }),
      );

      for (final order in details) {
        if (order == null) continue;
        subOrders.addAll(
          // An order may span several stores. The backend scopes this, but
          // filtering here too means a widened response can never show one
          // store another's line.
          order.subOrders.where(
            (subOrder) => sellerId == null || subOrder.sellerId == sellerId,
          ),
        );
      }
    }

    return subOrders;
  }

  /// MENUNGGU_KONFIRMASI -> DIKONFIRMASI.
  Future<String> confirm(int subOrderId) async {
    final envelope = await postRequest(ApiEndpoints.subOrderConfirm(subOrderId));
    return envelope.map['status']?.toString() ?? '';
  }

  /// [reason] must come from [RejectReason.all] — anything else is rejected
  /// with `422 INVALID_REASON`. Costs the store 2 score points, and a confirmed
  /// sub-order holding a custom item cannot be rejected at all
  /// (`409 CUSTOM_ITEM_LOCKED`).
  Future<String> reject(int subOrderId, {required String reason}) async {
    final envelope = await postRequest(
      ApiEndpoints.subOrderReject(subOrderId),
      body: <String, dynamic>{'reason': reason},
    );
    return envelope.map['status']?.toString() ?? '';
  }

  /// DIKONFIRMASI -> BERJALAN. Must be called before a shipment can be created.
  Future<String> readyToShip(int subOrderId) async {
    final envelope =
        await postRequest(ApiEndpoints.subOrderReadyToShip(subOrderId));
    return envelope.map['status']?.toString() ?? '';
  }
}
