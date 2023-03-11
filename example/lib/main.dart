import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/material.dart';

class _State {
  final counter1 = Observable.mutable(0);
  final counter2 = Observable.mutable(0);
  late final counterSum =
      Observable.computed(() => counter1.value + counter2.value);
  late final counterSumSquared =
      Observable.computed(() => counterSum.value * counterSum.value);

  late final list = Observable.mutable(<int>[]);
}

final state = _State();

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('easy_observable example'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Counter1(),
            _Counter2(),
            _CounterSum(),
            _SumSquared(),
            _List(),
          ],
        ),
      ),
    );
  }
}

class _Counter1 extends StatelessObserverWidget {
  const _Counter1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Counter 1: ${state.counter1.value}'),
        TextButton(
          onPressed: () => state.counter1.value++,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}

class _Counter2 extends StatelessObserverWidget {
  const _Counter2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Counter 2: ${state.counter2.value}'),
        TextButton(
          onPressed: () => state.counter2.value++,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}

class _CounterSum extends StatelessObserverWidget {
  const _CounterSum({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('Counter sum: ${state.counterSum.value}');
  }
}

class _SumSquared extends StatelessObserverWidget {
  const _SumSquared({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('Counter sum squared: ${state.counterSumSquared.value}');
  }
}

class _List extends StatelessObserverWidget {
  const _List({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('List: ${state.list.value}'),
        TextButton(
          onPressed: () => state.list.add(state.list.length),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
