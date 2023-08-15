import 'package:flutter/material.dart';

class ValueNotifierCounterBenchWidget extends StatefulWidget {
  const ValueNotifierCounterBenchWidget({
    super.key,
    required this.observers,
  });

  final int observers;

  @override
  State<ValueNotifierCounterBenchWidget> createState() =>
      _ValueNotifierCounterBenchWidgetState();
}

class _ValueNotifierCounterBenchWidgetState
    extends State<ValueNotifierCounterBenchWidget> {
  final counter = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          TextButton(
            onPressed: () => counter.value++,
            child: ListenableBuilder(
              listenable: counter,
              builder: (context, child) => Text(counter.value.toString()),
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

  final Listenable counter;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: counter,
      builder: (context, child) => const SizedBox.shrink(),
    );
  }
}
