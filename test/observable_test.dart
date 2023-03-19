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
}
