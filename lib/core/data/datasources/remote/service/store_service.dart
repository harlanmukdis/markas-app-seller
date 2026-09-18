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

  /// A store that has never had settings saved answers `data: null` rather
  /// than a row of defaults — every seeded store is in that state — so the
  /// empty envelope becomes [StoreSettings.empty] carrying the id we already
  /// know, not a parse failure or a settings object with `storeId: 0`.
  Future<StoreSettings> getSettings(int storeId) async {
    final envelope = await getRequest(ApiEndpoints.storeSettings(storeId));
    if (envelope.isNull) return StoreSettings.empty(storeId);
    return StoreSettings.fromJson(envelope.map);
  }

  /// `PATCH` answers `data: null`, so the saved row has to be read back —
  /// parsing the patch response would hand every caller a blank settings object
  /// and quietly undo what the form just showed.
  ///
  /// Only the fields the caller passes are sent: the server whitelists
  /// `auto_accept_order`, `vacation_mode`, `operational_hours`,
  /// `return_policy`, `shipping_origin`, `contact_phone` and
  /// `contact_whatsapp`, and writing a subset leaves the rest alone.
  Future<StoreSettings> updateSettings(
    int storeId, {
    bool? autoAcceptOrder,
    bool? vacationMode,
    String? contactPhone,
    String? contactWhatsapp,
    Map<String, dynamic>? operationalHours,
    Map<String, dynamic>? returnPolicy,
    Map<String, dynamic>? shippingOrigin,
  }) async {
    await patchRequest(
      ApiEndpoints.storeSettings(storeId),
      body: <String, dynamic>{
        if (autoAcceptOrder != null) 'auto_accept_order': autoAcceptOrder ? 1 : 0,
        if (vacationMode != null) 'vacation_mode': vacationMode ? 1 : 0,
        if (contactPhone != null) 'contact_phone': contactPhone,
        if (contactWhatsapp != null) 'contact_whatsapp': contactWhatsapp,
        if (operationalHours != null) 'operational_hours': operationalHours,
        if (returnPolicy != null) 'return_policy': returnPolicy,
        if (shippingOrigin != null) 'shipping_origin': shippingOrigin,
      },
    );
    return getSettings(storeId);
  }
}
