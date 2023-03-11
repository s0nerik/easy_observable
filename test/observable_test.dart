import 'package:easy_observable/easy_observable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Observable.stream notifies of value changes', () async {
    var observable = Observable.mutable(0);

    var value = 0;
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
}
