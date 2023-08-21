import 'package:context_watch/context_watch.dart';
import 'package:flutter/material.dart';

class ValueNotifierWatchCounterBenchWidget extends StatefulWidget {
  const ValueNotifierWatchCounterBenchWidget({
    super.key,
    required this.observers,
    required this.unwatchInBuild,
  });

  final int observers;
  final bool unwatchInBuild;

  @override
  State<ValueNotifierWatchCounterBenchWidget> createState() =>
      _ValueNotifierWatchCounterBenchWidgetState();
}

class _ValueNotifierWatchCounterBenchWidgetState
    extends State<ValueNotifierWatchCounterBenchWidget> {
  final counter = ValueNotifier(0);

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
                ? Builder(
                    builder: (context) {
                      context.unwatch();
                      return Text(counter.watch(context).toString());
                    },
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

  final Listenable counter;

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

  final Listenable counter;

  @override
  Widget build(BuildContext context) {
    context.unwatch();
    counter.watch(context);
    return const SizedBox.shrink();
  }
}
