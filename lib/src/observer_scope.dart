import 'package:easy_observable/src/observer.dart';

class ObserverScope<T> with Observer {
  ObserverScope(this._recompute) {
    recompute();
  }

  final void Function() _recompute;

  @override
  void performRecompute() {
    _recompute();
  }

  void dispose() {
    clearObservableRefs();
  }
}
