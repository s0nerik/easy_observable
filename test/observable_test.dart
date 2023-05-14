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

  group('Observable.computed recompute rules', () {
    test('value is recomputed only when referenced observables notify', () {
      final obs1 = Observable.mutable('a');
      final obs2 = Observable.mutable(0);

      var recomputations = 0;
      final computed = Observable.computed(() {
        recomputations++;
        return '${obs1.value}${obs2.value}';
      });

      expect(computed.value, 'a0');
      expect(recomputations, 1);

      obs1.value = 'b';
      expect(computed.value, 'b0');
      expect(recomputations, 2);

      obs2.value = 1;
      expect(computed.value, 'b1');
      expect(recomputations, 3);
    });

    test('each referenced observable notification == 1 recompute', () {
      final obs1 = Observable.mutable('a');
      final obs2 = Observable.mutable(0);

      var recomputations = 0;
      final computed = Observable.computed(() {
        recomputations++;
        return '${obs1.value}${obs2.value}';
      });

      expect(computed.value, 'a0');
      expect(recomputations, 1);

      obs1.value = 'b';
      obs2.value = 1;
      expect(computed.value, 'b1');
      expect(recomputations, 3);
    });

    test('no longer referenced observables do_not trigger a recompute', () {
      final obs1 = Observable.mutable('a');
      final obs2 = Observable.mutable(0);

      bool readObs1 = true;
      bool readObs2 = true;
      var recomputations = 0;
      final computed = Observable.computed(() {
        recomputations++;
        if (readObs1 && readObs2) {
          return '${obs1.value}${obs2.value}';
        } else if (readObs1) {
          return obs1.value;
        } else if (readObs2) {
          return '${obs2.value}';
        } else {
          return '';
        }
      });

      expect(computed.value, 'a0');
      expect(recomputations, 1);

      obs1.value = 'b';
      obs2.value = 1;
      expect(computed.value, 'b1');
      expect(recomputations, 3);

      readObs1 = false;
      obs1.value = 'c';
      expect(computed.value, '1');
      expect(recomputations, 4);

      obs1.value = 'd';
      expect(computed.value, '1');
      expect(recomputations, 4);

      readObs2 = false;
      obs2.value = 2;
      expect(computed.value, '');
      expect(recomputations, 5);

      obs1.value = 'e';
      obs2.value = 3;
      expect(computed.value, '');
      expect(recomputations, 5);
    });
  });
}
