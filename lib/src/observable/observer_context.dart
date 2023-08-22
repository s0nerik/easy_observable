import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../debug_logging.dart';
import 'observable.dart';
import 'observed_key.dart';

abstract interface class ObserverContext implements BuildContext {
  void _recompute();
  void _registerObservable(Observable observable);
}

@internal
mixin ObserverContextMixin implements ObserverContext {
  final refs = <Observable>{};

  @override
  void _recompute() {
    assert(debugClearComputeDepthIfNeeded(this));
    assert(debugIncrementComputeDepth());
    assert(
      debugPrintRecomputeStatus(
        this,
        ObservedKey.value,
        refs,
        this is Observable ? (this as Observable).notifier : null,
        DebugRecomputeState.beforeRecompute,
      ),
    );

    _clearObservableRefs();
    performRecompute();

    assert(
      debugPrintRecomputeStatus(
        this,
        ObservedKey.value,
        refs,
        this is Observable ? (this as Observable).notifier : null,
        DebugRecomputeState.afterRecompute,
      ),
    );
    assert(debugDecrementComputeDepth());
  }

  @override
  void _registerObservable(Observable observable) {
    refs.add(observable);
  }

  void _clearObservableRefs() {
    for (final ref in refs) {
      ref.notifier.unregisterObserver(this);
    }
    refs.clear();
  }

  @internal
  void performRecompute();
}

@internal
extension InternalAPI on ObserverContext {
  void recompute() {
    _recompute();
  }

  void registerObservable(Observable observable) {
    _registerObservable(observable);
  }
}

/// A fake [BuildContext] implementation to make [ObserverContext] conform to
/// the [BuildContext] interface.
@internal
mixin FakeBuildContext on ObserverContext implements BuildContext {
  @override
  bool get debugDoingBuild => throw UnsupportedError('debugDoingBuild');

  @override
  InheritedWidget dependOnInheritedElement(
    InheritedElement ancestor, {
    Object? aspect,
  }) =>
      throw UnsupportedError('dependOnInheritedElement');

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({
    Object? aspect,
  }) =>
      throw UnsupportedError('dependOnInheritedWidgetOfExactType');

  @override
  DiagnosticsNode describeElement(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  }) =>
      throw UnsupportedError('describeElement');

  @override
  List<DiagnosticsNode> describeMissingAncestor({
    required Type expectedAncestorType,
  }) =>
      throw UnsupportedError('describeMissingAncestor');

  @override
  DiagnosticsNode describeOwnershipChain(String name) =>
      throw UnsupportedError('describeOwnershipChain');

  @override
  DiagnosticsNode describeWidget(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  }) =>
      throw UnsupportedError('describeWidget');

  @override
  void dispatchNotification(Notification notification) =>
      throw UnsupportedError('dispatchNotification');

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() =>
      throw UnsupportedError('findAncestorRenderObjectOfType');

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() =>
      throw UnsupportedError('findAncestorStateOfType');

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() =>
      throw UnsupportedError('findAncestorWidgetOfExactType');

  @override
  RenderObject? findRenderObject() =>
      throw UnsupportedError('findRenderObject');

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() =>
      throw UnsupportedError('findRootAncestorStateOfType');

  @override
  InheritedElement?
      getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() =>
          throw UnsupportedError('getElementForInheritedWidgetOfExactType');

  @override
  T? getInheritedWidgetOfExactType<T extends InheritedWidget>() =>
      throw UnsupportedError('getInheritedWidgetOfExactType');

  @override
  bool get mounted => throw UnsupportedError('mounted');

  @override
  BuildOwner? get owner => throw UnsupportedError('owner');

  @override
  Size? get size => throw UnsupportedError('size');

  @override
  void visitAncestorElements(ConditionalElementVisitor visitor) =>
      throw UnsupportedError('visitAncestorElements');

  @override
  void visitChildElements(ElementVisitor visitor) =>
      throw UnsupportedError('visitChildElements');

  @override
  Widget get widget => throw UnsupportedError('widget');
}
