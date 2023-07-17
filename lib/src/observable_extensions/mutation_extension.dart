import '../observable/mutable_observable.dart';
import '../observable/observable.dart';
import '../observable/observed_key.dart';

extension MutationExtension<T> on MutableObservable<T> {
  TResult mutate<TResult>(
    TResult Function() applyMutation, {
    List<ObservedKey> notifyKeys = const [ObservedKey.value],
  }) {
    final result = applyMutation();
    notifyChange(notifyKeys);
    return result;
  }
}
