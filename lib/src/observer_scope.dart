import 'package:easy_observable/src/observable_ref_holder.dart';

class ObserverScope<T> with ObservableRefHolder {
  ObserverScope(this._recompute);

  final void Function() _recompute;

  @override
  void performRecompute() {
    _recompute();
  }

  void dispose() {
    clearObservableRefs();
  }
}
