import '../observable.dart';
import 'mutation_extension.dart';

extension ObservableMutableMapExtension<K, V> on MutableObservable<Map<K, V>> {
  void operator []=(K key, V value) => mutate(() => this.value[key] = value);

  void addAll(Map<K, V> other) => mutate(() => value.addAll(other));
  void clear() => mutate(() => value.clear());
  V? remove(Object? key) => mutate(() => value.remove(key));
  void removeWhere(bool Function(K key, V value) test) =>
      mutate(() => value.removeWhere(test));
}
