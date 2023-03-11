import 'dart:async';

import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/widgets.dart';

class ObserverBuilder extends StatefulWidget {
  const ObserverBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final WidgetBuilder builder;

  @override
  State<ObserverBuilder> createState() => _ObserverBuilderState();
}

class _ObserverBuilderState extends State<ObserverBuilder> {
  StreamSubscription? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _subscription?.cancel();
    final computedWidget = Observable.computed(() => widget.builder(context));
    _subscription = computedWidget.stream.listen((_) => setState(() {}));
    return computedWidget.value;
  }
}
