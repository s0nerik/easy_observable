import 'package:flutter/widgets.dart';

import '../inherited_observable_notifier.dart';
import '../observable.dart';

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
    dependOnInheritedWidgetOfExactType<InheritedObservableNotifier>(
      aspect: null,
    );
  }
}

extension InheritedObservableNotifierObservableExtension<T> on Observable<T> {
  T watch(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<InheritedObservableNotifier>(
      aspect: this,
    );
    return value;
  }
}
