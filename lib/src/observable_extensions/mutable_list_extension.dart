import 'dart:math';

import '../observable.dart';
import 'mutation_extension.dart';

extension ObservableMutableListExtension<E> on MutableObservable<List<E>> {
  void operator []=(int index, E newValue) =>
      mutate(() => value[index] = newValue);

  void add(E element) => mutate(() => value.add(element));
  void addAll(Iterable<E> iterable) => mutate(() => value.addAll(iterable));
  void clear() => mutate(() => value.clear());
  void fillRange(int start, int end, [E? fillValue]) =>
      mutate(() => value.fillRange(start, end, fillValue));
  void insert(int index, E element) =>
      mutate(() => value.insert(index, element));
  void insertAll(int index, Iterable<E> iterable) =>
      mutate(() => value.insertAll(index, iterable));
  bool remove(Object? value) => mutate(() => this.value.remove(value));
  E removeAt(int index) => mutate(() => value.removeAt(index));
  E removeLast() => mutate(() => value.removeLast());
  void removeRange(int start, int end) =>
      mutate(() => value.removeRange(start, end));
  void removeWhere(bool Function(E element) test) =>
      mutate(() => value.removeWhere(test));
  void replaceRange(int start, int end, Iterable<E> newContents) =>
      mutate(() => value.replaceRange(start, end, newContents));
  void retainWhere(bool Function(E element) test) =>
      mutate(() => value.retainWhere(test));
  void setAll(int index, Iterable<E> iterable) =>
      mutate(() => value.setAll(index, iterable));
  void setRange(int start, int end, Iterable<E> iterable,
          [int skipCount = 0]) =>
      mutate(() => value.setRange(start, end, iterable, skipCount));
  void shuffle([Random? random]) => mutate(() => value.shuffle(random));
  void sort([int Function(E a, E b)? compare]) =>
      mutate(() => value.sort(compare));
}
