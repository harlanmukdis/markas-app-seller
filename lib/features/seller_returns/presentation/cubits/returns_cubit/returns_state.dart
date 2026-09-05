part of 'returns_cubit.dart';

sealed class ReturnsState {
  const ReturnsState();
}

final class ReturnsLoadInProgress extends ReturnsState {
  const ReturnsLoadInProgress();
}

final class ReturnsLoadSuccess extends ReturnsState {
  const ReturnsLoadSuccess({
    required this.returns,
    this.disputes = const <Dispute>[],
    this.busyReturnId,
  });

  final List<ReturnModel> returns;

  /// Shown alongside, because a return that goes wrong becomes a dispute and
  /// the store needs to see both queues in one place.
  final List<Dispute> disputes;

  final int? busyReturnId;

  /// Returns where the clock is running against the store. Silence on either
  /// of these is a decision: unanswered means accepted, uninspected means
  /// as-described.
  List<ReturnModel> get needsAction => returns
      .where((entry) => entry.awaitingResponse || entry.awaitingInspection)
      .toList();

  /// Pickups the store must make within 3×24h or it loses both the goods and
  /// the refund.
  List<ReturnModel> get needsPickup =>
      returns.where((entry) => entry.needsPickup).toList();

  ReturnsLoadSuccess copyWith({
    List<ReturnModel>? returns,
    List<Dispute>? disputes,
    int? busyReturnId,
    bool clearBusy = false,
  }) =>
      ReturnsLoadSuccess(
        returns: returns ?? this.returns,
        disputes: disputes ?? this.disputes,
        busyReturnId: clearBusy ? null : (busyReturnId ?? this.busyReturnId),
      );
}

final class ReturnsLoadFailure extends ReturnsState {
  const ReturnsLoadFailure(this.error);

  final DataError error;
}
