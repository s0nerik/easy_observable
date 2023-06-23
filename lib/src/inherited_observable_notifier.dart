import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'observable.dart';

class InheritedObservableNotifier extends InheritedWidget {
  const InheritedObservableNotifier({super.key, required super.child});

  @override
  InheritedElement createElement() => _ObservableNotifierInheritedElement(this);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class _ObservableNotifierInheritedElement extends InheritedElement {
  _ObservableNotifierInheritedElement(super.widget);

  final _elementSubs = <Element, Map<Observable, StreamSubscription>>{};
  final _frameElementSubs = <Element, Map<Observable, StreamSubscription>>{};

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    SchedulerBinding.instance.addPostFrameCallback(_onPostFrame);
  }

  void _onPostFrame(_) {
    if (!mounted) return;

    // dispose all subscriptions that are no longer present in the frame
    // subscriptions map, but only for elements that are present within the
    // frame element subscriptions map
    for (final element in _frameElementSubs.keys) {
      final frameObservableSubs = _frameElementSubs[element]!;
      final observableSubs = _elementSubs[element]!;
      for (final observable in observableSubs.keys) {
        if (!frameObservableSubs.containsKey(observable)) {
          final sub = observableSubs[observable]!;
          sub.cancel();
        }
      }
      _elementSubs[element] = frameObservableSubs;
      if (observableSubs.isEmpty) {
        _elementSubs.remove(element);
      }
    }

    _frameElementSubs.clear();
    SchedulerBinding.instance.addPostFrameCallback(_onPostFrame);
  }

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    if (aspect == null) {
      onDependentRemoved(dependent);
      return;
    }

    final observable = aspect as Observable;

    _elementSubs[dependent] ??= <Observable, StreamSubscription>{};
    final observableSubs = _elementSubs[dependent]!;
    observableSubs[observable] ??= observable.stream.listen((_) {
      dependent.markNeedsBuild();
    });

    _frameElementSubs[dependent] ??= <Observable, StreamSubscription>{};
    final frameObservableSubs = _frameElementSubs[dependent]!;
    frameObservableSubs[observable] = observableSubs[observable]!;
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

  /// A workaround for https://github.com/flutter/flutter/issues/106549#issue-1283582212
  ///
  /// Use this on the first line of your build method if you specify
  /// conditional observable watchers.
  ///
  /// This will ensure that any previously-specified observable subscriptions
  /// are canceled before the new subscriptions are created via
  /// `context.watch()` down the line.
  ///
  /// Example:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   context.unwatch();
  ///   if (condition) {
  ///     context.watch(observable);
  ///   }
  /// }
  /// ```
  void unwatch() {
    dependOnInheritedWidgetOfExactType<InheritedObservableNotifier>(
      aspect: null,
    );
  }
}
