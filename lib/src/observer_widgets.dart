import 'dart:async';

import 'package:easy_observable/easy_observable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class ObserverBuilder extends ObserverStatefulWidget {
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

abstract class ObserverStatelessWidget extends StatelessWidget {
  const ObserverStatelessWidget({Key? key}) : super(key: key);

  @override
  StatelessElement createElement() => ObserverStatelessElement(this);
}

class ObserverStatelessElement extends StatelessElement
    with ObserverElementMixin {
  ObserverStatelessElement(super.widget);
}

abstract class ObserverStatefulWidget extends StatefulWidget {
  const ObserverStatefulWidget({Key? key}) : super(key: key);

  @override
  StatefulElement createElement() => ObserverStatefulElement(this);
}

class ObserverStatefulElement extends StatefulElement
    with ObserverElementMixin {
  ObserverStatefulElement(super.widget);
}

mixin ObserverElementMixin on ComponentElement {
  late final Widget Function() _builder =
      kDebugMode ? _buildWithTypeErrorDebugging : super.build;

  Observable<Widget>? _computedWidget;
  StreamSubscription? _subscription;

  bool _initialBuild = true;

  @override
  void unmount() {
    _subscription?.cancel();
    super.unmount();
  }

  Widget _buildWithTypeErrorDebugging() {
    try {
      return super.build();
    } on TypeError catch (e, stackTrace) {
      final errorText = e.toString();
      if (errorText.contains('_ComputedObservable') &&
          errorText.contains('is not a subtype of type') &&
          errorText.contains('MutableObservable')) {
        FlutterError.onError?.call(FlutterErrorDetails(
          exception: e,
          stack: stackTrace,
          library: 'easy_observable',
          context: ErrorDescription('Error in ObserverWidget'),
        ));
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 20,
            maxWidth: MediaQuery.of(this).size.width,
          ),
          child: ErrorWidget.withDetails(message: 'Hot restart is needed!'),
        );
      }
      rethrow;
    }
  }

  bool get _shouldWaitForNextFrame {
    final schedulerPhase = SchedulerBinding.instance.schedulerPhase;
    return schedulerPhase != SchedulerPhase.idle &&
        schedulerPhase != SchedulerPhase.postFrameCallbacks;
  }

  Widget _build() {
    if (!_initialBuild && (dirty || _shouldWaitForNextFrame)) {
      return _computedWidget!.value;
    }
    if (_initialBuild) {
      _initialBuild = false;
    }
    return _builder();
  }

  void _markNeedsBuildNextFrame() async {
    if (_shouldWaitForNextFrame) {
      await SchedulerBinding.instance.endOfFrame;
    }
    if (!mounted || dirty) return;

    markNeedsBuild();
  }

  @override
  Widget build() {
    _computedWidget ??=
        Observable.computed(_build, debugLabel: widget.toString());
    _subscription ??=
        _computedWidget!.stream.listen((_) => _markNeedsBuildNextFrame());
    return _computedWidget!.value;
  }
}
