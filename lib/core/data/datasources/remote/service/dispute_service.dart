import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/dispute/dispute.dart';
import 'base_service.dart';

class DisputeService extends BaseService {
  const DisputeService(super.dio);

  Future<List<Dispute>> getDisputes() async {
    final envelope = await getRequest(ApiEndpoints.disputes);
    return envelope
        .listAt('disputes')
        .map(Dispute.fromJson)
        .toList(growable: false);
  }

  /// `/detail` is required here too.
  Future<Dispute> getDisputeDetail(int disputeId) async {
    final envelope = await getRequest(ApiEndpoints.disputeDetail(disputeId));
    return Dispute.fromJson(envelope.map);
  }

  /// Evidence is append-only and cannot be removed by anyone, including an
  /// admin (DSP-02). Deadline is 2×24h; after that CS decides on what exists.
  Future<void> addEvidence(
    int disputeId, {
    required String evidenceType,
    String? fileUrl,
    String? textContent,
  }) async {
    await postRequest(
      ApiEndpoints.disputeEvidence(disputeId),
      body: <String, dynamic>{
        'evidence_type': evidenceType,
        'file_url': fileUrl,
        'text_content': textContent,
      },
    );
  }
}
