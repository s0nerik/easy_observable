import 'dart:async';

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
    ObservableComputedScope.current?.notifyRead(this);
    return _value;
  }

  set value(T newValue) {
    _value = newValue;
    _streamController.add(newValue);
  }

  final _streamController = StreamController<T>.broadcast();
  @override
  Stream<T> get stream => _streamController.stream;
}

class ObservableComputedValue<T> implements Observable<T> {
  ObservableComputedValue._(this._compute) {
    _value = scope.run(_compute);
  }

  final T Function() _compute;
  final scope = ObservableComputedScope._();

  late T _value;
  @override
  T get value => _value;
}

class ObservableComputedScope {
  ObservableComputedScope._();

  static const zoneKey = 'ObservableComputedScope';
  static ObservableComputedScope? get current =>
      Zone.current[ObservableComputedScope.zoneKey];

  T run<T>(T Function() fn) =>
      runZoned(fn, zoneValues: {ObservableComputedScope.zoneKey: this});

  final _observables = <Observable>{};

  void notifyRead(Observable observable) {
    _observables.add(observable);
  }
}
