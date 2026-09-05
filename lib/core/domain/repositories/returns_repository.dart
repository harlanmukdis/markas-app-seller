import '../../data_state.dart';
import '../model/returns/return_model.dart';

abstract class ReturnsRepository {
  Future<DataState<List<ReturnModel>>> getReturns({int limit, int offset});

  Future<DataState<ReturnModel>> getReturnDetail(int returnId);

  /// Silence for 2×24h counts as acceptance (RET-04).
  Future<DataState<bool>> respond(
    int returnId, {
    required String decision,
    String? note,
    String? refundRoute,
    String? fault,
  });

  /// Silence for 2×24h counts as SESUAI (RET-15). BEDA_KONDISI opens a dispute.
  Future<DataState<InspectOutcome>> inspect(
    int returnId, {
    required String result,
    String? fault,
    String? note,
  });
}
