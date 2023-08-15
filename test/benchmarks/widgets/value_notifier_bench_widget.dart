import 'package:flutter/widgets.dart';

class ValueNotifierBenchWidget extends StatefulWidget {
  const ValueNotifierBenchWidget({super.key});

  @override
  State<ValueNotifierBenchWidget> createState() =>
      _ValueNotifierBenchWidgetState();
}

class _ValueNotifierBenchWidgetState extends State<ValueNotifierBenchWidget> {
  final counter = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: counter,
      builder: (context, child) => GestureDetector(
        onTap: () => counter.value++,
        child: Text(counter.value.toString()),
      ),
    );
  }
}
