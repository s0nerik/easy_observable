import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'observable.dart';

final _frame = Observable.mutable(0);
void _onBeginFrame(Duration timeStamp) {
  _frame.value++;
}

class InheritedObservableNotifier extends InheritedWidget {
  const InheritedObservableNotifier({super.key, required super.child});

  @override
  InheritedElement createElement() => ObservableNotifierInheritedElement(this);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class ObservableNotifierInheritedElement extends InheritedElement {
  ObservableNotifierInheritedElement(super.widget);

  final _elementSubs = <Element, Map<Observable, StreamSubscription>>{};

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    if (_frame.value == 0) {
      SchedulerBinding.instance.addPersistentFrameCallback(_onBeginFrame);
    }
  }

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    final observable = aspect as Observable;
    _elementSubs[dependent] ??= <Observable, StreamSubscription>{};
    final observableSubs = _elementSubs[dependent]!;
    observableSubs[observable] ??= observable.stream.listen((_) {
      dependent.markNeedsBuild();
    });
  }

  @override
  void onDependentRemoved(Element dependent) {
    final observableSubs = _elementSubs[dependent];
    if (observableSubs == null) {
      return;
    }

    for (final sub in observableSubs.values) {
      sub.cancel();
    }
    _elementSubs.remove(dependent);
  }
}

extension InheritedObservableNotifierWatcherExtension on BuildContext {
  T watch<T>(Observable<T> observable) {
    dependOnInheritedWidgetOfExactType<InheritedObservableNotifier>(
      aspect: observable,
    );
    return observable.value;
  }
}
