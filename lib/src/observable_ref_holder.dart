import 'package:meta/meta.dart';

import 'observable.dart';
import 'observer.dart';

mixin ObservableRefHolder implements Observer {
  final refs = <Observable>{};

  @internal
  void clearObservableRefs() {
    for (final ref in refs) {
      ref.notifier.unregisterObserver(this);
    }
    refs.clear();
  }
}
