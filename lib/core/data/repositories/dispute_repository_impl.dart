import '../../data_state.dart';
import '../../domain/model/dispute/dispute.dart';
import '../../domain/repositories/dispute_repository.dart';
import '../datasources/remote/service/dispute_service.dart';
import 'repository_guard.dart';

class DisputeRepositoryImpl with RepositoryGuard implements DisputeRepository {
  const DisputeRepositoryImpl(this._service);

  final DisputeService _service;

  @override
  Future<DataState<List<Dispute>>> getDisputes() =>
      guard(() => _service.getDisputes());

  @override
  Future<DataState<Dispute>> getDisputeDetail(int disputeId) =>
      guard(() => _service.getDisputeDetail(disputeId));

  @override
  Future<DataState<bool>> addEvidence(
    int disputeId, {
    required String evidenceType,
    String? fileUrl,
    String? textContent,
  }) =>
      guard(() async {
        await _service.addEvidence(
          disputeId,
          evidenceType: evidenceType,
          fileUrl: fileUrl,
          textContent: textContent,
        );
        return true;
      });
}
