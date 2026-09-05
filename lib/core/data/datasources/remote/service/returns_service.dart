import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/returns/return_model.dart';
import 'base_service.dart';

class ReturnsService extends BaseService {
  const ReturnsService(super.dio);

  Future<List<ReturnModel>> getReturns({
    int limit = 50,
    int offset = 0,
  }) async {
    final envelope = await getRequest(
      ApiEndpoints.returns,
      query: <String, dynamic>{'limit': limit, 'offset': offset},
    );
    return envelope
        .listAt('returns')
        .map(ReturnModel.fromJson)
        .toList(growable: false);
  }

  /// Note the `/detail` suffix — plain `GET /returns/{id}` does not exist and
  /// answers "Endpoint not found" (API doc 1.6).
  Future<ReturnModel> getReturnDetail(int returnId) async {
    final envelope = await getRequest(ApiEndpoints.returnDetail(returnId));
    return ReturnModel.fromJson(envelope.map);
  }

  /// Must be answered within 2×24h of delivery: **silence means acceptance**
  /// (RET-04). Past the deadline this answers `409 ALREADY_AUTO_APPROVED`.
  ///
  /// Leaving [refundRoute] null lets the server choose, which is usually right:
  /// when return shipping costs more than the goods it picks
  /// REFUND_TANPA_KEMBALI (RET-07).
  Future<void> respond(
    int returnId, {
    required String decision,
    String? note,
    String? refundRoute,
    String? fault,
  }) async {
    await postRequest(
      ApiEndpoints.returnRespond(returnId),
      body: <String, dynamic>{
        'decision': decision,
        'note': note,
        'refund_route': refundRoute,
        'fault': fault,
      },
    );
  }

  /// Silence for 2×24h counts as SESUAI and the refund proceeds (RET-15).
  /// A BEDA_KONDISI result opens a dispute and the response carries its id.
  Future<InspectOutcome> inspect(
    int returnId, {
    required String result,
    String? fault,
    String? note,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.returnInspect(returnId),
      body: <String, dynamic>{
        'result': result,
        'fault': fault,
        'note': note,
      },
    );
    return InspectOutcome.fromJson(envelope.map);
  }
}
