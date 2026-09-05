import '../../../config/network/api_exception.dart';
import '../../data_state.dart';

/// Turns a throwing service call into a [DataState].
///
/// Every repository method funnels through this so the "repositories never
/// throw" rule holds by construction instead of by remembering to write the
/// same try/catch each time.
mixin RepositoryGuard {
  Future<DataState<T>> guard<T>(Future<T> Function() call) async {
    try {
      final result = await call();

      // An empty collection is a distinct outcome from a populated one — the
      // UI shows an empty state, not a spinner or an error.
      if (result is Iterable && result.isEmpty) return DataEmpty<T>();

      return DataSuccess<T>(result);
    } on ApiException catch (error) {
      return DataFailed<T>(error.toDataError());
    } catch (error) {
      // Almost always a bug in a fromJson rather than a transport failure.
      return DataFailed<T>(DataError.unexpected(error));
    }
  }
}
