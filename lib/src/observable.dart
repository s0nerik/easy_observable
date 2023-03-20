import 'dart:async';

abstract class Observable<T> {
  static MutableObservable<T> mutable<T>(T value) => MutableObservable._(value);
  static Observable<T> computed<T>(T Function() compute) =>
      _ComputedObservable(compute);

  T get value;
  Stream<T> get stream;
}

class MutableObservable<T> implements Observable<T> {
  MutableObservable._(this._value);

  final _dependants = <_ComputedObservable>{};
  final _changes = StreamController<void>.broadcast(sync: true);

  T _value;
  @override
  T get value {
    final computed = _ComputedObservable.current;
    if (computed != null) {
      _dependants.add(computed);
    }
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
  final _dependants = <_ComputedObservable>{};
  final _changes = StreamController<void>.broadcast(sync: true);

  late T _value;
  @override
  T get value {
    final computed = _ComputedObservable.current;
    if (computed != null) {
      _dependants.add(computed);
    }
    return _value;
  }

  @override
  Stream<T> get stream => _changes.stream.map((_) => _value);

  void recompute() {
    runZoned(_doRecompute, zoneValues: {
      _ComputedObservable.zoneKey: this,
    });
  }

  void _doRecompute() {
    _value = _compute();
    _changes.add(null);
    for (final dependant in _dependants) {
      dependant.recompute();
    }
  }

  @override
  String toString() => 'Observable.computed(${identityHashCode(this)})';
}
