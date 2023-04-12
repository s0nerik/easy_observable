import 'dart:async';

abstract class Observable<T> {
  static MutableObservable<T> mutable<T>(T value) => MutableObservable._(value);
  static Observable<T> computed<T>(T Function() compute) =>
      ComputedObservable(compute);

  late T _value;
  T get value {
    final computed = ComputedObservable.current;
    if (computed != null && !identical(this, computed)) {
      _dependants.add(computed);
    }
    return _value;
  }

  final _dependants = <ComputedObservable>{};
  final _changes = StreamController<T>.broadcast(sync: true);
  Stream<T> get stream => _changes.stream;

  void _notifyChange() {
    _changes.add(_value);
    final dependants = _dependants.toList();
    for (final dependant in dependants) {
      dependant.recompute();
    }
  }
}

class MutableObservable<T> extends Observable<T> {
  MutableObservable._(T value) {
    _value = value;
  }

  set value(T newValue) {
    _value = newValue;
    _notifyChange();
  }

  @override
  String toString() => 'Observable.mutable($_value)';
}

class ComputedObservable<T> extends Observable<T> {
  static const zoneKey = 'ComputedObservable';
  static ComputedObservable? get current =>
      Zone.current[ComputedObservable.zoneKey];

  ComputedObservable(this._compute) {
    recompute();
  }

  final T Function() _compute;

  void recompute() {
    runZoned(_recompute, zoneValues: {
      ComputedObservable.zoneKey: this,
    });
  }

  void _recompute() {
    _value = _compute();
    _notifyChange();
  }

  @override
  String toString() => 'Observable.computed($_value)';
}
