import 'package:easy_observable/src/observable_ref_holder.dart';

import 'observable.dart';
import 'observer_notifier.dart';

const _enableDebugLogging = false;

var _computeDepth = 0;
String get _computePrefix => '  ' * _computeDepth;

const _printObserveValue = _enableDebugLogging;
const _targetPrintObserveValueComputeDepth = -1;

const _printSetValue = _enableDebugLogging;
const _targetSetValueComputeDepth = -1;

const _printNotifyChange = _enableDebugLogging;
const _targetNotifyChangeComputeDepth = -1;

const _printBeforeRecompute = _enableDebugLogging;
const _printAfterRecompute = _enableDebugLogging;
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

bool debugClearComputeDepthIfNeeded(ObservableRefHolder? currentScope) {
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
  ObservableRefHolder observable,
  ObservedKey key,
  Set<Observable> dependencies,
  ObserverNotifier? computedNotifier,
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
      Observable.debugPrint
          ?.call('$_computePrefix$_eventBeforeRecompute $observable:');
    } else {
      Observable.debugPrint
          ?.call('$_computePrefix$_eventAfterRecompute $observable:');
    }

    Observable.debugPrint?.call('$_computePrefix  DEPENDENCIES:');
    for (final dependency in dependencies) {
      Observable.debugPrint?.call('$_computePrefix  - $dependency');
    }

    if (computedNotifier != null) {
      Observable.debugPrint?.call('$_computePrefix  KEY REFERENCES:');
      final descLines = computedNotifier.debugKeyReferencesTreeDescription();
      for (final line in descLines) {
        Observable.debugPrint?.call('$_computePrefix  $line');
      }
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
    Observable.debugPrint?.call(
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
    Observable.debugPrint?.call(
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
    Observable.debugPrint?.call(
      '$_computePrefix$_eventNotifyChange $observable -> $keys',
    );
  }
  return true;
}
