import 'dart:async';

import 'package:meta/meta.dart';

import 'computed_notifier.dart';
import 'observable_debug_logging.dart';

@internal
extension RegisterKeyReferenceExtension on Observable {
  void registerKeyReference(ObservedKey key) {
    final computed = ComputedObservable.current;
    if (computed != null && !identical(this, computed)) {
      _computedNotifier.registerKeyReference(computed, key);
      computed._dependencies.add(this);
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
      _computedNotifier.recompute(key);
    }
  }
}

@internal
extension ComputedNotifierExtension on Observable {
  ComputedNotifier get computedNotifier => _computedNotifier;
}

abstract class Observable<T> {
  static MutableObservable<T> mutable<T>(
    T value, {
    String? debugLabel,
  }) =>
      MutableObservable._(value, debugLabel);

  static Observable<T> computed<T>(
    T Function() compute, {
    String? debugLabel,
  }) =>
      ComputedObservable(compute, debugLabel);

  late T _value;
  T get value => observeValue(ObservedKey.value);

  final _computedNotifier = ComputedNotifier();
  final _changes = StreamController<T>.broadcast(sync: true);
  Stream<T> get stream => _changes.stream;
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
      '${_debugLabel != null ? '($_debugLabel) ' : ''}Observable.mutable($_value)';
}

class ComputedObservable<T> extends Observable<T> {
  static const zoneKey = 'ComputedObservable';
  static ComputedObservable? get current =>
      Zone.current[ComputedObservable.zoneKey];

  ComputedObservable(this._compute, [this._debugLabel]) {
    recompute();
  }

  final String? _debugLabel;

  final T Function() _compute;

  final _dependencies = <Observable>{};

  bool _initialized = false;

  void recompute() {
    assert(debugClearComputeDepthIfNeeded(current));
    assert(debugIncrementComputeDepth());
    assert(
      debugPrintRecomputeStatus(
        this,
        ObservedKey.value,
        _dependencies,
        computedNotifier,
        DebugRecomputeState.beforeRecompute,
      ),
    );

    for (final dependency in _dependencies) {
      dependency._computedNotifier.unregisterKeyReferences(this);
    }
    _dependencies.clear();
    runZoned(_recompute, zoneValues: {
      ComputedObservable.zoneKey: this,
    });

    assert(
      debugPrintRecomputeStatus(
        this,
        ObservedKey.value,
        _dependencies,
        computedNotifier,
        DebugRecomputeState.afterRecompute,
      ),
    );
    assert(debugDecrementComputeDepth());
  }

  void _recompute() {
    _value = _compute();
    notifyChange(const [ObservedKey.value]);
    _initialized = true;
  }

  @override
  String toString() {
    if (!_initialized) {
      return '${_debugLabel != null ? '($_debugLabel) ' : ''}Observable.computed(UNINITIALIZED)';
    }
    return '${_debugLabel != null ? '($_debugLabel) ' : ''}Observable.computed($_value)';
  }
}
