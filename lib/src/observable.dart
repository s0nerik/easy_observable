import 'dart:async';

import 'package:weak_map/weak_map.dart';

final _observableChangeControllers = WeakMap<Observable, StreamController>();

abstract class Observable<T> {
  static ObservableValue<T> mutable<T>(T value) => ObservableValue._(value);

  T get value;
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
