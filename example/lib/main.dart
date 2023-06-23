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
    return InheritedObservableNotifier(
      child: Provider(
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
            body: ListView(
              children: const [
                SizedBox(height: 24),
                _Counter1(),
                SizedBox(height: 16),
                _Counter2(),
                SizedBox(height: 16),
                _CounterSum(),
                SizedBox(height: 16),
                _SumSquared(),
                SizedBox(height: 16),
                _Dynamic(),
                SizedBox(height: 16),
                _List(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatefulWidget {
  const _Card({
    Key? key,
    required this.title,
    required this.builder,
  }) : super(key: key);

  final Widget title;
  final WidgetBuilder builder;

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 16),
              child: Row(
                children: [
                  widget.title,
                  const Spacer(),
                  const Icon(Icons.refresh, size: 20),
                  const SizedBox(width: 4),
                  Text('$_buildCount'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            widget.builder(context),
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
    return _Card(
      title: const Text('Counter 1'),
      builder: (context) {
        final state = context.get<_State>();
        final counter1 = context.watch(state.counter1);
        return Row(
          children: [
            Text('$counter1'),
            const SizedBox(width: 16),
            const Spacer(),
            TextButton(
              onPressed: () => state.counter1.value++,
              child: const Text('Increment'),
            ),
          ],
        );
      },
    );
  }
}

class _Counter2 extends StatelessWidget {
  const _Counter2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: const Text('Counter 2'),
      builder: (context) {
        final state = context.get<_State>();
        final counter2 = context.watch(state.counter2);
        return Row(
          children: [
            Text('$counter2'),
            const SizedBox(width: 16),
            const Spacer(),
            TextButton(
              onPressed: () => state.counter2.value++,
              child: const Text('Increment'),
            ),
          ],
        );
      },
    );
  }
}

class _CounterSum extends StatelessWidget {
  const _CounterSum({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: const Text('Counter sum'),
      builder: (context) {
        final state = context.get<_State>();
        final counterSum = context.watch(state.counterSum);
        return Text('$counterSum');
      },
    );
  }
}

class _SumSquared extends StatelessWidget {
  const _SumSquared({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: const Text('Counter sum squared'),
      builder: (context) {
        final state = context.get<_State>();
        final counterSumSquared = context.watch(state.counterSumSquared);
        return Text('$counterSumSquared');
      },
    );
  }
}

class _Dynamic extends StatefulWidget {
  const _Dynamic({Key? key}) : super(key: key);

  @override
  State<_Dynamic> createState() => _DynamicState();
}

class _DynamicState extends State<_Dynamic> {
  var _watchCounter1 = false;
  var _watchCounter2 = false;
  var _watchCounterSum = false;
  var _watchCounterSumSquared = false;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: const Text('Dynamic set of properties'),
      builder: (context) {
        context.unwatch();

        final state = context.get<_State>();
        final counter1 = _watchCounter1
            ? context.watch(state.counter1)
            : state.counter1.value;
        final counter2 = _watchCounter2
            ? context.watch(state.counter2)
            : state.counter2.value;
        final counterSum = _watchCounterSum
            ? context.watch(state.counterSum)
            : state.counterSum.value;
        final counterSumSquared = _watchCounterSumSquared
            ? context.watch(state.counterSumSquared)
            : state.counterSumSquared.value;

        return Column(
          children: [
            Row(
              children: [
                Text('Counter 1: $counter1'),
                const SizedBox(width: 8),
                const Spacer(),
                const Text('Watch?'),
                Checkbox(
                  value: _watchCounter1,
                  onChanged: (value) => setState(() => _watchCounter1 = value!),
                ),
              ],
            ),
            Row(
              children: [
                Text('Counter 2: $counter2'),
                const SizedBox(width: 8),
                const Spacer(),
                const Text('Watch?'),
                Checkbox(
                  value: _watchCounter2,
                  onChanged: (value) => setState(() => _watchCounter2 = value!),
                ),
              ],
            ),
            Row(
              children: [
                Text('Counter sum: $counterSum'),
                const SizedBox(width: 8),
                const Spacer(),
                const Text('Watch?'),
                Checkbox(
                  value: _watchCounterSum,
                  onChanged: (value) =>
                      setState(() => _watchCounterSum = value!),
                ),
              ],
            ),
            Row(
              children: [
                Text('Counter sum squared: $counterSumSquared'),
                const SizedBox(width: 8),
                const Spacer(),
                const Text('Watch?'),
                Checkbox(
                  value: _watchCounterSumSquared,
                  onChanged: (value) =>
                      setState(() => _watchCounterSumSquared = value!),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _List extends StatelessWidget {
  const _List({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: const Text('List'),
      builder: (context) {
        final state = context.get<_State>();
        final list = context.watch(state.list);
        return Row(
          children: [
            Expanded(
              child: Text('$list'),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () => state.list.add(state.list.length),
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () => state.list.removeLast(),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
