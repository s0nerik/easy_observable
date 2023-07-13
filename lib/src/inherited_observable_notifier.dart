import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'observable.dart';

class ObservableRoot extends StatelessWidget {
  const ObservableRoot({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _InheritedObservableNotifier(
      child: child,
    );
  }
}

class _InheritedObservableNotifier extends InheritedWidget {
  const _InheritedObservableNotifier({super.key, required super.child});

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
    _clearSubscriptionsForUnwatchedObservables();
    _clearSubscriptionsForUnmountedElements();
    SchedulerBinding.instance.addPostFrameCallback(_onPostFrame);
  }

  // Workaround for https://github.com/flutter/flutter/issues/106549
  void _clearSubscriptionsForUnwatchedObservables() {
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
  }

  // Workaround for https://github.com/flutter/flutter/issues/128432
  void _clearSubscriptionsForUnmountedElements() {
    final unmountedElements = <Element>[];
    for (final element in _elementSubs.keys) {
      if (!element.mounted) {
        unmountedElements.add(element);
      }
    }
    for (final element in unmountedElements) {
      _disposeDependentSubscriptions(element);
    }
  }

  void _disposeDependentSubscriptions(Element dependent) {
    final observableSubs = _elementSubs[dependent];
    if (observableSubs == null) {
      return;
    }

    for (final sub in observableSubs.values) {
      sub.cancel();
    }
    _elementSubs.remove(dependent);
  }

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    if (aspect == null) {
      _disposeDependentSubscriptions(dependent);
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
}

extension InheritedObservableNotifierWatcherExtension on BuildContext {
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
  void unwatchObservables() {
    dependOnInheritedWidgetOfExactType<_InheritedObservableNotifier>(
      aspect: null,
    );
  }
}

extension InheritedObservableNotifierObservableExtension<T> on Observable<T> {
  T watch(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<_InheritedObservableNotifier>(
      aspect: this,
    );
    return value;
  }
}
