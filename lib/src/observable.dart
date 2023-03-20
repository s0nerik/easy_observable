import 'dart:async';

import 'package:weak_map/weak_map.dart';

final _observableDependants = WeakMap<Observable, Set<_ComputedObservable>>();

abstract class Observable<T> {
  static MutableObservable<T> mutable<T>(T value) => MutableObservable._(value);
  static Observable<T> computed<T>(T Function() compute) =>
      _ComputedObservable(compute);

  T get value;
  Stream<T> get stream;
}

class MutableObservable<T> implements Observable<T> {
  MutableObservable._(this._value) {
    _observableDependants[this] = {};
    _dependants = _observableDependants[this]!;
  }

  late final Set<_ComputedObservable> _dependants;

  final _changes = StreamController<void>.broadcast(sync: true);

  T _value;
  @override
  T get value {
    _ComputedObservable.current?.addDependency(this);
    return _value;
  }

  set value(T newValue) {
    _value = newValue;
    _changes.add(null);
    for (final dependant in _dependants) {
      dependant.recompute();
    }
  }

  @override
  Stream<T> get stream => _changes.stream.map((_) => _value);

  @override
  String toString() => 'Observable.mutable($value)';
}

class _ComputedObservable<T> implements Observable<T> {
  static const zoneKey = 'ComputedObservable';
  static _ComputedObservable? get current =>
      Zone.current[_ComputedObservable.zoneKey];

  _ComputedObservable(this._compute) {
    recompute();
  }

  final T Function() _compute;

  final _changes = StreamController<void>.broadcast(sync: true);

  late T _value;

  @override
  T get value {
    final computedScope = _ComputedObservable.current;
    if (computedScope != null) {
      for (final dependency in _dependencies) {
        computedScope.addDependency(dependency);
      }
    }
    return _value;
  }

  @override
  Stream<T> get stream => _changes.stream.map((_) => _value);

  final _dependencies = <Observable>{};
  void addDependency(Observable observable) {
    _dependencies.add(observable);
    if (observable is MutableObservable) {
      observable._dependants.add(this);
    }
  }

  void recompute() {
    runZoned(_doRecompute, zoneValues: {
      _ComputedObservable.zoneKey: this,
    });
  }

  void _doRecompute() {
    _dependencies.clear();
    _value = _compute();
    _changes.add(null);
  }

  @override
  String toString() => 'Observable.computed(${identityHashCode(this)})';
}
