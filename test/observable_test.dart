import 'dart:async';

import 'package:easy_observable/easy_observable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ObservableValue.stream notifies of value changes', () async {
    final observable = Observable.mutable(0);

    var value = observable.value;
    observable.stream.listen((observedValue) => value = observedValue);

    expect(value, 0);

    observable.value = 1;
    await Future.value();
    expect(value, 1);

    observable.value = 2;
    await Future.value();
    expect(value, 2);

    observable.value = 5;
    await Future.value();
    expect(value, 5);
  });
  test(
      'ObservableComputedValue.stream notifies of a computed value whenever any of the dependencies notify change',
      () async {
    final dep0 = Observable.mutable('a');
    final dep1 = Observable.mutable(0);
    final computedDep =
        Observable.computed(() => '${dep0.value} ${dep1.value}');
    final observable =
        Observable.computed(() => 'result: ${computedDep.value}');

    final streamNotifications = <String>[];
    observable.stream.listen(streamNotifications.add);

    expect(streamNotifications, []);
    expect(observable.value, 'result: a 0');

    dep0.value = 'b';
    await Future.value();
    expect(observable.value, 'result: b 0');
    expect(streamNotifications, ['result: b 0']);

    dep1.value = 1;
    await Future.value();
    expect(observable.value, 'result: b 1');
    expect(streamNotifications, ['result: b 0', 'result: b 1']);
  });
  test(
      'No matter how many subscribers, ObservableComputedValue.stream notifies them of a computed value change only once',
      () async {
    final dep0 = Observable.mutable('a');
    final dep1 = Observable.mutable(0);
    final computedDep =
        Observable.computed(() => '${dep0.value} ${dep1.value}');
    final observable =
        Observable.computed(() => 'result: ${computedDep.value}');

    final streamNotifications1 = <String>[];
    final streamNotifications2 = <String>[];
    observable.stream.listen(streamNotifications1.add);
    observable.stream.listen(streamNotifications2.add);

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
  });
  group('ObservableComputedValue', () {
    late MutableObservable<String> dep1;
    late MutableObservable<int> dep2;
    late MutableObservable<bool> dep3;
    late Observable<String> computed1;
    late Observable<String> computed2;
    late Observable<String> computed3;
    late Observable<String> combinedComputed;
    late Map<Observable, List> streamNotifications;
    late Map<Observable, int> streamComputations;

    setUp(() {
      streamNotifications = {};
      streamComputations = {};

      dep1 = Observable.mutable('a');
      dep2 = Observable.mutable(0);
      dep3 = Observable.mutable(false);
      computed1 = Observable.computed(() {
        scheduleMicrotask(() {
          streamComputations.putIfAbsent(computed1, () => 0);
          streamComputations[computed1] = streamComputations[computed1]! + 1;
        });
        return 'computed1: ${dep1.value}';
      });
      computed2 = Observable.computed(() {
        scheduleMicrotask(() {
          streamComputations.putIfAbsent(computed2, () => 0);
          streamComputations[computed2] = streamComputations[computed2]! + 1;
        });
        return 'computed2: ${dep2.value}';
      });
      computed3 = Observable.computed(() {
        scheduleMicrotask(() {
          streamComputations.putIfAbsent(computed3, () => 0);
          streamComputations[computed3] = streamComputations[computed3]! + 1;
        });
        return 'computed3: ${dep3.value}';
      });
      combinedComputed = Observable.computed(() {
        scheduleMicrotask(() {
          streamComputations.putIfAbsent(combinedComputed, () => 0);
          streamComputations[combinedComputed] =
              streamComputations[combinedComputed]! + 1;
        });
        return '${computed1.value}, ${computed2.value}';
      });

      dep1.stream.listen(
        (value) => streamNotifications.putIfAbsent(dep1, () => []).add(value),
      );
      dep2.stream.listen(
        (value) => streamNotifications.putIfAbsent(dep2, () => []).add(value),
      );
      dep3.stream.listen(
        (value) => streamNotifications.putIfAbsent(dep3, () => []).add(value),
      );
      computed1.stream.listen(
        (value) =>
            streamNotifications.putIfAbsent(computed1, () => []).add(value),
      );
      computed2.stream.listen(
        (value) =>
            streamNotifications.putIfAbsent(computed2, () => []).add(value),
      );
      computed3.stream.listen(
        (value) =>
            streamNotifications.putIfAbsent(computed3, () => []).add(value),
      );
      combinedComputed.stream.listen(
        (value) => streamNotifications
            .putIfAbsent(combinedComputed, () => [])
            .add(value),
      );
    });

    group('`stream` notification rules', () {
      test(
        'ObservableComputedValue.stream is notified only when a dependency is changed (1)',
        () async {
          dep1.value = 'b';
          await Future.value();
          expect(streamNotifications[dep1], ['b']);
          expect(streamNotifications[dep2], isNull);
          expect(streamNotifications[dep3], isNull);
          expect(streamNotifications[computed1], ['computed1: b']);
          expect(streamNotifications[computed2], isNull);
          expect(streamNotifications[computed3], isNull);
          expect(
            streamNotifications[combinedComputed],
            ['computed1: b, computed2: 0'],
          );
        },
      );
      test(
        'ObservableComputedValue.stream is notified only when a dependency is changed (2)',
        () async {
          dep1.value = 'b';
          dep3.value = true;
          await Future.value();
          expect(streamNotifications[dep1], ['b']);
          expect(streamNotifications[dep2], isNull);
          expect(streamNotifications[dep3], [true]);
          expect(streamNotifications[computed1], ['computed1: b']);
          expect(streamNotifications[computed2], isNull);
          expect(streamNotifications[computed3], ['computed3: true']);
          expect(
            streamNotifications[combinedComputed],
            ['computed1: b, computed2: 0'],
          );
        },
      );
      test(
        'ObservableComputedValue.stream is notified even if a dependency is changed to the same value',
        () async {
          dep1.value = 'b';
          dep1.value = 'b';
          await Future.value();
          dep1.value = 'b';
          await Future.value();
          expect(streamNotifications[dep1], ['b', 'b', 'b']);
          expect(
            streamNotifications[computed1],
            [
              'computed1: b',
              'computed1: b',
              'computed1: b',
            ],
          );
          expect(
            streamNotifications[combinedComputed],
            [
              'computed1: b, computed2: 0',
              'computed1: b, computed2: 0',
              'computed1: b, computed2: 0',
            ],
          );
        },
      );
    });
  });
}
