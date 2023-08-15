import 'package:context_watch/context_watch.dart';
import 'package:easy_observable/src/observable/computed_hot_reload.dart';
import 'package:flutter/widgets.dart';

class ObservableRoot extends StatefulWidget {
  const ObservableRoot({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ObservableRoot> createState() => _ObservableRootState();
}

class _ObservableRootState extends State<ObservableRoot> {
  @override
  void reassemble() {
    assert(performComputedHotReload());
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return ContextWatchRoot(
      child: widget.child,
    );
  }
}
