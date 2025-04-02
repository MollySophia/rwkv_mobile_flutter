// ignore: unused_import
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/widgets/app_info.dart';

class Menu extends ConsumerWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Co(
      m: MAA.center,
      children: [
        AppInfo(),
      ],
    );
  }
}
