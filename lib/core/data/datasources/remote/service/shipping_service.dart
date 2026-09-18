import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/shipping/courier.dart';
import 'base_service.dart';

/// Couriers, and which of them a store ships with.
///
/// `store_couriers` is an **optional whitelist**: the backend narrows a buyer's
/// shipping options to it only when it has rows, and offers every active
/// courier when it has none. Selecting therefore restricts rather than enables.
class ShippingService extends BaseService {
  const ShippingService(super.dio);

  /// The platform's master list — what a picker offers.
  Future<List<Courier>> getCouriers() async {
    final envelope = await getRequest(ApiEndpoints.couriers);
    return envelope.list
        .map(Courier.fromJson)
        .where((courier) => courier.isActive)
        .toList(growable: false);
  }

  /// The store's own selection. Empty is a real and common answer.
  Future<List<Courier>> getStoreCouriers(int storeId) async {
    final envelope = await getRequest(ApiEndpoints.storeCouriers(storeId));
    return envelope.list.map(Courier.fromJson).toList(growable: false);
  }

  /// **Replaces** the store's selection rather than adding to it — the server
  /// deletes every row for the store and re-inserts what is sent, so the list
  /// must always be the complete intended set. An empty list is accepted and
  /// clears everything.
  ///
  /// An unknown code fails the whole call with `VALIDATION_ERROR`; codes come
  /// from [getCouriers] rather than being typed.
  Future<List<Courier>> setStoreCouriers(
    int storeId,
    List<String> courierCodes,
  ) async {
    await patchRequest(
      ApiEndpoints.storeCouriers(storeId),
      body: <String, dynamic>{'courier_codes': courierCodes},
      headers: <String, dynamic>{'X-Store-Id': '$storeId'},
    );
    return getStoreCouriers(storeId);
  }
}
