import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meta/meta.dart';

import 'widgets/observable_counter_bench_widget.dart';
import 'widgets/value_notifier_counter_bench_widget.dart';

Future<void> main() async {
  assert(false); // fail in debug mode

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  _benchmark(
    'ValueNotifier',
    const ValueNotifierCounterBenchWidget(observers: 10000),
  );
  _benchmark(
    'EasyObservable',
    const ObservableCounterBenchWidget(observers: 10000),
  );
}

@isTest
void _benchmark(String description, Widget widget) {
  testWidgets(description, (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    final timer = Stopwatch()..start();
    for (int i = 0; i < 200; i++) {
      await widgetTester.tap(find.byType(TextButton));
      await widgetTester.pump();
    }
    timer.stop();

    // ignore: avoid_print
    print('($description) Time taken: ${timer.elapsedMilliseconds}ms');
  });
}
