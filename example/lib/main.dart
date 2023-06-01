import 'package:easy_observable/easy_observable.dart';
import 'package:easy_provider/easy_provider.dart';
import 'package:example/test_page.dart';
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

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      init: (scope) => scope..provide(_State()),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('easy_observable example'),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TestPage(pageName: 'Page1'),
                    ),
                  ),
                  icon: const Icon(Icons.ac_unit),
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Counter1(key: const ValueKey('counter1')),
              _Counter2(key: const ValueKey('counter2')),
              _CounterSum(key: const ValueKey('counterSum')),
              _SumSquared(key: const ValueKey('counterSumSquared')),
              _List(key: const ValueKey('list')),
            ],
          ),
        ),
      ),
    );
  }
}

class _Counter1 extends ObserverStatelessWidget {
  _Counter1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.get<_State>();
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

class _Counter2 extends ObserverStatelessWidget {
  _Counter2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.get<_State>();
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

class _CounterSum extends ObserverStatelessWidget {
  _CounterSum({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.get<_State>();
    return Text('Counter sum: ${state.counterSum.value}');
  }
}

class _SumSquared extends ObserverStatelessWidget {
  _SumSquared({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.get<_State>();
    return Text('Counter sum squared: ${state.counterSumSquared.value}');
  }
}

class _List extends ObserverStatelessWidget {
  _List({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.get<_State>();
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
