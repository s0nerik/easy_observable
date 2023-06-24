import 'dart:async';

import 'package:easy_observable/easy_observable.dart';
import 'package:easy_provider/easy_provider.dart';
import 'package:flutter/material.dart';

class _State {
  _State(this.pageName);

  final String pageName;

  final counter1 = observable(0);
  final counter2 = observable(0);
  late final counterSum = computed(() {
    // print('$pageName counterSum computed');
    return counter1.value + counter2.value;
  });
}

class TestPage extends StatelessWidget {
  const TestPage({
    Key? key,
    required this.pageName,
  }) : super(key: key);

  final String pageName;

  @override
  Widget build(BuildContext context) {
    return Provider(
      init: (scope) => scope..provide(_State(pageName)),
      child: _Page(pageName: pageName),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    Key? key,
    required this.pageName,
  }) : super(key: key);

  final String pageName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
      ),
      body: _Body(pageName: pageName),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({
    Key? key,
    required this.pageName,
  }) : super(key: key);

  final String pageName;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final StreamSubscription sub;
  late final Timer counter1IncrementTimer;
  late final Timer counter2IncrementTimer;

  @override
  void initState() {
    super.initState();
    final state = context.get<_State>();
    sub = state.counterSum.stream.listen(_onSumValue);
    counter1IncrementTimer =
        Timer.periodic(const Duration(milliseconds: 20), (timer) {
      state.counter1.value++;
    });
    counter2IncrementTimer =
        Timer.periodic(const Duration(milliseconds: 10), (timer) {
      state.counter2.value++;
    });
  }

  void _onSumValue(int value) {
    // print('${widget.pageName} counterSum value: $value');
  }

  @override
  void dispose() {
    sub.cancel();
    counter1IncrementTimer.cancel();
    counter2IncrementTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = int.parse(widget.pageName.replaceAll('Page', ''));
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: _Counter1(),
        ),
        Center(
          child: _Counter2(),
        ),
        Center(
          child: _CounterSum(),
        ),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TestPage(
                  pageName: 'Page${pageIndex + 1}',
                ),
              ),
            ),
            child: const Text('Open next page'),
          ),
        ),
      ],
    );
  }
}

class _Counter1 extends ObserverStatelessWidget {
  _Counter1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.get<_State>();
    return Text('Counter1: ${state.counter1.value}');
  }
}

class _Counter2 extends ObserverStatefulWidget {
  _Counter2({Key? key}) : super(key: key);

  @override
  State<_Counter2> createState() => _Counter2State();
}

class _Counter2State extends State<_Counter2> {
  @override
  Widget build(BuildContext context) {
    final state = context.get<_State>();
    return Text('Counter2: ${state.counter2.value}');
  }
}

class _CounterSum extends ObserverStatelessWidget {
  _CounterSum({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.get<_State>();
    return Text('CounterSum: ${state.counterSum.value}');
  }
}
