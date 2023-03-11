import 'dart:async';

abstract class Observable<T> {
  T get value;
  Stream<T> get stream;
}
