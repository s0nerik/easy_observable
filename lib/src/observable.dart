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
    ObservableComputedValue.current?.notifyRead(this);
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
  static const zoneKey = 'ObservableComputedValue';
  static ObservableComputedValue? get current =>
      Zone.current[ObservableComputedValue.zoneKey];

  ObservableComputedValue._(this._computeCallback) {
    _compute();
  }

  final T Function() _computeCallback;

  late T _value;
  @override
  T get value => _value;

  final _streamController = StreamController<T>.broadcast();
  @override
  Stream<T> get stream => _streamController.stream;

  final _dependencies = <Observable>{};

  void notifyRead(Observable observable) {
    _dependencies.add(observable);
  }

  void _compute() {
    runZoned(() {
      final oldObservables = Set.of(_dependencies);
      _dependencies.clear();
      _value = _computeCallback();
      final newObservables = _dependencies;
      final toRemove = oldObservables.difference(newObservables);
      final toAdd = newObservables.difference(oldObservables);
    }, zoneValues: {
      ObservableComputedValue.zoneKey: this,
    });
    _streamController.add(_value);
  }
}
