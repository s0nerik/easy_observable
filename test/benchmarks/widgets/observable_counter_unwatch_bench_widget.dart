import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/widgets.dart';

class ObservableCounterUnwatchBenchWidget extends StatefulWidget {
  const ObservableCounterUnwatchBenchWidget({super.key});

  @override
  State<ObservableCounterUnwatchBenchWidget> createState() =>
      _ObservableCounterUnwatchBenchWidgetState();
}

class _ObservableCounterUnwatchBenchWidgetState
    extends State<ObservableCounterUnwatchBenchWidget> {
  final counter = observable(0);

  @override
  Widget build(BuildContext context) {
    context.unwatchObservables();
    return GestureDetector(
      onTap: () => counter.value++,
      child: Text(counter.watch(context).toString()),
    );
  }
}
