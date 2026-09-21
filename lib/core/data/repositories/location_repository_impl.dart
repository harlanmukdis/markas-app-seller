import '../../data_state.dart';
import '../../domain/model/location/master_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/remote/service/location_service.dart';
import 'repository_guard.dart';

class LocationRepositoryImpl with RepositoryGuard implements LocationRepository {
  const LocationRepositoryImpl(this._service);

  final LocationService _service;

  @override
  Future<DataState<List<MasterProvince>>> getProvinces() =>
      guard(() => _service.getProvinces());

  @override
  Future<DataState<List<MasterCity>>> getCities({int? provinceId}) =>
      guard(() => _service.getCities(provinceId: provinceId));
}
