import '../observable/observable.dart';
import 'mutation_extension.dart';

extension ObservableMutableSetExtension<E> on MutableObservable<Set<E>> {
  void add(E value) => mutate(() => this.value.add(value));
  void addAll(Iterable<E> elements) => mutate(() => value.addAll(elements));

  bool remove(Object? value) => mutate(() => this.value.remove(value));
  void removeAll(Iterable<Object?> elements) =>
      mutate(() => value.removeAll(elements));
  void removeWhere(bool Function(E element) test) =>
      mutate(() => value.removeWhere(test));
  void retainAll(Iterable<Object?> elements) =>
      mutate(() => value.retainAll(elements));
  void retainWhere(bool Function(E element) test) =>
      mutate(() => value.retainWhere(test));

  void clear() => mutate(() => value.clear());
}
