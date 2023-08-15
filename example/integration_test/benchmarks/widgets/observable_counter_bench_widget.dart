import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/material.dart';

class ObservableCounterBenchWidget extends StatefulWidget {
  const ObservableCounterBenchWidget({
    super.key,
    required this.observers,
    required this.unwatchInBuild,
  });

  final int observers;
  final bool unwatchInBuild;

  @override
  State<ObservableCounterBenchWidget> createState() =>
      _ObservableCounterBenchWidgetState();
}

class _ObservableCounterBenchWidgetState
    extends State<ObservableCounterBenchWidget> {
  final counter = observable(0);

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
            child: widget.unwatchInBuild
                ? ObserverBuilder(
                    builder: (context) =>
                        Text(counter.watch(context).toString()),
                  )
                : Builder(
                    builder: (context) =>
                        Text(counter.watch(context).toString()),
                  ),
          ),
        ),
        ...List.filled(
          widget.observers,
          widget.unwatchInBuild
              ? _UnwatchingObserver(counter: counter)
              : _Observer(counter: counter),
        ),
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
    counter.watch(context);
    return const SizedBox.shrink();
  }
}

class _UnwatchingObserver extends StatelessWidget {
  const _UnwatchingObserver({
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
