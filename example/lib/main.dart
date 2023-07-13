import 'package:easy_observable/easy_observable.dart';
import 'package:easy_provider/easy_provider.dart';
import 'package:example/test_page.dart';
import 'package:flutter/material.dart';

class _State {
  final counter1 = observable(0);
  final counter2 = observable(0);
  late final counterSum = computed(() => counter1.value + counter2.value);
  late final counterSumSquared =
      computed(() => counterSum.value * counterSum.value);

  late final list = observable(<int>[]);
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const horizontalMargin = 0.0;
    const verticalMargin = 2.0;
    const gap = 2.0;
    return ObservableRoot(
      child: Provider(
        init: (scope) => scope..provide(_State()),
        child: MaterialApp(
          themeMode: ThemeMode.dark,
          theme: ThemeData.dark(),
          darkTheme: ThemeData.dark(),
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
            body: const SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: verticalMargin),
                    Row(
                      children: [
                        Expanded(child: _Counter1()),
                        SizedBox(width: gap),
                        Expanded(child: _Counter2()),
                      ],
                    ),
                    SizedBox(height: gap),
                    Row(
                      children: [
                        Expanded(child: _CounterSum()),
                        SizedBox(width: gap),
                        Expanded(child: _CounterSumSquared()),
                      ],
                    ),
                    SizedBox(height: gap),
                    _Dynamic(),
                    SizedBox(height: gap),
                    _List(),
                    SizedBox(height: verticalMargin),
                  ],
                ),
              ),
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
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              child: Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      alignment: AlignmentDirectional.bottomStart,
                      fit: BoxFit.scaleDown,
                      child: widget.title,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.refresh, size: 16),
                  ),
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
        final counter1 = state.counter1.watch(context);
        return Row(
          children: [
            Text('$counter1'),
            const SizedBox(width: 16),
            const Spacer(),
            TextButton(
              onPressed: () => state.counter1.value++,
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.zero),
              ),
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
        final counter2 = state.counter2.watch(context);
        return Row(
          children: [
            Text('$counter2'),
            const SizedBox(width: 16),
            const Spacer(),
            TextButton(
              onPressed: () => state.counter2.value++,
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.zero),
              ),
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
        final counterSum = state.counterSum.watch(context);
        return Text('$counterSum');
      },
    );
  }
}

class _CounterSumSquared extends StatelessWidget {
  const _CounterSumSquared({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: const Text('Counter sum²'),
      builder: (context) {
        final state = context.get<_State>();
        final counterSumSquared = state.counterSumSquared.watch(context);
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
        context.unwatchObservables();

        final state = context.get<_State>();

        final counter1 = _watchCounter1
            ? state.counter1.watch(context)
            : state.counter1.value;
        final counter2 = _watchCounter2
            ? state.counter2.watch(context)
            : state.counter2.value;
        final counterSum = _watchCounterSum
            ? state.counterSum.watch(context)
            : state.counterSum.value;
        final counterSumSquared = _watchCounterSumSquared
            ? state.counterSumSquared.watch(context)
            : state.counterSumSquared.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const Divider(height: 0),
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
            const Divider(height: 0),
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
            const Divider(height: 0),
            Row(
              children: [
                Text('Counter sum²: $counterSumSquared'),
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
        final list = state.list.watch(context);
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
