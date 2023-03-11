import 'dart:async';

import 'package:weak_map/weak_map.dart';

final _observableChangeControllers = WeakMap<Observable, StreamController>();
final _observableScopes = WeakMap<Observable, ObservableComputedScope>();

abstract class Observable<T> {
  static ObservableValue<T> mutable<T>(T value) => ObservableValue._(value);
  static ObservableComputedValue<T> computed<T>(T Function() valueGenerator) =>
      ObservableComputedValue._(valueGenerator);

  T get value;
  Stream<T> get stream;
}

extension ObservableStreamExtension<T> on Observable<T> {
  Stream<T> get stream => _changesStreamController.stream;
}

extension ObservableStreamControllerExtension<T> on Observable<T> {
  StreamController<T> get _changesStreamController {
    var controller = _observableChangeControllers[this] as StreamController<T>?;
    if (controller == null) {
      controller = StreamController<T>.broadcast();
      _observableChangeControllers[this] = controller;
    }
    return controller;
  }
}

class ObservableValue<T> implements Observable<T> {
  ObservableValue._(this._value);

  T _value;
  @override
  T get value => _value;

  set value(T newValue) {
    _value = newValue;
    _changesStreamController.add(newValue);
  }
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
  ObservableComputedScope._() {}

  static const zoneKey = 'computed_scope';
  static ObservableComputedScope? get current =>
      Zone.current[ObservableComputedScope.zoneKey];

  T run<T>(T Function() fn) =>
      runZoned(fn, zoneValues: {ObservableComputedScope.zoneKey: this});

  final _observables = <Observable>[];
}
