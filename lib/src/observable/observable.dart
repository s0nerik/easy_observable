import 'dart:async';
import 'dart:collection';

import 'package:easy_observable/src/observable/observer_context.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../debug_logging.dart';
import 'observed_key.dart';
import 'observer_notifier.dart';

/// Matches the `VoidCallback`'s `hashCode` and `==` behavior as long as
/// the `VoidCallback` is alive. After the `VoidCallback` is
/// garbage collected, `equals` will always return `false`.
class _VoidCallbackWeakRef {
  _VoidCallbackWeakRef(VoidCallback callback)
      : weakRef = WeakReference(callback),
        _hashCode = callback.hashCode;

  final WeakReference<VoidCallback> weakRef;
  final int _hashCode;

  static bool checkEquals(Object? a, Object? b) {
    if (a is VoidCallback) {
      return b == a;
    }
    return a == b;
  }

  @override
  bool operator ==(Object other) {
    if (weakRef.target == null) {
      return false;
    }
    if (other is VoidCallback) {
      return weakRef.target == other;
    }
    if (other is! _VoidCallbackWeakRef) {
      return false;
    }
    return weakRef.target == other.weakRef.target;
  }

  @override
  int get hashCode => _hashCode;

  @override
  String toString() =>
      weakRef.target?.toString() ?? '_VoidCallbackWeakRef(target: null)';
}

/// Keys are actually guaranteed to be `_VoidCallbackWeakRef` instances.
/// However, to be able to compare a normal ref with a weak ref, and since
/// Dart checks the key types before calling `equals`, `Object` is declared
/// as a key type.
final _listeners = LinkedHashMap<Object, StreamSubscription>(
  equals: _VoidCallbackWeakRef.checkEquals,
);

var _lastCleanup = DateTime.now();
void _cleanup() {
  final now = DateTime.now();
  if (_lastCleanup.difference(now).abs() < const Duration(seconds: 10)) {
    return;
  }
  _lastCleanup = now;
  _listeners.removeWhere(
    (key, value) => (key as _VoidCallbackWeakRef).weakRef.target == null,
  );
}

abstract class Observable<T> implements ValueListenable<T> {
  late T _value;
  @override
  T get value => _value;

  final _notifier = ObserverNotifier();
  final _changes = StreamController<T>.broadcast();
  Stream<T> get stream => _changes.stream;

  @override
  void addListener(VoidCallback listener) {
    final weakRefWrapper = _VoidCallbackWeakRef(listener);
    _listeners[weakRefWrapper] ??= stream.listen((_) => listener());
  }

  @override
  void removeListener(VoidCallback listener) {
    final subscription = _listeners.remove(listener);
    subscription?.cancel();

    _cleanup();
  }

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
    observer.registerObservable(this);
  }

  void notifyChange(List<ObservedKey> keys) {
    assert(debugPrintNotifyChange(this, keys));
    _changes.add(_value);
    for (final key in keys) {
      _notifier.recompute(key);
    }
  }
}
