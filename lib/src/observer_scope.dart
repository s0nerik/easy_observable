import 'package:easy_observable/src/observable_ref_holder.dart';
import 'package:meta/meta.dart';

class ObserverScope<T> with ObservableRefHolder {
  ObserverScope(this._recompute);

  final void Function() _recompute;

  @internal
  @override
  void recompute() {
    clearObservableRefs();
    _recompute();
  }

  void dispose() {
    clearObservableRefs();
  }
}
