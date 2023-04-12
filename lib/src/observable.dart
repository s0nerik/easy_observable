import 'dart:async';

import 'package:meta/meta.dart';

import 'computed_notifier.dart';

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
  static MutableObservable<T> mutable<T>(T value) => MutableObservable._(value);
  static Observable<T> computed<T>(T Function() compute) =>
      ComputedObservable(compute);

  late T _value;
  T get value => observeValue(const ObservedKey.value());

  final _computedNotifier = ComputedNotifier();
  final _changes = StreamController<T>.broadcast(sync: true);
  Stream<T> get stream => _changes.stream;
}

class MutableObservable<T> extends Observable<T> {
  MutableObservable._(T value) {
    _value = value;
  }

  set value(T newValue) {
    _value = newValue;
    notifyChange(const [ObservedKey.value()]);
  }

  @override
  String toString() => 'Observable.mutable($_value)';
}

class ComputedObservable<T> extends Observable<T> {
  static const zoneKey = 'ComputedObservable';
  static ComputedObservable? get current =>
      Zone.current[ComputedObservable.zoneKey];

  ComputedObservable(this._compute) {
    recompute();
  }

  final T Function() _compute;

  final _dependencies = <Observable>{};

  void recompute() {
    for (final dependency in _dependencies) {
      dependency._computedNotifier.unregisterKeyReferences(this);
    }
    _dependencies.clear();
    runZoned(_recompute, zoneValues: {
      ComputedObservable.zoneKey: this,
    });
  }

  void _recompute() {
    _value = _compute();
    notifyChange(const [ObservedKey.value()]);
  }

  @override
  String toString() => 'Observable.computed($_value)';
}
