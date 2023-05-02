import 'observable.dart';

enum _Key { value }

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
  final _referencedKeys = <ComputedObservable, Set<ObservedKey>>{};
  final _keyReferences = <ObservedKey, Set<ComputedObservable>>{};

  void registerKeyReference(ComputedObservable computed, ObservedKey key) {
    _referencedKeys[computed] ??= {};
    _referencedKeys[computed]!.add(key);
    _keyReferences[key] ??= {};
    _keyReferences[key]!.add(computed);
  }

  void unregisterKeyReferences(ComputedObservable computed) {
    final keys = _referencedKeys.remove(computed);
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
      ref.recompute();
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
        ref.computedNotifier.debugKeyReferencesTreeDescription(
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
        entry.key.computedNotifier.debugReferencedKeysTreeDescription(
          nestingLevel: nestingLevel + 1,
          lines: lines,
        );
      }
    }
    return lines;
  }
}
