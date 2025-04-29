part of 'p.dart';

class _Debugger {
  late final showFrame = qs(HF.randomBool(truePercentage: .3));
}

/// Public methods
extension $Debugger on _Debugger {}

/// Private methods
extension _$Debugger on _Debugger {
  FV _init() async {
    qq;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      showFrame.q = !showFrame.q;
    });
  }
}
