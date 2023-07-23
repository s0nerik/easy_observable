import 'dart:collection';

import 'package:easy_observable/src/observable/observer_context.dart';

import 'computed_observable.dart';

final _hotReloadableComputedObservables = HashSet<_ComputedWeakRef>(
  equals: (a, b) => _ComputedWeakRef.checkEquals(a, b),
);

/// Matches the `ComputedObservable`'s `hashCode` and `==` behavior as long as
/// the `ComputedObservable` is alive. After the `ComputedObservable` is
/// garbage collected, `equals` will always return `false`.
class _ComputedWeakRef {
  _ComputedWeakRef(ComputedObservable computed)
      : weakRef = WeakReference(computed),
        _hashCode = computed.hashCode;

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
    if (other is! _ComputedWeakRef) {
      return false;
    }
    return weakRef.target == other.weakRef.target;
  }

  @override
  int get hashCode => _hashCode;

  @override
  String toString() =>
      weakRef.target?.toString() ?? '_ComputedWeakRef(target: null)';
}

bool registerForHotReload(ComputedObservable computed) {
  if (computed.hotReloadable) {
    _hotReloadableComputedObservables.add(_ComputedWeakRef(computed));
  }
  return true;
}

bool performComputedHotReload() {
  final clearedComputedRefs = <_ComputedWeakRef>[];
  for (final computedRef in _hotReloadableComputedObservables) {
    final computed = computedRef.weakRef.target;
    if (computed == null) {
      clearedComputedRefs.add(computedRef);
      continue;
    }
    try {
      computed.recompute();
    } catch (e) {
      if (e.runtimeType.toString() == '_CompileTimeError') {
        // This happens when the compute callback refers to a no-longer-existing
        // parent object type which was renamed.
        //
        // It is safe to ignore this error as the `computed` here is outdated
        // and will be garbage collected soon anyway.
        clearedComputedRefs.add(computedRef);
        continue;
      }
      rethrow;
    }
  }
  _hotReloadableComputedObservables.removeAll(clearedComputedRefs);
  return true;
}
