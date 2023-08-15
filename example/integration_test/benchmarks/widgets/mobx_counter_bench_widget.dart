import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

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
  final counter = Observable(0);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Center(
          child: TextButton(
            onPressed: () => counter.value++,
            child: Observer(
              builder: (context) => Text(counter.value.toString()),
            ),
          ),
        ),
        ...List.filled(widget.observers, _Observer(counter: counter)),
      ],
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
    counter.value;
    return const SizedBox.shrink();
  }
}
