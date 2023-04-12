import 'observable.dart';

class _ValueKey {
  const _ValueKey();
}

class ObservedKey {
  const ObservedKey(this.key);
  const ObservedKey.value() : key = const _ValueKey();

  final Object? key;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservedKey &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;
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
    final refs = _keyReferences[key]?.toSet();
    if (refs == null) return;

    for (final ref in refs) {
      ref.recompute();
    }
  }
}
