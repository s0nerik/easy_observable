import 'dart:async';

import 'package:meta/meta.dart';

import 'observable.dart';
import 'observable_debug_logging.dart';
import 'observer.dart';
import 'observer_notifier.dart';

@internal
mixin ObservableRefHolder implements Observer {
  static const zoneKey = 'ObservableRefHolder';
  static ComputedObservable? get current =>
      Zone.current[ObservableRefHolder.zoneKey];

  final refs = <Observable>{};

  @internal
  @override
  void recompute() {
    assert(debugClearComputeDepthIfNeeded(current));
    assert(debugIncrementComputeDepth());
    assert(
      debugPrintRecomputeStatus(
        this,
        ObservedKey.value,
        refs,
        this is Observable ? (this as Observable).notifier : null,
        DebugRecomputeState.beforeRecompute,
      ),
    );

    clearObservableRefs();
    runZoned(performRecompute, zoneValues: {
      ObservableRefHolder.zoneKey: this,
    });

    assert(
      debugPrintRecomputeStatus(
        this,
        ObservedKey.value,
        refs,
        this is Observable ? (this as Observable).notifier : null,
        DebugRecomputeState.afterRecompute,
      ),
    );
    assert(debugDecrementComputeDepth());
  }

  void clearObservableRefs() {
    for (final ref in refs) {
      ref.notifier.unregisterObserver(this);
    }
    refs.clear();
  }

  void performRecompute();
}
