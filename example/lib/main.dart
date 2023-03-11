import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/material.dart';

class _State {
  final counter1 = Observable.mutable(0);
  final counter2 = Observable.mutable(0);
  late final sum = Observable.computed(() => counter1.value + counter2.value);
  late final sumSquared = Observable.computed(() => sum.value * sum.value);
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
          children: const [
            _Counter1(),
            _Counter2(),
            _Sum(),
            _SumSquared(),
          ],
        ),
      ),
    );
  }
}

class _Counter1 extends StatelessWidget {
  const _Counter1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ObserverBuilder(
      builder: (context) => Row(
        children: [
          Text('Counter 1: ${state.counter1.value}'),
          TextButton(
            onPressed: () => state.counter1.value++,
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}

class _Counter2 extends StatelessWidget {
  const _Counter2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ObserverBuilder(
      builder: (context) => Row(
        children: [
          Text('Counter 2: ${state.counter2.value}'),
          TextButton(
            onPressed: () => state.counter2.value++,
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}

class _Sum extends StatelessWidget {
  const _Sum({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ObserverBuilder(
      builder: (context) => Text('Sum: ${state.sum.value}'),
    );
  }
}

class _SumSquared extends StatelessWidget {
  const _SumSquared({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ObserverBuilder(
      builder: (context) => Text('Sum squared: ${state.sumSquared.value}'),
    );
  }
}
