import 'dart:async';

final _observableChanges = StreamController<Observable>.broadcast();

abstract class Observable<T> {
  static ObservableValue<T> mutable<T>(T value) => ObservableValue._(value);
  static ObservableComputedValue<T> computed<T>(T Function() valueGenerator) =>
      ObservableComputedValue._(valueGenerator);

  T get value;
  Stream<T> get stream;
}

class ObservableValue<T> implements Observable<T> {
  ObservableValue._(this._value);

  T _value;
  @override
  T get value {
    ObservableComputedValue.current?.addDependency(this);
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
}

class ObservableComputedValue<T> implements Observable<T> {
  static const zoneKey = 'ObservableComputedValue';
  static ObservableComputedValue? get current =>
      Zone.current[ObservableComputedValue.zoneKey];

  ObservableComputedValue._(this._computeCallback);

  final T Function() _computeCallback;

  @override
  T get value => _computeAndUpdateDependencies();

  @override
  Stream<T> get stream => _observableChanges.stream
      .where((observable) => _dependencies.contains(observable))
      .map((_) => _computeAndUpdateDependencies());

  final _dependencies = <Observable>{};
  void addDependency(Observable observable) {
    _dependencies.add(observable);
  }

  T _computeAndUpdateDependencies() {
    return runZoned(() {
      _dependencies.clear();
      return _computeCallback();
    }, zoneValues: {
      ObservableComputedValue.zoneKey: this,
    });
  }
}
