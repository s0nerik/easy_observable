import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/material.dart';

class ObservableCounterBenchWidget extends StatefulWidget {
  const ObservableCounterBenchWidget({
    super.key,
    required this.observers,
  });

  final int observers;

  @override
  State<ObservableCounterBenchWidget> createState() =>
      _ObservableCounterBenchWidgetState();
}

class _ObservableCounterBenchWidgetState
    extends State<ObservableCounterBenchWidget> {
  final counter = observable(0);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          TextButton(
            onPressed: () => counter.value++,
            child: ObserverBuilder(
              builder: (context) => Text(counter.watch(context).toString()),
            ),
          ),
          ...List.filled(widget.observers, _Observer(counter: counter)),
        ],
      ),
    );
  }
}

class _Observer extends StatelessWidget {
  const _Observer({
    super.key,
    required this.counter,
  });

  final Observable counter;

  @override
  Widget build(BuildContext context) {
    context.unwatchObservables();
    counter.watch(context);
    return const SizedBox.shrink();
  }
}
