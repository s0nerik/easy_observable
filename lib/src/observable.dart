import 'dart:async';

final _observableChanges = StreamController<Observable>.broadcast(sync: true);

abstract class Observable<T> {
  static MutableObservable<T> mutable<T>(T value) => MutableObservable._(value);
  static Observable<T> computed<T>(T Function() compute) =>
      _ComputedObservable(compute);

  T get value;
  Stream<T> get stream;
}

class MutableObservable<T> implements Observable<T> {
  MutableObservable._(this._value);

  T _value;
  @override
  T get value {
    _ComputedObservable.current?.addDependency(this);
    return _value;
  }

  set value(T newValue) {
    _value = newValue;
    _observableChanges.add(this);
  }

  @override
  Stream<T> get stream => _observableChanges.stream
      .where((observable) => identical(observable, this))
      .map((observable) => observable.value);

  @override
  String toString() => 'Observable.mutable($value)';
}

class _ComputedObservable<T> implements Observable<T> {
  static const zoneKey = 'ComputedObservable';
  static _ComputedObservable? get current =>
      Zone.current[_ComputedObservable.zoneKey];

  _ComputedObservable(this._compute) {
    _computeAndUpdateDependencies();
  }

  final T Function() _compute;

  @override
  T get value {
    final computedScope = _ComputedObservable.current;
    if (computedScope != null) {
      for (final dependency in _dependencies) {
        computedScope.addDependency(dependency);
      }
    }
    return _computeAndUpdateDependencies();
  }

  @override
  Stream<T> get stream => _observableChanges.stream
      .where((observable) => _dependencies.contains(observable))
      .map((_) => _computeAndUpdateDependencies());

  final _dependencies = <Observable>{};
  void addDependency(Observable observable) {
    _dependencies.add(observable);
    if (observable is _ComputedObservable) {
      for (final dependency in observable._dependencies) {
        addDependency(dependency);
      }
    }
  }

  T _computeAndUpdateDependencies() {
    return runZoned(() {
      _dependencies.clear();
      return _compute();
    }, zoneValues: {
      _ComputedObservable.zoneKey: this,
    });
  }

  @override
  String toString() => 'Observable.computed';
}
