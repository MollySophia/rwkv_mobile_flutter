part of 'p.dart';

class _Device {
  final memUsed = qs(0);
  final memFree = qs(0);
  final memUsedByCurrentModel = qs(0);
}

/// Public methods
extension $Device on _Device {
  FV sync() async {
    if (Platform.isIOS) {
      final result = await P.adapter.call(ToNative.checkMemory);
      if (result == null) return;
      qqq("$result");
      final memUsed = result[0];
      final memFree = result[1];
      this.memUsed.q = memUsed;
      this.memFree.q = memFree;
    } else {
      await HF.wait(200);
      final result = await compute((message) async {
        final free = SysInfo.getFreePhysicalMemory();
        final total = SysInfo.getTotalPhysicalMemory();
        qqq("free: $free, total: $total");
        return [free, total];
      }, []);
      qqq("result: $result");
      final memFree = result[0];
      final memTotal = result[1];
      memUsed.q = memTotal - memFree;
      this.memFree.q = memFree;
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
