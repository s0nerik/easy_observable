import 'dart:async';

import 'package:meta/meta.dart';

import 'debug_logging.dart';
import 'observable/observable.dart';
import 'observer_notifier.dart';

@internal
mixin Observer {
  static const zoneKey = 'ObservableRefHolder';
  static Observer? get current => Zone.current[Observer.zoneKey];

  final refs = <Observable>{};

  @internal
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
      Observer.zoneKey: this,
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
