import 'dart:async';

import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/widgets.dart';
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
    late Observable<String> dep1computed;
    late Observable<String> dep2computed;
    late Observable<String> dep3computed;
    late Observable<String> computed1and2;
    late Map<Observable, List> streamNotifications;
    late Map<Observable, int> streamComputations;

    setUp(() {
      streamNotifications = {};
      streamComputations = {};

      dep1 = Observable.mutable('a');
      dep2 = Observable.mutable(0);
      dep3 = Observable.mutable(false);
      dep1computed = Observable.computed(() {
        scheduleMicrotask(() {
          streamComputations.putIfAbsent(dep1computed, () => 0);
          streamComputations[dep1computed] =
              streamComputations[dep1computed]! + 1;
        });
        return 'dep1computed: ${dep1.value}';
      });
      dep2computed = Observable.computed(() {
        scheduleMicrotask(() {
          streamComputations.putIfAbsent(dep2computed, () => 0);
          streamComputations[dep2computed] =
              streamComputations[dep2computed]! + 1;
        });
        return 'dep2computed: ${dep2.value}';
      });
      dep3computed = Observable.computed(() {
        scheduleMicrotask(() {
          streamComputations.putIfAbsent(dep3computed, () => 0);
          streamComputations[dep3computed] =
              streamComputations[dep3computed]! + 1;
        });
        return 'dep3computed: ${dep3.value}';
      });
      computed1and2 = Observable.computed(() {
        scheduleMicrotask(() {
          streamComputations.putIfAbsent(computed1and2, () => 0);
          streamComputations[computed1and2] =
              streamComputations[computed1and2]! + 1;
        });
        return '${dep1computed.value}, ${dep2computed.value}';
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
      dep1computed.stream.listen(
        (value) =>
            streamNotifications.putIfAbsent(dep1computed, () => []).add(value),
      );
      dep2computed.stream.listen(
        (value) =>
            streamNotifications.putIfAbsent(dep2computed, () => []).add(value),
      );
      dep3computed.stream.listen(
        (value) =>
            streamNotifications.putIfAbsent(dep3computed, () => []).add(value),
      );
      computed1and2.stream.listen(
        (value) =>
            streamNotifications.putIfAbsent(computed1and2, () => []).add(value),
      );
    });

    group('`stream` notification rules', () {
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
    });
    group('Observer widget rules', () {
      late int rebuilds;
      late Widget widget;
      late List<Observable> observed;

      setUp(() {
        observed = [computed1and2];
        rebuilds = 0;
        widget = ObserverBuilder(
          builder: (context) {
            for (final observable in observed) {
              // read the value to create a subscription
              observable.value;
            }
            rebuilds++;
            return const SizedBox.shrink();
          },
        );
      });

      testWidgets(
        'ObserverBuilder builds only once before the first change',
        (widgetTester) async {
          await widgetTester.pumpWidget(widget);
          await widgetTester.pumpAndSettle();
          expect(rebuilds, 1);
        },
      );

      testWidgets(
        'ObserverBuilder rebuilds only once after each change',
        (widgetTester) async {
          await widgetTester.pumpWidget(widget);
          expect(rebuilds, 1);

          dep1.value = 'b';
          await widgetTester.pumpAndSettle();
          expect(rebuilds, 2);
        },
      );

      testWidgets(
        'ObserverBuilder rebuilds only once after each bunch of synchronous changes',
        (widgetTester) async {
          await widgetTester.pumpWidget(widget);
          expect(rebuilds, 1);

          dep1.value = 'b';
          dep2.value = 1;
          await widgetTester.pumpAndSettle();
          expect(rebuilds, 2);

          dep1.value = 'c';
          dep2.value = 2;
          await widgetTester.pumpAndSettle();
          expect(rebuilds, 3);
        },
      );
    });
  });
}
