import '../../data_state.dart';
import '../model/rfq/rfq.dart';

abstract class RfqRepository {
  Future<DataState<List<Rfq>>> getRfqs();

  Future<DataState<Rfq>> getRfq(int rfqId);

  Future<DataState<List<RfqOffer>>> getRfqOffers(int rfqId);

  /// Pass [parentOfferId] to revise: the old quote becomes SUPERSEDED and this
  /// one gets the next version number.
  Future<DataState<RfqOffer>> submitOffer(
    int rfqId, {
    required int price,
    required double qty,
    String? validUntil,
    int? termsSkuId,
    String? termsNote,
    int? parentOfferId,
  });

  /// Carries real risk: buyer silence cancels the remaining contract
  /// (RFQ-17), so confirm before calling.
  Future<DataState<bool>> requestAdjustment(int contractId);

  Future<DataState<List<RfqBatch>>> getBatches(int contractId);

  Future<DataState<Map<String, dynamic>>> getCancellationTerms(int contractId);
}
