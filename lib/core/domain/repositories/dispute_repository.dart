import '../../data_state.dart';
import '../model/dispute/dispute.dart';

abstract class DisputeRepository {
  Future<DataState<List<Dispute>>> getDisputes();

  Future<DataState<Dispute>> getDisputeDetail(int disputeId);

  /// Append-only; there is no delete counterpart by design (DSP-02).
  Future<DataState<bool>> addEvidence(
    int disputeId, {
    required String evidenceType,
    String? fileUrl,
    String? textContent,
  });
}
