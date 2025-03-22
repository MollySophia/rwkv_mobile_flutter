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
    } else {
      await HF.wait(200);
      final result = await compute((message) async {
        final free = SysInfo.getFreePhysicalMemory();
        final total = SysInfo.getTotalPhysicalMemory();
        if (kDebugMode) print("💬 free: $free, total: $total");
        return [free, total];
      }, []);
      if (kDebugMode) print("💬 result: $result");
      final memFree = result[0];
      final memTotal = result[1];
      memUsed.u(memTotal - memFree);
      this.memFree.u(memFree);
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
