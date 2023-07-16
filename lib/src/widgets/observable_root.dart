import 'package:flutter/widgets.dart';

import 'inherited_observable_notifier.dart';

class ObservableRoot extends StatelessWidget {
  const ObservableRoot({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InheritedObservableNotifier(
      child: child,
    );
  }
}
