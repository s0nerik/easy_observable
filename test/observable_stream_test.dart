import 'dart:async';

import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Observable.debugPrint = debugPrint;

  late MutableObservable<String> dep1;
  late MutableObservable<int> dep2;
  late MutableObservable<bool> dep3;
  late Observable<String> dep1computed;
  late Observable<String> dep2computed;
  late Observable<String> dep3computed;
  late Observable<String> computed1and2;
  late Map<Observable, List> streamNotifications;
  late Map<Observable, int> streamComputations;

  final streamSubscriptions = <Observable, StreamSubscription>{};

  setUp(() {
    final oldDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {};

    streamNotifications = {};
    streamComputations = {};

    dep1 = observable('a', debugLabel: 'dep1');
    dep2 = observable(0, debugLabel: 'dep2');
    dep3 = observable(false, debugLabel: 'dep3');
    dep1computed = computed((context) {
      scheduleMicrotask(() {
        streamComputations.putIfAbsent(dep1computed, () => 0);
        streamComputations[dep1computed] =
            streamComputations[dep1computed]! + 1;
      });
      return 'dep1computed: ${dep1.watch(context)}';
    }, debugLabel: 'dep1computed', hotReloadable: false);
    dep2computed = computed((context) {
      scheduleMicrotask(() {
        streamComputations.putIfAbsent(dep2computed, () => 0);
        streamComputations[dep2computed] =
            streamComputations[dep2computed]! + 1;
      });
      return 'dep2computed: ${dep2.watch(context)}';
    }, debugLabel: 'dep2computed', hotReloadable: false);
    dep3computed = computed((context) {
      scheduleMicrotask(() {
        streamComputations.putIfAbsent(dep3computed, () => 0);
        streamComputations[dep3computed] =
            streamComputations[dep3computed]! + 1;
      });
      return 'dep3computed: ${dep3.watch(context)}';
    }, debugLabel: 'dep3computed', hotReloadable: false);
    computed1and2 = computed((context) {
      scheduleMicrotask(() {
        streamComputations.putIfAbsent(computed1and2, () => 0);
        streamComputations[computed1and2] =
            streamComputations[computed1and2]! + 1;
      });
      return '${dep1computed.watch(context)}, ${dep2computed.watch(context)}';
    }, debugLabel: 'computed1and2', hotReloadable: false);

    streamSubscriptions.addAll({
      dep1: dep1.stream.listen(
        (value) => streamNotifications.putIfAbsent(dep1, () => []).add(value),
      ),
      dep2: dep2.stream.listen(
        (value) => streamNotifications.putIfAbsent(dep2, () => []).add(value),
      ),
      dep3: dep3.stream.listen(
        (value) => streamNotifications.putIfAbsent(dep3, () => []).add(value),
      ),
      dep1computed: dep1computed.stream.listen(
        (value) =>
            streamNotifications.putIfAbsent(dep1computed, () => []).add(value),
      ),
      dep2computed: dep2computed.stream.listen(
        (value) =>
            streamNotifications.putIfAbsent(dep2computed, () => []).add(value),
      ),
      dep3computed: dep3computed.stream.listen(
        (value) =>
            streamNotifications.putIfAbsent(dep3computed, () => []).add(value),
      ),
      computed1and2: computed1and2.stream.listen(
        (value) =>
            streamNotifications.putIfAbsent(computed1and2, () => []).add(value),
      ),
    });

    debugPrint = oldDebugPrint;
  });

  tearDown(() {
    streamSubscriptions.forEach((observable, subscription) {
      subscription.cancel();
    });
  });

  test('Observable.stream notifies of value changes', () async {
    final observableValue = observable(0);

    var value = observableValue.value;
    final sub =
        observableValue.stream.listen((observedValue) => value = observedValue);

    expect(value, 0);

    observableValue.value = 1;
    await Future.value();
    expect(value, 1);

    observableValue.value = 2;
    await Future.value();
    expect(value, 2);

    observableValue.value = 5;
    await Future.value();
    expect(value, 5);

    sub.cancel();
  });

  test(
      'ComputedObservable.stream notifies of a computed value whenever any of the dependencies notify change',
      () async {
    final dep0 = observable('a');
    final dep1 = observable(0);
    final computedDep = computed(
        (context) => '${dep0.watch(context)} ${dep1.watch(context)}',
        hotReloadable: false);
    final computedValue = computed(
        (context) => 'result: ${computedDep.watch(context)}',
        hotReloadable: false);

    final streamNotifications = <String>[];
    final sub = computedValue.stream.listen(streamNotifications.add);

    expect(streamNotifications, []);
    expect(computedValue.value, 'result: a 0');

    dep0.value = 'b';
    await Future.value();
    expect(computedValue.value, 'result: b 0');
    expect(streamNotifications, ['result: b 0']);

    dep1.value = 1;
    await Future.value();
    expect(computedValue.value, 'result: b 1');
    expect(streamNotifications, ['result: b 0', 'result: b 1']);

    sub.cancel();
  });

  test(
      'No matter how many subscribers, ComputedObservable.stream notifies them of a computed value change only once',
      () async {
    final dep0 = observable('a');
    final dep1 = observable(0);
    final computedDep = computed(
        (context) => '${dep0.watch(context)} ${dep1.watch(context)}',
        hotReloadable: false);
    final computedValue = computed(
        (context) => 'result: ${computedDep.watch(context)}',
        hotReloadable: false);

    final streamNotifications1 = <String>[];
    final streamNotifications2 = <String>[];
    final sub1 = computedValue.stream.listen(streamNotifications1.add);
    final sub2 = computedValue.stream.listen(streamNotifications2.add);

    expect(streamNotifications1, []);
    expect(streamNotifications2, []);

    dep0.value = 'b';
    await Future.value();
    expect(streamNotifications1, ['result: b 0']);
    expect(streamNotifications2, ['result: b 0']);

    dep1.value = 1;
    await Future.value();
    expect(streamNotifications1, ['result: b 0', 'result: b 1']);
    expect(streamNotifications2, ['result: b 0', 'result: b 1']);

    sub1.cancel();
    sub2.cancel();
  });

  test(
    'emits only when a dependency is changed (1)',
    () async {
      dep1.value = 'b';
      await Future.value();
      expect(streamNotifications[dep1], ['b']);
      expect(streamNotifications[dep2], isNull);
      expect(streamNotifications[dep3], isNull);
      expect(streamNotifications[dep1computed], ['dep1computed: b']);
      expect(streamNotifications[dep2computed], isNull);
      expect(streamNotifications[dep3computed], isNull);
      expect(
        streamNotifications[computed1and2],
        ['dep1computed: b, dep2computed: 0'],
      );
    },
  );
  test(
    'emits only when a dependency is changed (2)',
    () async {
      dep1.value = 'b';
      dep3.value = true;
      await Future.value();
      expect(streamNotifications[dep1], ['b']);
      expect(streamNotifications[dep2], isNull);
      expect(streamNotifications[dep3], [true]);
      expect(streamNotifications[dep1computed], ['dep1computed: b']);
      expect(streamNotifications[dep2computed], isNull);
      expect(streamNotifications[dep3computed], ['dep3computed: true']);
      expect(
        streamNotifications[computed1and2],
        ['dep1computed: b, dep2computed: 0'],
      );
    },
  );
  test(
    'emits even if a dependency is changed to the same value',
    () async {
      dep1.value = 'b';
      dep1.value = 'b';
      await Future.value();
      dep1.value = 'b';
      await Future.value();
      expect(streamNotifications[dep1], ['b', 'b', 'b']);
      expect(
        streamNotifications[dep1computed],
        [
          'dep1computed: b',
          'dep1computed: b',
          'dep1computed: b',
        ],
      );
      expect(
        streamNotifications[computed1and2],
        [
          'dep1computed: b, dep2computed: 0',
          'dep1computed: b, dep2computed: 0',
          'dep1computed: b, dep2computed: 0',
        ],
      );
    },
  );
}
