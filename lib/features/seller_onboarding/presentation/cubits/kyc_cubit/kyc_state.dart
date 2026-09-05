part of 'kyc_cubit.dart';

/// A single state, because there is nothing to load.
///
/// The API has no endpoint that lists KYC documents back (API doc 5.2 names
/// none), so [submittedDocTypes] is a client-side record of what this device
/// has sent — not a statement about what an admin approved.
final class KycState {
  const KycState({
    this.submittedDocTypes = const <String>[],
    this.isBusy = false,
  });

  final List<String> submittedDocTypes;
  final bool isBusy;

  bool isSubmitted(String docType) => submittedDocTypes.contains(docType);

  KycState copyWith({List<String>? submittedDocTypes, bool? isBusy}) => KycState(
        submittedDocTypes: submittedDocTypes ?? this.submittedDocTypes,
        isBusy: isBusy ?? this.isBusy,
      );
}
