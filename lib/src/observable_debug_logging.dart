import 'package:flutter/foundation.dart';

import 'computed_notifier.dart';
import 'observable.dart';

var _computeDepth = 0;
String get _computePrefix => '  ' * _computeDepth;

const _printObserveValue = false;
const _printSetValue = false;
const _printNotifyChange = true;

const _printBeforeRecompute = true;
const _printAfterRecompute = true;
const _targetComputeDepth = 1;

bool debugClearComputeDepth(ComputedObservable? currentScope) {
  if (currentScope == null) {
    _computeDepth = 0;
  }
  return true;
}

bool debugIncrementComputeDepth() {
  _computeDepth++;
  return true;
}

bool debugDecrementComputeDepth() {
  _computeDepth--;
  return true;
}

bool debugPrintBeforeRecompute(
  Observable observable,
  ObservedKey key,
  ComputedNotifier computedNotifier,
) {
  if (_targetComputeDepth != -1 && _computeDepth != _targetComputeDepth) {
    return true;
  }
  if (_printBeforeRecompute) {
    debugPrint('${_computePrefix}BEFORE RECOMPUTE:');
    debugPrint('$_computePrefix╰ $key <- $observable');
    final descLines = computedNotifier.debugKeyReferencesTreeDescription();
    for (final line in descLines) {
      debugPrint('$_computePrefix  $line');
    }
  }
  return true;
}

bool debugPrintAfterRecompute(
  Observable observable,
  ObservedKey key,
  ComputedNotifier computedNotifier,
) {
  if (_targetComputeDepth != -1 && _computeDepth != _targetComputeDepth) {
    return true;
  }
  if (_printAfterRecompute) {
    debugPrint('${_computePrefix}AFTER RECOMPUTE:');
    debugPrint('$_computePrefix╰ $key <- $observable');
    final descLines = computedNotifier.debugKeyReferencesTreeDescription();
    for (final line in descLines) {
      debugPrint('$_computePrefix  $line');
    }
  }
  return true;
}

bool debugPrintSetValue(Observable observable, ObservedKey key, Object? value) {
  if (_printSetValue) {
    debugPrint('${_computePrefix}SET $observable -> $key = $value');
  }
  return true;
}

bool debugPrintObserveValue(Observable observable, ObservedKey key) {
  if (_printObserveValue) {
    debugPrint('${_computePrefix}OBSERVE $observable -> $key');
  }
  return true;
}

bool debugPrintNotifyChange(Observable observable, List<ObservedKey> keys) {
  if (_printNotifyChange) {
    debugPrint('${_computePrefix}NOTIFY $observable -> $keys');
  }
  return true;
}