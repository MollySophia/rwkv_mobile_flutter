part of 'p.dart';

class _Debugger {
  late final showFrame = _gs(HF.randomBool(truePercentage: 0.3));
}

/// Public methods
extension $Debugger on _Debugger {}

/// Private methods
extension _$Debugger on _Debugger {
  FV _init() async {
    logTrace();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      showFrame.u(!showFrame.v);
    });
  }
}
