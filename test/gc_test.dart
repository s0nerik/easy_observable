import 'dart:developer';
import 'dart:isolate';

import 'package:easy_observable/easy_observable.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service_io.dart';

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

    final obs1 = Observable.mutable('a');
    final obs2 = Observable.mutable(0);

    var computes = 0;

    Observable? comp = Observable.computed(() {
      computes++;
      return '${obs1.value}${obs2.value}';
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
