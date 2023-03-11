import 'dart:async';

class Observable<T> {
  Observable(this._value);

  T _value;
  T get value => _value;

  set value(T newValue) {
    _value = newValue;
    _controller.add(newValue);
  }

  final _controller = StreamController<T>.broadcast();
  Stream<T> get stream => _controller.stream;
}
