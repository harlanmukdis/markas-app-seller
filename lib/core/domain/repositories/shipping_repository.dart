import '../../data_state.dart';
import '../model/shipping/courier.dart';

/// Couriers, and the store's selection among them.
abstract class ShippingRepository {
  /// The platform's active couriers.
  Future<DataState<List<Courier>>> getCouriers();

  /// What this store restricts itself to. [DataEmpty] is the normal starting
  /// state and means *no restriction* — every active courier is on offer.
  Future<DataState<List<Courier>>> getStoreCouriers(int storeId);

  /// Replaces the selection wholesale and returns it as stored.
  Future<DataState<List<Courier>>> setStoreCouriers(
    int storeId,
    List<String> courierCodes,
  );
}
