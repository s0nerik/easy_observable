import 'observable.dart';

MutableObservable<T> observable<T>(
  T value, {
  String? debugLabel,
}) =>
    MutableObservable._(value, debugLabel);

class MutableObservable<T> extends Observable<T> {
  MutableObservable._(T value, [this._debugLabel]) {
    initValue(value);
  }

  final String? _debugLabel;

  set value(T newValue) => setValue(newValue);

  @override
  String toString() =>
      '${_debugLabel != null ? '($_debugLabel) ' : ''}observable<$T>($value)';
}
