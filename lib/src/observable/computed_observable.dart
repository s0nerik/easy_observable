import 'package:meta/meta.dart';

import 'observable.dart';
import 'observer_context.dart';

typedef ComputedCallback<T> = T Function(ObserverContext context);

Observable<T> computed<T>(
  ComputedCallback<T> compute, {
  String? debugLabel,
}) =>
    ComputedObservable._(compute, debugLabel);

class ComputedObservable<T> extends Observable<T> with ObserverContextMixin {
  ComputedObservable._(this._compute, [this._debugLabel]) {
    recompute();
  }

  final String? _debugLabel;
  final ComputedCallback<T> _compute;

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
