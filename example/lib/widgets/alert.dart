import 'package:chat/state/p.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';

class Alert {
  static Widget deploy() {
    HF.wait(0).then((value) {
      _Alert.hasBeenDeployed.u(true);
    });
    return const IgnorePointer(child: _Alert());
  }

  static FV _show(String message, int id, int notifyStatus) async {
    final hasBeenDeployed = _Alert.hasBeenDeployed.v;
    if (!hasBeenDeployed) throw "😡😡😡 Alert has not been deployed";

    //  添加
    final c = _Alert.alert.v;

    final containMessage = c.firstWhereOrNull((e) => e.message == message) != null;
    if (containMessage) return;

    final nC1 = [...c, _AlertItem(id, 0, message, notifyStatus)];
    _Alert.alert.u(nC1);

    //  展示
    await HF.wait(10);
    final c1 = _Alert.alert.v;
    final idx1 = c1.indexWhere((e) => e.id == id);
    c1[idx1] = _AlertItem(id, 1, message, notifyStatus);
    final nC2 = [...c1];
    nC2.sort((l, r) => l.id - r.id);
    _Alert.alert.u(nC2);

    //  收起
    await HF.wait(2000);
    final c2 = _Alert.alert.v;
    final idx2 = c2.indexWhere((e) => e.id == id);
    c2[idx2] = _AlertItem(id, 2, message, notifyStatus);
    final nC3 = [...c2];
    nC3.sort((l, r) => l.id - r.id);
    _Alert.alert.u(nC3);

    //  回收内存
    await HF.wait(250);
    final c3 = _Alert.alert.v;
    final idx3 = c3.indexWhere((e) => e.id == id);
    c3.removeAt(idx3);
    final nC4 = [...c3];
    nC4.sort((l, r) => l.id - r.id);
    _Alert.alert.u(nC4);
  }

  static FV success(String msg) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    const notifyStatus = 0;
    return await _show(msg, id, notifyStatus);
  }

  static FV warning(String msg) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    const notifyStatus = 1;
    return await _show(msg, id, notifyStatus);
  }

  static FV error(String msg) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    const notifyStatus = 2;
    return await _show(msg, id, notifyStatus);
  }
}

class _AlertItem {
  final int id;
  final int displayStatus;
  final int notifyStatus;
  final String message;

  _AlertItem(this.id, this.displayStatus, this.message, this.notifyStatus);
}

class _Alert extends ConsumerWidget {
  static final alert = StateProvider((ref) => List<_AlertItem>.empty(growable: true));
  static final hasBeenDeployed = StateProvider((ref) => false);

  const _Alert();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(alert);

    final screenWidth = ref.watch(P.app.screenWidth);
    final paddingTop = ref.watch(P.app.paddingTop);

    final light = ref.watch(P.app.light);
    final top = paddingTop + 25;
    return Material(
      color: kC,
      child: Stack(
        children: items.indexMap((index, value) {
          final item = items[index];
          final message = item.message;
          final notifyStatus = item.notifyStatus;
          Color c;
          IconData iconData;
          switch (notifyStatus) {
            case 1:
              c = Colors.yellow[800]!;
              iconData = Icons.info_outline_rounded;
              break;
            case 2:
              c = kCR;
              iconData = Icons.error_outline;
              break;
            default:
              c = kCG;
              iconData = Icons.check_circle_outline_rounded;
              break;
          }

          return AnimatedPositioned(
            duration: 250.ms,
            curve: item.displayStatus == 1 ? Curves.easeOutBack : Curves.easeInBack,
            top: item.displayStatus == 1 ? top : 0,
            child: AnimatedOpacity(
              duration: 250.ms,
              curve: item.displayStatus == 1 ? Curves.easeOutBack : Curves.easeInBack,
              opacity: item.displayStatus == 1 ? 1 : 0,
              child: C(
                margin: const EI.o(l: 24, r: 24),
                width: screenWidth - 24 - 24,
                decoration: const BD(color: kC),
                child: Ro(
                  m: MAA.center,
                  children: [
                    C(
                      decoration: BD(
                        color: light ? kW.wo(1) : kB.wo(1),
                        borderRadius: 12.r,
                        border: Border.all(color: c.wo(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: kB.wo(0.1),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      padding: const EI.s(h: 8, v: 8),
                      child: Ro(
                        m: MAA.center,
                        c: CAA.center,
                        children: [
                          Icon(iconData, color: c),
                          8.w,
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: screenWidth - 100),
                            child: T(
                              message,
                              s: TS(
                                c: c,
                                s: 16,
                              ),
                              maxLines: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
