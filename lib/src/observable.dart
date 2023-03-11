import 'dart:async';

final _observableChanges = StreamController<Observable>.broadcast(sync: true);

abstract class Observable<T> {
  static MutableObservable<T> mutable<T>(T value) => MutableObservable._(value);
  static Observable<T> computed<T>(T Function() compute) =>
      ComputedObservable._(compute);

  T get value;
  Stream<T> get stream;
}

class MutableObservable<T> implements Observable<T> {
  MutableObservable._(this._value);

  T _value;
  @override
  T get value {
    ComputedObservable.current?._dependencies.add(this);
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

class ComputedObservable<T> implements Observable<T> {
  static const zoneKey = 'ComputedObservable';
  static ComputedObservable? get current =>
      Zone.current[ComputedObservable.zoneKey];

  ComputedObservable._(this._compute) {
    _computeAndUpdateDependencies();
  }

  final T Function() _compute;

  @override
  T get value {
    ComputedObservable.current?._addDependency(this);
    return _computeAndUpdateDependencies();
  }

  @override
  Stream<T> get stream => _observableChanges.stream
      .where((observable) => _dependencies.contains(observable))
      .map((_) => _computeAndUpdateDependencies());

  final _dependencies = <Observable>{};
  void _addDependency(Observable observable) {
    _dependencies.add(observable);
    if (observable is ComputedObservable) {
      for (final dependency in observable._dependencies) {
        _addDependency(dependency);
      }
    }
  }

  T _computeAndUpdateDependencies() {
    return runZoned(() {
      _dependencies.clear();
      return _compute();
    }, zoneValues: {
      ComputedObservable.zoneKey: this,
    });
  }

  @override
  String toString() => 'Observable.computed';
}
