import '../../data_state.dart';
import '../../domain/model/rfq/rfq.dart';
import '../../domain/repositories/rfq_repository.dart';
import '../datasources/remote/service/rfq_service.dart';
import 'repository_guard.dart';

class RfqRepositoryImpl with RepositoryGuard implements RfqRepository {
  const RfqRepositoryImpl(this._service);

  final RfqService _service;

  @override
  Future<DataState<List<Rfq>>> getRfqs() => guard(() => _service.getRfqs());

  @override
  Future<DataState<Rfq>> getRfq(int rfqId) => guard(() => _service.getRfq(rfqId));

  @override
  Future<DataState<List<RfqOffer>>> getRfqOffers(int rfqId) =>
      guard(() => _service.getRfqOffers(rfqId));

  @override
  Future<DataState<RfqOffer>> submitOffer(
    int rfqId, {
    required int price,
    required double qty,
    String? validUntil,
    int? termsSkuId,
    String? termsNote,
    int? parentOfferId,
  }) =>
      guard(() => _service.submitOffer(
            rfqId,
            price: price,
            qty: qty,
            validUntil: validUntil,
            termsSkuId: termsSkuId,
            termsNote: termsNote,
            parentOfferId: parentOfferId,
          ));

  @override
  Future<DataState<bool>> requestAdjustment(int contractId) => guard(() async {
        await _service.requestAdjustment(contractId);
        return true;
      });

  @override
  Future<DataState<List<RfqBatch>>> getBatches(int contractId) =>
      guard(() => _service.getBatches(contractId));

  @override
  Future<DataState<Map<String, dynamic>>> getCancellationTerms(
    int contractId,
  ) =>
      guard(() => _service.getCancellationTerms(contractId));
}
