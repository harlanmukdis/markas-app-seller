import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/store/store.dart';
import '../../../../domain/model/store/store_settings.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

/// The stores the logged-in account owns, and their settings.
class StoreService extends BaseService {
  const StoreService(super.dio);

  /// The owner's own list. This is the **only** way an owner sees a store that
  /// is not yet active: `GET /stores/{id}` is the public profile and answers
  /// `STORE_NOT_FOUND` for an inactive store even to the person who owns it.
  Future<List<Store>> getMyStores() async {
    final envelope = await getRequest(ApiEndpoints.stores);
    return envelope.list.map(Store.fromJson).toList(growable: false);
  }

  /// Answers `{ "id": N }` rather than the created row, so the caller folds
  /// the submitted values back in instead of parsing a stub.
  Future<int> createStore({
    required String name,
    String? description,
    String type = StoreType.physical,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.stores,
      body: <String, dynamic>{
        'name': name,
        'description': description,
        'type': type,
      },
    );
    return asInt(envelope.map['id']);
  }

  Future<Store> getStore(int storeId) async {
    final envelope = await getRequest(ApiEndpoints.store(storeId));
    return Store.fromJson(envelope.map);
  }

  Future<Store> updateStore(
    int storeId, {
    String? name,
    String? description,
    String? logoUrl,
    String? bannerUrl,
  }) async {
    final envelope = await patchRequest(
      ApiEndpoints.store(storeId),
      body: <String, dynamic>{
        'name': name,
        'description': description,
        'logo_url': logoUrl,
        'banner_url': bannerUrl,
      },
    );
    return Store.fromJson(envelope.map);
  }

  Future<StoreSettings> getSettings(int storeId) async {
    final envelope = await getRequest(ApiEndpoints.storeSettings(storeId));
    return StoreSettings.fromJson(envelope.map);
  }

  Future<StoreSettings> updateSettings(
    int storeId, {
    bool? autoAcceptOrder,
    bool? vacationMode,
    String? vacationMessage,
  }) async {
    final envelope = await patchRequest(
      ApiEndpoints.storeSettings(storeId),
      body: <String, dynamic>{
        'auto_accept_order': autoAcceptOrder == null
            ? null
            : (autoAcceptOrder ? 1 : 0),
        'vacation_mode': vacationMode == null ? null : (vacationMode ? 1 : 0),
        'vacation_message': vacationMessage,
      },
    );
    return StoreSettings.fromJson(envelope.map);
  }
}
