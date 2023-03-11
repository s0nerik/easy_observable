import 'dart:async';

final _observableChanges = StreamController<Observable>.broadcast(sync: true);

abstract class Observable<T> {
  static ObservableValue<T> mutable<T>(T value) => ObservableValue._(value);
  static ObservableComputedValue<T> computed<T>(T Function() compute) =>
      ObservableComputedValue._(compute);

  T get value;
  Stream<T> get stream;
}

class ObservableValue<T> implements Observable<T> {
  ObservableValue._(this._value);

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

  ObservableComputedValue._(this._computeCallback) {
    _computeAndUpdateDependencies();
  }

  final T Function() _computeCallback;

  @override
  T get value {
    ObservableComputedValue.current?._dependencies.add(this);
    return _computeAndUpdateDependencies();
  }

  @override
  Stream<T> get stream => _observableChanges.stream
      .where((observable) => _dependencies.contains(observable))
      .map((_) => _computeAndUpdateDependencies());

  final _dependencies = <Observable>{};

  T _computeAndUpdateDependencies() {
    return runZoned(() {
      _dependencies.clear();
      return _computeCallback();
    }, zoneValues: {
      ObservableComputedValue.zoneKey: this,
    });
  }
}
