// ignore: unused_import

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';

class PerformanceInfo extends ConsumerWidget {
  const PerformanceInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefillSpeed = ref.watch(P.rwkv.prefillSpeed);
    final decodeSpeed = ref.watch(P.rwkv.decodeSpeed);
    final kB = ref.watch(P.app.qb);
    return Co(
      c: CAA.start,
      m: MAA.center,
      children: [
        T("Prefill: ${prefillSpeed.toStringAsFixed(1)} t/s", s: TS(c: kB.q(.6), s: 10)),
        T("Decode: ${decodeSpeed.toStringAsFixed(1)} t/s", s: TS(c: kB.q(.6), s: 10)),
      ],
    );
  }
}
