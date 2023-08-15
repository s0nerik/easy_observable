import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/widgets.dart';

class ObservableCounterBenchWidget extends StatefulWidget {
  const ObservableCounterBenchWidget({super.key});

  @override
  State<ObservableCounterBenchWidget> createState() =>
      _ObservableCounterBenchWidgetState();
}

class _ObservableCounterBenchWidgetState
    extends State<ObservableCounterBenchWidget> {
  final counter = observable(0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => counter.value++,
      child: Text(counter.watch(context).toString()),
    );
  }
}
