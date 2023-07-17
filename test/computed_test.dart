import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Observable.debugPrint = debugPrint;

  test('value is recomputed only when watched observables notify', () {
    final obs1 = observable('a');
    final obs2 = observable(0);

    var recomputations = 0;
    final computedValue = computed((context) {
      recomputations++;
      return '${obs1.watch(context)}${obs2.watch(context)}';
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

  test('each watched observable notification == 1 recompute', () {
    final obs1 = observable('a');
    final obs2 = observable(0);

    var recomputations = 0;
    final computedValue = computed((context) {
      recomputations++;
      return '${obs1.watch(context)}${obs2.watch(context)}';
    });

    expect(computedValue.value, 'a0');
    expect(recomputations, 1);

    obs1.value = 'b';
    obs2.value = 1;
    expect(computedValue.value, 'b1');
    expect(recomputations, 3);
  });

  test('no longer watched observables do_not trigger a recompute', () {
    final obs1 = observable('a');
    final obs2 = observable(0);

    bool readObs1 = true;
    bool readObs2 = true;
    var recomputations = 0;
    final computedValue = computed((context) {
      recomputations++;
      if (readObs1 && readObs2) {
        return '${obs1.watch(context)}${obs2.watch(context)}';
      } else if (readObs1) {
        return obs1.watch(context);
      } else if (readObs2) {
        return '${obs2.watch(context)}';
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
}
