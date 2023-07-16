import 'dart:collection';

import 'observable.dart';
import 'observer_context.dart';

enum _Key { value }

/// Matches the `Observer`'s `hashCode` and `==` behavior as long as
/// the `Observer` is alive. After the `Observer` is
/// garbage collected, `equals` will always return `false`.
class _ObserverWeakRef {
  _ObserverWeakRef(ObserverContext observer)
      : weakRef = WeakReference(observer),
        _hashCode = observer.hashCode;

  final WeakReference<ObserverContext> weakRef;
  final int _hashCode;

  static bool checkEquals(Object a, Object b) {
    if (a is ObserverContext) {
      return b == a;
    }
    return a == b;
  }

  @override
  bool operator ==(Object other) {
    if (weakRef.target == null) {
      return false;
    }
    if (other is ObserverContext) {
      return weakRef.target == other;
    }
    if (other is! _ObserverWeakRef) {
      return false;
    }
    return weakRef.target == other.weakRef.target;
  }

  @override
  int get hashCode => _hashCode;

  @override
  String toString() =>
      weakRef.target?.toString() ?? '_ObserverWeakRef(target: null)';
}

class ObservedKey {
  const ObservedKey(this.key);
  const ObservedKey._value() : key = _Key.value;

  static const value = ObservedKey._value();

  final Object? key;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservedKey &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    if (key == _Key.value) return 'value';
    return '$key';
  }
}

class ObserverNotifier {
  /// Keys are actually guaranteed to be an `_ObserverWeakRef` instances.
  /// However, to be able to compare a normal ref with a weak ref, and since
  /// Dart checks the key types before calling `equals`, `Object` is declared
  /// as a key type.
  final _observerKeys = LinkedHashMap<Object, Set<ObservedKey>>(
    equals: (a, b) => _ObserverWeakRef.checkEquals(a, b),
  );

  /// Set items are actually guaranteed to be an `_ObserverWeakRef` instances.
  /// However, to be able to compare a normal ref with a weak ref, and since
  /// Dart checks the key types before calling `equals`, `Object` is declared
  /// as an item type.
  final _keyObservers = <ObservedKey, Set<Object>>{};

  void registerObserver(ObserverContext observer, ObservedKey key) {
    final weakRefWrapper = _ObserverWeakRef(observer);
    _observerKeys[weakRefWrapper] ??= {};
    _observerKeys[observer]!.add(key);
    _keyObservers[key] ??= LinkedHashSet(
      equals: (a, b) => _ObserverWeakRef.checkEquals(a, b),
    );
    _keyObservers[key]!.add(weakRefWrapper);
  }

  void unregisterObserver(ObserverContext observer) {
    final keys = _observerKeys[observer];
    _observerKeys.remove(observer);
    if (keys == null) return;

    for (final key in keys) {
      final refs = _keyObservers[key];
      if (refs == null) continue;
      refs.remove(observer);
      if (refs.isEmpty) {
        _keyObservers.remove(key);
      }
    }
  }

  void recompute(ObservedKey key) {
    final refs = _keyObservers[key]?.toList().reversed;
    if (refs == null) return;

    for (final ref in refs) {
      final observer = (ref as _ObserverWeakRef).weakRef.target;
      if (observer == null) {
        _keyObservers[key]!.remove(ref);
        _observerKeys.remove(ref);
        continue;
      }
      observer.recompute();
    }
  }

  List<String> debugKeyReferencesTreeDescription({
    int nestingLevel = 0,
    List<String>? lines,
  }) {
    final nesting = '  ' * nestingLevel;

    lines ??= <String>[];
    for (final entry in _keyObservers.entries) {
      for (final ref in entry.value) {
        lines.add('$nesting╰ ${entry.key} <- $ref');
        final target = (ref as _ObserverWeakRef).weakRef.target;
        if (target is Observable) {
          (target as Observable).notifier.debugKeyReferencesTreeDescription(
                nestingLevel: nestingLevel + 1,
                lines: lines,
              );
        }
      }
    }
    return lines;
  }

  List<String> debugReferencedKeysTreeDescription({
    int nestingLevel = 0,
    List<String>? lines,
  }) {
    final nesting = '  ' * nestingLevel;

    lines ??= <String>[];
    for (final entry in _observerKeys.entries) {
      for (final key in entry.value) {
        lines.add('$nesting╰ $key <- ${entry.key}');
        final target = (entry.key as _ObserverWeakRef).weakRef.target;
        if (target is Observable) {
          (target as Observable).notifier.debugReferencedKeysTreeDescription(
                nestingLevel: nestingLevel + 1,
                lines: lines,
              );
        }
      }
    }
    return lines;
  }
}
