import 'package:context_watch/context_watch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../observable/observable.dart';
import '../observable/observed_key.dart';
import '../observable/observer_context.dart';

extension UnwatchObservablesExtension on BuildContext {
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
  ///   context.unwatchObservables();
  ///   if (condition) {
  ///     context.watch(observable);
  ///   }
  /// }
  /// ```
  void unwatchObservables() => unwatch();
}

extension WatchObservableExtension<T> on Observable<T> {
  T watch(Object context) {
    assert(context is BuildContext || context is ObserverContext);

    if (context is ObserverContext) {
      registerObserver(context, ObservedKey.value);
      return value;
    }
    // ignore: unnecessary_cast
    return (this as ValueListenable<T>).watch(context as BuildContext);
  }
}
