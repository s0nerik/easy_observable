import 'dart:async';

import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/widgets.dart';

class ObserverBuilder extends StatefulObserverWidget {
  const ObserverBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final WidgetBuilder builder;

  @override
  State<ObserverBuilder> createState() => _ObserverBuilderState();
}

class _ObserverBuilderState extends State<ObserverBuilder> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

abstract class StatelessObserverWidget extends StatelessWidget {
  const StatelessObserverWidget({Key? key}) : super(key: key);

  @override
  StatelessElement createElement() => StatelessObserverElement(this);
}

class StatelessObserverElement extends StatelessElement
    with ObserverElementMixin {
  StatelessObserverElement(super.widget);
}

abstract class StatefulObserverWidget extends StatefulWidget {
  const StatefulObserverWidget({Key? key}) : super(key: key);

  @override
  StatefulElement createElement() => StatefulObserverElement(this);
}

class StatefulObserverElement extends StatefulElement
    with ObserverElementMixin {
  StatefulObserverElement(super.widget);
}

mixin ObserverElementMixin on ComponentElement {
  StreamSubscription? _subscription;

  @override
  void unmount() {
    _subscription?.cancel();
    super.unmount();
  }

  @override
  Widget build() {
    _subscription?.cancel();
    final computedWidget = Observable.computed(super.build);
    _subscription = computedWidget.stream.listen((_) => markNeedsBuild());
    return computedWidget.value;
  }
}
