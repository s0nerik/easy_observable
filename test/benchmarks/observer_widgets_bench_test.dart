import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'widgets/observable_counter_bench_widget.dart';
import 'widgets/observable_counter_unwatch_bench_widget.dart';
import 'widgets/set_state_counter_bench_widget.dart';
import 'widgets/value_notifier_bench_widget.dart';

void main() {
  _benchmark('setState', const SetStateCounterBenchWidget());
  _benchmark('ValueNotifier', const ValueNotifierBenchWidget());
  _benchmark('EasyObservable', const ObservableCounterBenchWidget());
  _benchmark(
    'EasyObservable (unwatch at the beginning)',
    const ObservableCounterUnwatchBenchWidget(),
  );
}

void _benchmark(String description, Widget widget) {
  testWidgets(description, (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    final timer = Stopwatch()..start();
    for (int index = 0; index < 10000; index += 1) {
      await widgetTester.tap(find.byType(Text));
      await widgetTester.pump();
    }
    timer.stop();
    debugPrint('($description) Time taken: ${timer.elapsedMilliseconds}ms');
  });
}
