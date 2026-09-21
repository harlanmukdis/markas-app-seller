import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/location/master_location.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

/// The province/city master data.
///
/// Public endpoints — no token required — unpaged, ordered by name, and the
/// server already filters out inactive rows.
///
/// ⚠️ **The seed is small: 11 provinces and 15 cities.** It is nowhere near
/// the ~38 provinces and hundreds of cities Indonesia actually has, and it is
/// missing ones already in use — "Jakarta Timur" is absent while "Jakarta",
/// "Jakarta Barat" and "Jakarta Selatan" are present. So this list cannot be
/// the only way to name a location: `warehouses.city_id` is nullable and the
/// free-text `city`/`province` columns were deliberately kept alongside it,
/// and any form built on this has to offer the same escape hatch.
class LocationService extends BaseService {
  const LocationService(super.dio);

  Future<List<MasterProvince>> getProvinces() async {
    final envelope = await getRequest(ApiEndpoints.locationProvinces);
    return asModelList(envelope.data, MasterProvince.fromJson);
  }

  /// All cities, or just one province's when [provinceId] is given.
  Future<List<MasterCity>> getCities({int? provinceId}) async {
    final envelope = await getRequest(
      ApiEndpoints.locationCities,
      query: <String, dynamic>{
        if (provinceId != null) 'province_id': provinceId,
      },
    );
    return asModelList(envelope.data, MasterCity.fromJson);
  }
}
