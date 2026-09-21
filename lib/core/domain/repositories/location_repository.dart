import '../../data_state.dart';
import '../model/location/master_location.dart';

/// Province/city master data, shared by anything that needs to name a place.
abstract class LocationRepository {
  Future<DataState<List<MasterProvince>>> getProvinces();

  Future<DataState<List<MasterCity>>> getCities({int? provinceId});
}
