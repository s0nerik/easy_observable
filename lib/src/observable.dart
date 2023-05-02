import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'computed_notifier.dart';

const _debugLogging = kDebugMode;
var _debugComputeDepth = 0;
String get _debugComputePrefix => '  ' * _debugComputeDepth;

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
    if (_debugLogging) {
      debugPrint('${_debugComputePrefix}OBSERVE $this -> $key');
    }
    registerKeyReference(key);
    return _value;
  }
}

@internal
extension NotifyChangeExtension on Observable {
  void notifyChange(List<ObservedKey> keys) {
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
    _value = newValue;
    if (_debugLogging) {
      debugPrint('${_debugComputePrefix}SET VALUE $this -> $newValue');
    }
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
    if (_debugLogging && current == null) {
      _debugComputeDepth = 0;
    }
    for (final dependency in _dependencies) {
      dependency._computedNotifier.unregisterKeyReferences(this);
    }
    _dependencies.clear();
    runZoned(_recompute, zoneValues: {
      ComputedObservable.zoneKey: this,
    });
  }

  void _recompute() {
    if (_debugLogging) {
      _debugComputeDepth++;
      debugPrint('${_debugComputePrefix}BEFORE RECOMPUTE:');
      debugPrint('$_debugComputePrefix| value <- $this');
      final descLines = _computedNotifier.debugKeyReferencesTreeDescription();
      for (final line in descLines) {
        debugPrint('$_debugComputePrefix| $line');
      }
    }

    _value = _compute();
    notifyChange(const [ObservedKey.value]);
    _initialized = true;

    if (_debugLogging) {
      _debugComputeDepth--;
      debugPrint('${_debugComputePrefix}AFTER RECOMPUTE:');
      debugPrint('$_debugComputePrefix| value <- $this');
      final descLines2 = _computedNotifier.debugKeyReferencesTreeDescription();
      for (final line in descLines2) {
        debugPrint('$_debugComputePrefix| $line');
      }
    }
  }

  @override
  String toString() {
    if (!_initialized) {
      return '${_debugLabel != null ? '($_debugLabel) ' : ''}Observable.computed(UNINITIALIZED)';
    }
    return '${_debugLabel != null ? '($_debugLabel) ' : ''}Observable.computed($_value)';
  }
}
