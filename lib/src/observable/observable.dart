import 'dart:async';

import 'package:easy_observable/src/observable/observer_context.dart';
import 'package:meta/meta.dart';

import '../debug_logging.dart';
import 'observer_notifier.dart';

abstract class Observable<T> {
  late T _value;
  T get value => _value;

  final _notifier = ObserverNotifier();
  final _changes = StreamController<T>.broadcast(sync: true);
  Stream<T> get stream => _changes.stream;

  static void Function(String message)? debugPrint;
}

@internal
extension InternalAPI<T> on Observable<T> {
  ObserverNotifier get notifier => _notifier;

  void initValue(T newValue) {
    _value = newValue;
    assert(debugPrintInitValue(this, newValue));
  }

  void setValue(
    T newValue, {
    List<ObservedKey> keys = const [ObservedKey.value],
  }) {
    assert(debugPrintSetValue(this, keys, newValue));
    _value = newValue;
    notifyChange(keys);
  }

  void registerObserver(ObserverContext observer, ObservedKey key) {
    _notifier.registerObserver(observer, key);
    observer.refs.add(this);
  }

  void notifyChange(List<ObservedKey> keys) {
    assert(debugPrintNotifyChange(this, keys));
    _changes.add(_value);
    for (final key in keys) {
      _notifier.recompute(key);
    }
  }
}
