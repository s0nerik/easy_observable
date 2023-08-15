import 'package:flutter/widgets.dart';

class SetStateCounterBenchWidget extends StatefulWidget {
  const SetStateCounterBenchWidget({super.key});

  @override
  State<SetStateCounterBenchWidget> createState() =>
      _SetStateCounterBenchWidgetState();
}

class _SetStateCounterBenchWidgetState
    extends State<SetStateCounterBenchWidget> {
  var counter = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => counter++),
      child: Text(counter.toString()),
    );
  }
}
