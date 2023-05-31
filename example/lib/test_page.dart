import 'dart:async';

import 'package:easy_observable/easy_observable.dart';
import 'package:easy_provider/easy_provider.dart';
import 'package:flutter/material.dart';

MutableObservable<T> observable<T>(T value) => Observable.mutable(value);
Observable<T> computed<T>(T Function() value) => Observable.computed(value);

class _State {
  _State(this.pageName);

  final String pageName;

  final counter1 = observable(0);
  final counter2 = observable(0);
  late final counterSum = computed(() {
    print('$pageName counterSum computed');
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

class _Body extends ObserverStatefulWidget {
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
  late final Timer timer;

  @override
  void initState() {
    super.initState();
    final state = context.get<_State>();
    sub = state.counterSum.stream.listen(_onSumValue);
    timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      state.counter1.value++;
      state.counter2.value++;
    });
  }

  void _onSumValue(int value) {
    print('${widget.pageName} counterSum value: $value');
  }

  @override
  void dispose() {
    sub.cancel();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = int.parse(widget.pageName.replaceAll('Page', ''));
    final state = context.get<_State>();
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text('Counter sum: ${state.counterSum.value}'),
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
            child: const Text('Move to next page'),
          ),
        ),
      ],
    );
  }
}
