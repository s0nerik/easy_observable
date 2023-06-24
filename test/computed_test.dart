import 'package:easy_observable/easy_observable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('value is recomputed only when referenced observables notify', () {
    final obs1 = observable('a');
    final obs2 = observable(0);

    var recomputations = 0;
    final computedValue = computed(() {
      recomputations++;
      return '${obs1.value}${obs2.value}';
    });

    expect(computedValue.value, 'a0');
    expect(recomputations, 1);

    obs1.value = 'b';
    expect(computedValue.value, 'b0');
    expect(recomputations, 2);

    obs2.value = 1;
    expect(computedValue.value, 'b1');
    expect(recomputations, 3);
  });

  test('each referenced observable notification == 1 recompute', () {
    final obs1 = observable('a');
    final obs2 = observable(0);

    var recomputations = 0;
    final computedValue = computed(() {
      recomputations++;
      return '${obs1.value}${obs2.value}';
    });

    expect(computedValue.value, 'a0');
    expect(recomputations, 1);

    obs1.value = 'b';
    obs2.value = 1;
    expect(computedValue.value, 'b1');
    expect(recomputations, 3);
  });

  test('no longer referenced observables do_not trigger a recompute', () {
    final obs1 = observable('a');
    final obs2 = observable(0);

    bool readObs1 = true;
    bool readObs2 = true;
    var recomputations = 0;
    final computedValue = computed(() {
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

    expect(computedValue.value, 'a0');
    expect(recomputations, 1);

    obs1.value = 'b';
    obs2.value = 1;
    expect(computedValue.value, 'b1');
    expect(recomputations, 3);

    readObs1 = false;
    obs1.value = 'c';
    expect(computedValue.value, '1');
    expect(recomputations, 4);

    obs1.value = 'd';
    expect(computedValue.value, '1');
    expect(recomputations, 4);

    readObs2 = false;
    obs2.value = 2;
    expect(computedValue.value, '');
    expect(recomputations, 5);

    obs1.value = 'e';
    obs2.value = 3;
    expect(computedValue.value, '');
    expect(recomputations, 5);
  });

  // ????????
  test(
      'if computed is not listened by anyone (including other computeds) - it is not automatically recomputed',
      () {
    final obs1 = observable('a');
    final obs2 = observable(0);

    var recomputations = 0;
    final computedValue = computed(() {
      recomputations++;
      return '${obs1.value}${obs2.value}';
    });

    expect(computedValue.value, 'a0');
    expect(recomputations, 1);

    obs1.value = 'b';
    obs2.value = 1;
    expect(computedValue.value, 'b1');
    expect(recomputations, 2);

    final obs3 = observable('c');
    final computed2 = computed(() {
      recomputations++;
      return '${obs3.value}${computedValue.value}';
    });

    expect(computed2.value, 'ca0');
    expect(recomputations, 4);

    obs1.value = 'd';
    obs2.value = 2;
    expect(computedValue.value, 'd2');
    expect(computed2.value, 'cd2');
    expect(recomputations, 6);

    obs3.value = 'e';
    expect(computedValue.value, 'd2');
    expect(computed2.value, 'ed2');
    expect(recomputations, 7);
  });
}
