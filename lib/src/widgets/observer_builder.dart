import 'package:flutter/widgets.dart';

import '../observable_extensions/watch_ext.dart';

class ObserverBuilder extends StatelessWidget {
  const ObserverBuilder({
    super.key,
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    context.unwatchObservables();
    return builder(context);
  }
}
