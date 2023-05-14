import 'package:easy_observable/easy_observable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
