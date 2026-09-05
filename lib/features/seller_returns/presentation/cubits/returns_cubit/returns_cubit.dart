import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/dispute/dispute.dart';
import '../../../../../core/domain/model/returns/return_model.dart';
import '../../../../../core/domain/repositories/dispute_repository.dart';
import '../../../../../core/domain/repositories/returns_repository.dart';
import '../../../../../di/injector.dart';

part 'returns_state.dart';

/// After-sales queue.
///
/// The two deadlines here are the most expensive in the whole app, because
/// missing them is not an error the store can retry: an unanswered return is
/// accepted automatically (RET-04) and an uninspected one is deemed as
/// described (RET-15). The screen exists mostly to make sure that never
/// happens by accident.
class ReturnsCubit extends Cubit<ReturnsState> {
  ReturnsCubit() : super(const ReturnsLoadInProgress());

  static ReturnsCubit get(BuildContext context) => BlocProvider.of(context);

  final ReturnsRepository _returnsRepository = injector<ReturnsRepository>();
  final DisputeRepository _disputeRepository = injector<DisputeRepository>();

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) emit(const ReturnsLoadInProgress());

    final results = await Future.wait(<Future<Object>>[
      _returnsRepository.getReturns(),
      _disputeRepository.getDisputes(),
    ]);

    if (isClosed) return;

    final returnResult = results[0] as DataState<List<ReturnModel>>;
    if (returnResult is DataFailed<List<ReturnModel>>) {
      emit(ReturnsLoadFailure(returnResult.failure));
      return;
    }

    emit(
      ReturnsLoadSuccess(
        returns: switch (returnResult) {
          DataSuccess<List<ReturnModel>>(:final value) => value,
          _ => const <ReturnModel>[],
        },
        disputes: switch (results[1] as DataState<List<Dispute>>) {
          DataSuccess<List<Dispute>>(:final value) => value,
          _ => const <Dispute>[],
        },
      ),
    );
  }

  /// Leaving [refundRoute] null lets the server pick, which is usually the
  /// right call: when return shipping costs more than the goods it chooses
  /// refund-without-return rather than moving a cracked sack of cement across
  /// the city (RET-07).
  Future<DataError?> respond(
    int returnId, {
    required String decision,
    String? note,
    String? refundRoute,
    String? fault,
  }) =>
      _act(
        returnId,
        () => _returnsRepository.respond(
          returnId,
          decision: decision,
          note: note,
          refundRoute: refundRoute,
          fault: fault,
        ),
      );

  /// A BEDA_KONDISI result opens a dispute; the id comes back in the response
  /// and the caller surfaces it.
  Future<(DataError?, int?)> inspect(
    int returnId, {
    required String result,
    String? fault,
    String? note,
  }) async {
    final current = state;
    if (current is ReturnsLoadSuccess) {
      emit(current.copyWith(busyReturnId: returnId));
    }

    final outcome = await _returnsRepository.inspect(
      returnId,
      result: result,
      fault: fault,
      note: note,
    );

    if (isClosed) return (null, null);

    if (outcome is DataFailed<InspectOutcome>) {
      if (current is ReturnsLoadSuccess) emit(current.copyWith(clearBusy: true));
      return (outcome.failure, null);
    }

    final disputeId = switch (outcome) {
      DataSuccess<InspectOutcome>(:final value) => value.disputeId,
      _ => null,
    };

    await load(showSpinner: false);
    return (null, disputeId);
  }

  Future<DataError?> _act(
    int returnId,
    Future<DataState<Object>> Function() action,
  ) async {
    final current = state;
    if (current is ReturnsLoadSuccess) {
      emit(current.copyWith(busyReturnId: returnId));
    }

    final result = await action();
    if (isClosed) return null;

    if (result is DataFailed<Object>) {
      if (current is ReturnsLoadSuccess) emit(current.copyWith(clearBusy: true));
      return result.failure;
    }

    await load(showSpinner: false);
    return null;
  }
}
