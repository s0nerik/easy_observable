import 'dart:async';

import 'package:weak_map/weak_map.dart';

final _observableControllers = WeakMap<Observable, StreamController>();

abstract class Observable<T> {
  static ObservableValue<T> mutable<T>(T value) => ObservableValue._(value);

  T get value;
}

extension ObservableStreamExtension<T> on Observable<T> {
  Stream<T> get stream => _streamController.stream;
}

extension ObservableStreamControllerExtension<T> on Observable<T> {
  StreamController<T> get _streamController {
    var controller = _observableControllers[this] as StreamController<T>?;
    if (controller == null) {
      controller = StreamController<T>.broadcast();
      _observableControllers[this] = controller;
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
    _streamController.add(newValue);
  }
}
