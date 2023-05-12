import 'dart:collection';

import 'observable.dart';
import 'observer.dart';

enum _Key { value }

/// Matches the `Observer`'s `hashCode` and `==` behavior as long as
/// the `Observer` is alive. After the `Observer` is
/// garbage collected, `equals` will always return `false`.
class _ObserverWeakRef {
  _ObserverWeakRef(Observer observer)
      : weakRef = WeakReference(observer),
        _hashCode = observer.hashCode;

  final WeakReference<Observer> weakRef;
  final int _hashCode;

  static bool checkEquals(Object a, Object b) {
    if (a is Observer) {
      return b == a;
    }
    return a == b;
  }

  @override
  bool operator ==(Object other) {
    if (weakRef.target == null) {
      return false;
    }
    if (other is Observer) {
      return weakRef.target == other;
    }
    if (other is! _ObserverWeakRef) {
      return false;
    }
    return weakRef.target == other.weakRef.target;
  }

  @override
  int get hashCode => _hashCode;
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
  final _referencedKeys = LinkedHashMap<Object, Set<ObservedKey>>(
    equals: (a, b) => _ObserverWeakRef.checkEquals(a, b),
  );
  final _keyReferences = <ObservedKey, Set<_ObserverWeakRef>>{};

  void registerKeyReference(Observer observer, ObservedKey key) {
    final weakRefWrapper = _ObserverWeakRef(observer);
    _referencedKeys[weakRefWrapper] ??= {};
    _referencedKeys[observer]!.add(key);
    _keyReferences[key] ??= {};
    _keyReferences[key]!.add(weakRefWrapper);
  }

  void unregisterKeyReferences(Observer observer) {
    final keys = _referencedKeys[observer];
    _referencedKeys.remove(observer);
    if (keys == null) return;

    for (final key in keys) {
      final refs = _keyReferences[key];
      if (refs == null) continue;
      refs.remove(observer);
      if (refs.isEmpty) {
        _keyReferences.remove(key);
      }
    }
  }

  void recompute(ObservedKey key) {
    final refs = _keyReferences[key]?.toList().reversed;
    if (refs == null) return;

    for (final ref in refs) {
      final computed = ref.weakRef.target;
      if (computed == null) {
        _keyReferences[key]!.remove(ref);
        _referencedKeys.remove(ref);
        continue;
      }
      computed.recompute();
    }
  }

  List<String> debugKeyReferencesTreeDescription({
    int nestingLevel = 0,
    List<String>? lines,
  }) {
    final nesting = '  ' * nestingLevel;

    lines ??= <String>[];
    for (final entry in _keyReferences.entries) {
      for (final ref in entry.value) {
        lines.add('$nesting╰ ${entry.key} <- $ref');
        final target = ref.weakRef.target;
        if (target is Observable) {
          (target as Observable)
              .computedNotifier
              .debugKeyReferencesTreeDescription(
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
    for (final entry in _referencedKeys.entries) {
      for (final key in entry.value) {
        lines.add('$nesting╰ $key <- ${entry.key}');
        final target = (entry.key as _ObserverWeakRef).weakRef.target;
        if (target is Observable) {
          (target as Observable)
              .computedNotifier
              .debugReferencedKeysTreeDescription(
                nestingLevel: nestingLevel + 1,
                lines: lines,
              );
        }
      }
    }
    return lines;
  }
}
