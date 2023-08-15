import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counter = StateProvider((ref) => 0);

class RiverpodCounterBenchWidget extends ConsumerStatefulWidget {
  const RiverpodCounterBenchWidget({
    Key? key,
    required this.observers,
  }) : super(key: key);

  final int observers;

  @override
  RiverpodCounterBenchWidgetState createState() =>
      RiverpodCounterBenchWidgetState();
}

class RiverpodCounterBenchWidgetState
    extends ConsumerState<RiverpodCounterBenchWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Center(
          child: TextButton(
            onPressed: () => ref.read(counter.notifier).state++,
            child: Consumer(
              builder: (context, ref, child) => Text(
                ref.watch(counter).toString(),
              ),
            ),
          ),
        ),
        ...List.filled(widget.observers, const _Observer()),
      ],
    );
  }
}

class _Observer extends ConsumerWidget {
  const _Observer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(counter);
    return const SizedBox.shrink();
  }
}
