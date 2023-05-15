import 'dart:async';

import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

    dep1 = Observable.mutable('a', debugLabel: 'dep1');
    dep2 = Observable.mutable(0, debugLabel: 'dep2');
    dep3 = Observable.mutable(false, debugLabel: 'dep3');
    dep1computed = Observable.computed(() {
      scheduleMicrotask(() {
        streamComputations.putIfAbsent(dep1computed, () => 0);
        streamComputations[dep1computed] =
            streamComputations[dep1computed]! + 1;
      });
      return 'dep1computed: ${dep1.value}';
    }, debugLabel: 'dep1computed');
    dep2computed = Observable.computed(() {
      scheduleMicrotask(() {
        streamComputations.putIfAbsent(dep2computed, () => 0);
        streamComputations[dep2computed] =
            streamComputations[dep2computed]! + 1;
      });
      return 'dep2computed: ${dep2.value}';
    }, debugLabel: 'dep2computed');
    dep3computed = Observable.computed(() {
      scheduleMicrotask(() {
        streamComputations.putIfAbsent(dep3computed, () => 0);
        streamComputations[dep3computed] =
            streamComputations[dep3computed]! + 1;
      });
      return 'dep3computed: ${dep3.value}';
    }, debugLabel: 'dep3computed');
    computed1and2 = Observable.computed(() {
      scheduleMicrotask(() {
        streamComputations.putIfAbsent(computed1and2, () => 0);
        streamComputations[computed1and2] =
            streamComputations[computed1and2]! + 1;
      });
      return '${dep1computed.value}, ${dep2computed.value}';
    }, debugLabel: 'computed1and2');

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
