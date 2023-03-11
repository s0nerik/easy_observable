import 'dart:async';

import 'observable.dart';

class ObservableValue<T> implements Observable<T> {
  ObservableValue(this._value);

  T _value;
  @override
  T get value => _value;

  set value(T newValue) {
    _value = newValue;
    _controller.add(newValue);
  }

  final _controller = StreamController<T>.broadcast();
  @override
  Stream<T> get stream => _controller.stream;
}
