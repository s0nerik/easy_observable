import 'dart:async';

import 'package:easy_observable/src/observable_ref_holder.dart';
import 'package:meta/meta.dart';

import 'observable_debug_logging.dart';
import 'observer_notifier.dart';

MutableObservable<T> observable<T>(
  T value, {
  String? debugLabel,
}) =>
    MutableObservable._(value, debugLabel);

Observable<T> computed<T>(
  T Function() compute, {
  String? debugLabel,
}) =>
    ComputedObservable._(compute, debugLabel);

@internal
extension RegisterKeyReferenceExtension on Observable {
  void registerKeyReference(ObservedKey key) {
    final refHolder = ObservableRefHolder.current;
    if (refHolder != null && !identical(this, refHolder)) {
      _notifier.registerObserver(refHolder, key);
      refHolder.refs.add(this);
    }
  }
}

@internal
extension ObserveValueExtension<T> on Observable<T> {
  T observeValue(ObservedKey key) {
    assert(debugPrintObserveValue(this, key));
    registerKeyReference(key);
    return _value;
  }
}

@internal
extension NotifyChangeExtension on Observable {
  void notifyChange(List<ObservedKey> keys) {
    assert(debugPrintNotifyChange(this, keys));
    _changes.add(_value);
    for (final key in keys) {
      _notifier.recompute(key);
    }
  }
}

@internal
extension ComputedNotifierExtension on Observable {
  ObserverNotifier get notifier => _notifier;
}

abstract class Observable<T> {
  late T _value;
  T get value => observeValue(ObservedKey.value);

  final _notifier = ObserverNotifier();
  final _changes = StreamController<T>.broadcast(sync: true);
  Stream<T> get stream => _changes.stream;

  static void Function(String message)? debugPrint;
}

class MutableObservable<T> extends Observable<T> {
  MutableObservable._(T value, [this._debugLabel]) {
    _value = value;
  }

  final String? _debugLabel;

  set value(T newValue) {
    assert(debugPrintSetValue(this, ObservedKey.value, newValue));
    _value = newValue;
    notifyChange(const [ObservedKey.value]);
  }

  @override
  String toString() =>
      '${_debugLabel != null ? '($_debugLabel) ' : ''}observable($_value)';
}

class ComputedObservable<T> extends Observable<T> with ObservableRefHolder {
  ComputedObservable._(this._compute, [this._debugLabel]) {
    recompute();
  }

  final String? _debugLabel;

  final T Function() _compute;

  bool _initialized = false;

  @override
  void performRecompute() {
    _value = _compute();
    notifyChange(const [ObservedKey.value]);
    _initialized = true;
  }

  @override
  String toString() {
    if (!_initialized) {
      return '${_debugLabel != null ? '($_debugLabel) ' : ''}computed(UNINITIALIZED)';
    }
    return '${_debugLabel != null ? '($_debugLabel) ' : ''}computed($_value)';
  }
}
