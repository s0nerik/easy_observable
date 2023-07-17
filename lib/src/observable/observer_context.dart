import 'package:meta/meta.dart';

import '../debug_logging.dart';
import 'observable.dart';
import 'observed_key.dart';

@internal
mixin ObserverContext {
  final refs = <Observable>{};

  @internal
  void recompute() {
    assert(debugClearComputeDepthIfNeeded(this));
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
    performRecompute();

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
