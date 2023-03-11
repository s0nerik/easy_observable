import 'dart:async';

final _observableChanges = StreamController<Observable>.broadcast(sync: true);

abstract class Observable<T> {
  static ObservableMutableValue<T> mutable<T>(T value) =>
      ObservableMutableValue._(value);
  static ObservableComputedValue<T> computed<T>(T Function() compute) =>
      ObservableComputedValue._(compute);

  T get value;
  Stream<T> get stream;
}

class ObservableMutableValue<T> implements Observable<T> {
  ObservableMutableValue._(this._value);

  T _value;
  @override
  T get value {
    ObservableComputedValue.current?._dependencies.add(this);
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

class ObservableComputedValue<T> implements Observable<T> {
  static const zoneKey = 'ObservableComputedValue';
  static ObservableComputedValue? get current =>
      Zone.current[ObservableComputedValue.zoneKey];

  ObservableComputedValue._(this._compute) {
    _computeAndUpdateDependencies();
  }

  final T Function() _compute;

  @override
  T get value {
    ObservableComputedValue.current?._addDependency(this);
    return _computeAndUpdateDependencies();
  }

  @override
  Stream<T> get stream => _observableChanges.stream
      .where((observable) => _dependencies.contains(observable))
      .map((_) => _computeAndUpdateDependencies());

  final _dependencies = <Observable>{};
  void _addDependency(Observable observable) {
    _dependencies.add(observable);
    if (observable is ObservableComputedValue) {
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
      ObservableComputedValue.zoneKey: this,
    });
  }

  @override
  String toString() => 'Observable.computed';
}
