import 'dart:collection';

import 'observable.dart';

enum _Key { value }

/// Matches the `ComputedObservable`'s `hashCode` and `==` behavior as long as
/// the `ComputedObservable` is alive. After the `ComputedObservable` is
/// garbage collected, `equals` will always return `false`.
class _ComputedWeakRefWrapper {
  _ComputedWeakRefWrapper(ComputedObservable observable)
      : weakRef = WeakReference(observable),
        _hashCode = observable.hashCode;

  final WeakReference<ComputedObservable> weakRef;
  final int _hashCode;

  static bool checkEquals(Object a, Object b) {
    if (a is ComputedObservable) {
      return b == a;
    }
    return a == b;
  }

  @override
  bool operator ==(Object other) {
    if (weakRef.target == null) {
      return false;
    }
    if (other is ComputedObservable) {
      return weakRef.target == other;
    }
    if (other is! _ComputedWeakRefWrapper) {
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

class ComputedNotifier {
  final _referencedKeys = LinkedHashMap<Object, Set<ObservedKey>>(
    equals: (a, b) => _ComputedWeakRefWrapper.checkEquals(a, b),
  );
  final _keyReferences = <ObservedKey, Set<_ComputedWeakRefWrapper>>{};

  void registerKeyReference(ComputedObservable computed, ObservedKey key) {
    final weakRefWrapper = _ComputedWeakRefWrapper(computed);
    _referencedKeys[weakRefWrapper] ??= {};
    _referencedKeys[computed]!.add(key);
    _keyReferences[key] ??= {};
    _keyReferences[key]!.add(weakRefWrapper);
  }

  void unregisterKeyReferences(ComputedObservable computed) {
    final keys = _referencedKeys[computed];
    _referencedKeys.remove(computed);
    if (keys == null) return;

    for (final key in keys) {
      final refs = _keyReferences[key];
      if (refs == null) continue;
      refs.remove(computed);
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
        ref.weakRef.target?.computedNotifier.debugKeyReferencesTreeDescription(
          nestingLevel: nestingLevel + 1,
          lines: lines,
        );
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
        (entry.key as _ComputedWeakRefWrapper)
            .weakRef
            .target
            ?.computedNotifier
            .debugReferencedKeysTreeDescription(
              nestingLevel: nestingLevel + 1,
              lines: lines,
            );
      }
    }
    return lines;
  }
}
