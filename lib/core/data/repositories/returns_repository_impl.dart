import '../../data_state.dart';
import '../../domain/model/returns/return_model.dart';
import '../../domain/repositories/returns_repository.dart';
import '../datasources/remote/service/returns_service.dart';
import 'repository_guard.dart';

class ReturnsRepositoryImpl with RepositoryGuard implements ReturnsRepository {
  const ReturnsRepositoryImpl(this._service);

  final ReturnsService _service;

  @override
  Future<DataState<List<ReturnModel>>> getReturns({
    int limit = 50,
    int offset = 0,
  }) =>
      guard(() => _service.getReturns(limit: limit, offset: offset));

  @override
  Future<DataState<ReturnModel>> getReturnDetail(int returnId) =>
      guard(() => _service.getReturnDetail(returnId));

  @override
  Future<DataState<bool>> respond(
    int returnId, {
    required String decision,
    String? note,
    String? refundRoute,
    String? fault,
  }) =>
      guard(() async {
        await _service.respond(
          returnId,
          decision: decision,
          note: note,
          refundRoute: refundRoute,
          fault: fault,
        );
        return true;
      });

  @override
  Future<DataState<InspectOutcome>> inspect(
    int returnId, {
    required String result,
    String? fault,
    String? note,
  }) =>
      guard(() => _service.inspect(
            returnId,
            result: result,
            fault: fault,
            note: note,
          ));
}
