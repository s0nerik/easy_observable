import 'dart:async';

abstract class Observable<T> {
  static ObservableValue<T> mutable<T>(T value) => ObservableValue._(value);

  T get value;
  Stream<T> get stream;
}

class ObservableValue<T> implements Observable<T> {
  ObservableValue._(this._value);

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
