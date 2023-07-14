import 'dart:developer';
import 'dart:isolate';

import 'package:easy_observable/src/observable/computed.dart';
import 'package:easy_observable/src/observable/mutable_observable.dart';
import 'package:easy_observable/src/observable/observable.dart';
import 'package:easy_observable/src/observer_notifier.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service_io.dart';

extension _WatchObservableExtension<T> on Observable<T> {
  T watch(ComputedContext context) {
    assert(context == ComputedContext.instance);
    registerKeyReference(ObservedKey.value);
    return value;
  }
}

/// Must be run via `dart run --enable-vm-service test/gc_test.dart` after
/// removing all Flutter-related lib exports and changing `skip: true` to `skip: false`
void main() async {
  test(
      skip: true,
      'Computed observable eventually stops recomputing after all references to it are gone',
      () async {
    final uri = (await Service.getInfo()).serverUri;
    final vmService = await vmServiceConnectUri(
      '${uri!.toString().replaceAll('http', 'ws')}ws',
    );

    final obs1 = observable('a');
    final obs2 = observable(0);

    var computes = 0;

    Observable? comp = computed((context) {
      computes++;
      return '${obs1.watch(context)}${obs2.watch(context)}';
    });
    expect(comp.value, 'a0');
    expect(computes, 1);

    comp = null;

    // Trigger GC
    final id = Isolate.current.hashCode.toString();
    await Future.delayed(const Duration(milliseconds: 2000));
    vmService.getAllocationProfile(id, gc: true);

    obs1.value = 'b';

    await Future.value();

    expect(computes, 1);
  });
}
