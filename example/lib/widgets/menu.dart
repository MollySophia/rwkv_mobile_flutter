// ignore: unused_import
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/config.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/app_info.dart';
import 'package:zone/widgets/settings.dart';

class Menu extends ConsumerWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kW = ref.watch(P.app.qw);
    return Co(
      m: MAA.center,
      children: [
        Exp(child: Settings()),
      ],
    );
  }
}

// ignore: unused_element
// TODO: Use this in the future
class _BottomInfo extends ConsumerWidget {
  const _BottomInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingBottom = ref.watch(P.app.quantizedIntPaddingBottom);
    final version = ref.watch(P.app.version);
    final buildNumber = ref.watch(P.app.buildNumber);
    final demoType = ref.watch(P.app.demoType);
    final iconPath = "assets/img/${demoType.name}/icon.png";

    final iconWidget = SB(
      width: 48,
      height: 48,
      child: ClipRRect(
        borderRadius: 8.r,
        child: Image.asset(iconPath),
      ),
    );

    return Co(
      children: [
        12.h,
        Ro(
          children: [
            12.w,
            iconWidget,
            8.w,
            Exp(
              child: Co(
                c: CAA.stretch,
                children: [
                  const T(
                    Config.appTitle,
                    s: TS(s: 20),
                  ),
                  Ro(
                    // m: MAA.center,
                    children: [
                      T(
                        version,
                        s: const TS(s: 12),
                      ),
                      T(
                        " ($buildNumber)",
                        s: const TS(s: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            8.w,
            IconButton(
              onPressed: () {
                AppInfo.show(context);
              },
              icon: const Icon(Icons.info_outline),
            ),
            8.w,
          ],
        ),
        12.h,
        paddingBottom.h,
      ],
    );
  }
}
