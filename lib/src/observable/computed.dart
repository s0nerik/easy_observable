import '../observer.dart';
import 'observable.dart';

typedef ComputedCallback<T> = T Function(Observer context);

Observable<T> computed<T>(
  ComputedCallback<T> compute, {
  String? debugLabel,
}) =>
    ComputedObservable._(compute, debugLabel);

class ComputedObservable<T> extends Observable<T> with Observer {
  ComputedObservable._(this._compute, [this._debugLabel]) {
    recompute();
  }

  final String? _debugLabel;
  final ComputedCallback<T> _compute;

  bool _initialized = false;

  @override
  void performRecompute() {
    final newValue = _compute(this);
    setValue(newValue);
    _initialized = true;
  }

  @override
  String toString() {
    if (!_initialized) {
      return '${_debugLabel != null ? '($_debugLabel) ' : ''}computed(UNINITIALIZED)';
    }
    return '${_debugLabel != null ? '($_debugLabel) ' : ''}computed($value)';
  }
}
