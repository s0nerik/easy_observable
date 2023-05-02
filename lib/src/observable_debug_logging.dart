import 'package:flutter/foundation.dart';

import 'computed_notifier.dart';
import 'observable.dart';

var _computeDepth = 0;
String get _computePrefix => '  ' * _computeDepth;

const _printObserveValue = true;
const _targetPrintObserveValueComputeDepth = -1;

const _printSetValue = true;
const _targetSetValueComputeDepth = -1;

const _printNotifyChange = true;
const _targetNotifyChangeComputeDepth = -1;

const _printBeforeRecompute = true;
const _printAfterRecompute = true;
const _targetComputeDepth = 1;

// ANSI green
const _green = '\u001b[32m';
// ANSI blue
const _blue = '\u001b[34m';
// ANSI yellow
const _yellow = '\u001b[33m';
// ANSI magenta
const _magenta = '\u001b[35m';
// ANSI reset
const _reset = '\u001b[0m';

const _eventObserve = '${_magenta}OBSERVE$_reset';
const _eventSetValue = '${_green}SET$_reset';
const _eventNotifyChange = '${_blue}NOTIFY$_reset';
const _eventBeforeRecompute = '${_yellow}BEFORE RECOMPUTE$_reset';
const _eventAfterRecompute = '${_yellow}AFTER RECOMPUTE$_reset';

enum DebugRecomputeState {
  beforeRecompute,
  afterRecompute,
}

bool debugClearComputeDepthIfNeeded(ComputedObservable? currentScope) {
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

bool debugPrintRecomputeStatus(
  Observable observable,
  ObservedKey key,
  Set<Observable> dependencies,
  ComputedNotifier computedNotifier,
  DebugRecomputeState recomputeState,
) {
  if (_targetComputeDepth != -1 && _computeDepth != _targetComputeDepth) {
    return true;
  }
  final shouldPrint = recomputeState == DebugRecomputeState.beforeRecompute
      ? _printBeforeRecompute
      : _printAfterRecompute;
  if (shouldPrint) {
    if (recomputeState == DebugRecomputeState.beforeRecompute) {
      debugPrint('$_computePrefix$_eventBeforeRecompute $observable:');
    } else {
      debugPrint('$_computePrefix$_eventAfterRecompute $observable:');
    }

    debugPrint('$_computePrefix  DEPENDENCIES:');
    for (final dependency in dependencies) {
      debugPrint('$_computePrefix  - $dependency');
    }

    debugPrint('$_computePrefix  KEY REFERENCES:');
    final descLines = computedNotifier.debugKeyReferencesTreeDescription();
    for (final line in descLines) {
      debugPrint('$_computePrefix  $line');
    }
  }
  return true;
}

bool debugPrintSetValue(Observable observable, ObservedKey key, Object? value) {
  if (_targetSetValueComputeDepth != -1 &&
      _computeDepth != _targetSetValueComputeDepth) {
    return true;
  }
  if (_printSetValue) {
    debugPrint(
      '$_computePrefix$_eventSetValue $observable -> $key = $value',
    );
  }
  return true;
}

bool debugPrintObserveValue(Observable observable, ObservedKey key) {
  if (_targetPrintObserveValueComputeDepth != -1 &&
      _computeDepth != _targetPrintObserveValueComputeDepth) {
    return true;
  }
  if (_printObserveValue) {
    debugPrint(
      '$_computePrefix$_eventObserve $observable -> $key',
    );
  }
  return true;
}

bool debugPrintNotifyChange(Observable observable, List<ObservedKey> keys) {
  if (_targetNotifyChangeComputeDepth != -1 &&
      _computeDepth != _targetNotifyChangeComputeDepth) {
    return true;
  }
  if (_printNotifyChange) {
    debugPrint(
      '$_computePrefix$_eventNotifyChange $observable -> $keys',
    );
  }
  return true;
}
