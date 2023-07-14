import '../observable_ref_holder.dart';
import 'observable.dart';

Observable<T> computed<T>(
  T Function(ComputedContext context) compute, {
  String? debugLabel,
}) =>
    ComputedObservable._(compute, debugLabel);

class ComputedContext {
  const ComputedContext._();

  static const instance = ComputedContext._();
}

class ComputedObservable<T> extends Observable<T> with ObservableRefHolder {
  ComputedObservable._(this._compute, [this._debugLabel]) {
    recompute();
  }

  final String? _debugLabel;
  final T Function(ComputedContext context) _compute;

  bool _initialized = false;

  @override
  void performRecompute() {
    final newValue = _compute(ComputedContext.instance);
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
