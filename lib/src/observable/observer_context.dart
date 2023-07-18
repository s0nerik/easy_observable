import 'package:meta/meta.dart';

import '../debug_logging.dart';
import 'observable.dart';
import 'observed_key.dart';

abstract interface class ObserverContext {
  void _recompute();
  void _registerObservable(Observable observable);
}

@internal
mixin ObserverContextMixin implements ObserverContext {
  final refs = <Observable>{};

  @override
  void _recompute() {
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

    _clearObservableRefs();
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

  @override
  void _registerObservable(Observable observable) {
    refs.add(observable);
  }

  void _clearObservableRefs() {
    for (final ref in refs) {
      ref.notifier.unregisterObserver(this);
    }
    refs.clear();
  }

  @internal
  void performRecompute();
}

@internal
extension InternalAPI on ObserverContext {
  void recompute() {
    _recompute();
  }

  void registerObservable(Observable observable) {
    _registerObservable(observable);
  }
}
