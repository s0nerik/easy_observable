import 'package:easy_observable/src/observable/computed_hot_reload.dart';
import 'package:meta/meta.dart';

import 'observable.dart';
import 'observer_context.dart';

typedef ComputedCallback<T> = T Function(ObserverContext context);

Observable<T> computed<T>(
  ComputedCallback<T> compute, {
  String? debugLabel,
  bool hotReloadable = true,
}) =>
    ComputedObservable._(
      compute,
      debugLabel: debugLabel,
      hotReloadable: hotReloadable,
    );

class ComputedObservable<T> extends Observable<T> with ObserverContextMixin {
  ComputedObservable._(
    this._compute, {
    String? debugLabel,
    this.hotReloadable = true,
  }) : _debugLabel = debugLabel {
    assert(registerForHotReload(this));
    recompute();
  }

  final String? _debugLabel;
  final ComputedCallback<T> _compute;
  final bool hotReloadable;

  bool _initialized = false;

  @override
  @internal
  void performRecompute() {
    final newValue = _compute(this);
    setValue(newValue);
    _initialized = true;
  }

  @override
  String toString() {
    if (!_initialized) {
      return '${_debugLabel != null ? '($_debugLabel) ' : ''}computed<$T>(UNINITIALIZED)';
    }
    return '${_debugLabel != null ? '($_debugLabel) ' : ''}computed<$T>($value)';
  }
}
