import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int rebuilds;
  late Widget widget;
  late List<Observable> observed;

  setUp(() {
    observed = [];
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
      observed = [Observable.mutable(0)];
      await widgetTester.pumpWidget(widget);
      await widgetTester.pumpAndSettle();
      expect(rebuilds, 1);
    },
  );

  testWidgets(
    'ObserverBuilder rebuilds only once after each change',
    (widgetTester) async {
      final observable = Observable.mutable('a');
      observed = [observable];

      await widgetTester.pumpWidget(widget);
      expect(rebuilds, 1);

      observable.value = 'b';
      await widgetTester.pumpAndSettle();
      expect(rebuilds, 2);
    },
  );

  testWidgets(
    'ObserverBuilder rebuilds only once after each bunch of synchronous changes',
    (widgetTester) async {
      final observable1 = Observable.mutable('a');
      final observable2 = Observable.mutable(0);
      final computed =
          Observable.computed(() => '${observable1.value}${observable2.value}');

      observed = [computed];

      await widgetTester.pumpWidget(widget);
      expect(rebuilds, 1);

      observable1.value = 'b';
      observable2.value = 1;
      await widgetTester.pumpAndSettle();
      expect(rebuilds, 2);

      observable1.value = 'c';
      observable2.value = 2;
      await widgetTester.pumpAndSettle();
      expect(rebuilds, 3);
    },
  );
  testWidgets(
    'ObserverBuilder subscribes to changes in all Observables accessed during the previous build',
    (widgetTester) async {
      final observable1 = Observable.mutable('a');
      final observable2 = Observable.mutable(0);

      observed = [observable1, observable2];

      await widgetTester.pumpWidget(widget);
      expect(rebuilds, 1);

      observable1.value = 'b';
      await widgetTester.pumpAndSettle();
      expect(rebuilds, 2);

      observed = [observable2];
      observable1.value = 'c';
      await widgetTester.pumpAndSettle();
      // Even though the `dep1` was_not accessed during this build, it was
      // accessed during the previous one, so we expect a rebuild.
      expect(rebuilds, 3);

      observable1.value = 'd';
      await widgetTester.pumpAndSettle();
      // Since `dep1` was_not accessed during the previous build, changing
      // its value does_not trigger an additional rebuild.
      expect(rebuilds, 3);

      observable2.value = 2;
      await widgetTester.pumpAndSettle();
      // `dep2` is still referenced, so changing its value triggers a rebuild.
      expect(rebuilds, 4);

      observed = [];
      observable2.value = 3;
      await widgetTester.pumpAndSettle();
      // Even though not `dep2` nor `dep1` were accessed during this build,
      // `dep2` was accessed during the previous one, so we expect a rebuild.
      expect(rebuilds, 5);

      observable1.value = 'e';
      observable2.value = 4;
      await widgetTester.pumpAndSettle();
      // Since no observables were accessed during the previous build,
      // changing any observable values does_not trigger an additional rebuild.
      expect(rebuilds, 5);
    },
  );

  testWidgets(
    'Accessing a specific list item rebuilds only when the value at that index changes',
    (widgetTester) async {
      final listObservable = Observable.mutable(['a', 'b', 'c']);

      await widgetTester.pumpWidget(
        ObserverBuilder(
          builder: (context) {
            listObservable[1];
            rebuilds++;
            return const SizedBox.shrink();
          },
        ),
      );

      await widgetTester.pumpAndSettle();
      expect(rebuilds, 1);

      listObservable[0] = 'aa';

      await widgetTester.pumpAndSettle();
      expect(rebuilds, 1);
    },
  );

  testWidgets(
    'ObserverBuilder rebuild can be triggered by the parent widget as usual',
    (widgetTester) async {
      final observable = Observable.mutable('a');

      final observerWidget = ObserverBuilder(
        builder: (context) {
          MediaQuery.of(context);
          observable.value;
          rebuilds++;
          return const SizedBox.shrink();
        },
      );

      await widgetTester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(alwaysUse24HourFormat: false),
          child: observerWidget,
        ),
      );

      await widgetTester.pumpAndSettle();
      expect(rebuilds, 1);

      observable.value = 'b';

      await widgetTester.pumpAndSettle();
      expect(rebuilds, 2);

      await widgetTester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(alwaysUse24HourFormat: true),
          child: observerWidget,
        ),
      );
      expect(rebuilds, 3);

      observable.value = 'c';
      await widgetTester.pumpAndSettle();
      expect(rebuilds, 4);
    },
  );
}