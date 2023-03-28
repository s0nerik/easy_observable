import 'dart:math';

import 'package:easy_observable/easy_observable.dart';

extension _MutationExtension<T> on MutableObservable<T> {
  TResult mutate<TResult>(TResult Function() applyMutation) {
    final result = applyMutation();
    value = value;
    return result;
  }
}

extension ObservableIterableExtension<E> on Observable<Iterable<E>> {
  Iterator<E> get iterator => value.iterator;
  int get length => value.length;
  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;

  bool any(bool Function(E element) test) => value.any(test);
  Iterable<T> cast<T>() => value.cast<T>();
  bool contains(Object? element) => value.contains(element);
  E elementAt(int index) => value.elementAt(index);
  bool every(bool Function(E element) test) => value.every(test);
  Iterable<T> expand<T>(Iterable<T> Function(E element) f) => value.expand(f);
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) =>
      value.firstWhere(test, orElse: orElse);
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) =>
      value.fold(initialValue, combine);
  Iterable<E> followedBy(Iterable<E> other) => value.followedBy(other);
  void forEach(void Function(E element) f) => value.forEach(f);
  Iterable<E> where(bool Function(E element) test) => value.where(test);
  String join([String separator = '']) => value.join(separator);
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) =>
      value.lastWhere(test, orElse: orElse);
  Iterable<T> map<T>(T Function(E e) f) => value.map(f);
  E reduce(E Function(E value, E element) combine) => value.reduce(combine);
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) =>
      value.singleWhere(test, orElse: orElse);
  Iterable<E> skip(int count) => value.skip(count);
  Iterable<E> skipWhile(bool Function(E value) test) => value.skipWhile(test);
  Iterable<E> take(int count) => value.take(count);
  Iterable<E> takeWhile(bool Function(E value) test) => value.takeWhile(test);
  List<E> toList({bool growable = true}) => value.toList(growable: growable);
  Set<E> toSet() => value.toSet();
  Iterable<T> whereType<T>() => value.whereType<T>();
}

extension ObservableListExtension<E> on Observable<List<E>> {
  Iterable<E> get reversed => value.reversed;

  E operator [](int index) => value[index];

  List<E> sublist(int start, [int? end]) => value.sublist(start, end);
  Map<int, E> asMap() => value.asMap();
}

extension ObservableMutableListExtension<E> on MutableObservable<List<E>> {
  int get length => value.length;
  set length(int newLength) => mutate(() => value.length = newLength);

  E operator [](int index) => value[index];
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

extension ObservableMapExtension<K, V> on Observable<Map<K, V>> {
  Iterable<K> get keys => value.keys;
  Iterable<V> get values => value.values;
  int get length => value.length;
  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;

  V? operator [](Object? key) => value[key];

  bool containsKey(Object? key) => value.containsKey(key);
  bool containsValue(Object? value) => this.value.containsValue(value);
  void forEach(void Function(K key, V value) f) => value.forEach(f);
}

extension ObservableMutableMapExtension<K, V> on MutableObservable<Map<K, V>> {
  V? operator [](Object? key) => value[key];
  void operator []=(K key, V value) => mutate(() => this.value[key] = value);

  void addAll(Map<K, V> other) => mutate(() => value.addAll(other));
  void clear() => mutate(() => value.clear());
  V? remove(Object? key) => mutate(() => value.remove(key));
  void removeWhere(bool Function(K key, V value) test) =>
      mutate(() => value.removeWhere(test));
}

extension ObservableSetExtension<E> on Observable<Set<E>> {
  E? lookup(Object? object) => value.lookup(object);
  bool containsAll(Iterable<Object?> other) => value.containsAll(other);

  Set<E> intersection(Set<Object?> other) => value.intersection(other);
  Set<E> union(Set<E> other) => value.union(other);
  Set<E> difference(Set<Object?> other) => value.difference(other);
}

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
