part of 'p.dart';

class _Device {
  final memUsed = _gs(0);
  final memFree = _gs(0);
  final memUsedByCurrentModel = _gs(0);
}

/// Public methods
extension $Device on _Device {
  FV sync() async {
    if (Platform.isIOS) {
      final result = await P.adapter.call(ToNative.checkMemory);
      if (result == null) return;
      if (kDebugMode) print("💬 $result");
      final memUsed = result[0];
      final memFree = result[1];
      this.memUsed.u(memUsed);
      this.memFree.u(memFree);
      final total = memUsed + memFree;
      if (kDebugMode) print("💬 total: $total");
      if (kDebugMode) print("💬 memUsed (MB): ${memUsed / 1024 / 1024}, memFree (MB): ${memFree / 1024 / 1024}");
    } else {
      final free = SysInfo.getFreePhysicalMemory();
      final total = SysInfo.getTotalPhysicalMemory();
      if (kDebugMode) print("💬 free: $free, total: $total");
    }
  }
}

/// Private methods
extension _$Device on _Device {
  FV _init() async {
    if (Platform.isIOS) {
    } else {
      // totalMemory.value = 0;
      // freeMemory.value = 0;
    }
  }
}
