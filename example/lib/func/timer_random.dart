import 'dart:async';

// extension TimerRandom on Timer {
//   static Timer random(Duration Function() duration) {
//     return Timer(duration(), () {});
//   }
// }

// TODO: Use it!
class RandomTimer {
  final Duration Function(int tick) duration;

  RandomTimer(this.duration) {
    _schedule();
  }

  Timer? _timer;
  int _tick = 0;

  void _schedule() {
    _timer = Timer(duration(_tick), () {
      _tick++;
      _schedule();
    });
  }

  void cancel() {
    _timer?.cancel();
  }

  bool get isActive => _timer?.isActive ?? false;

  int get tick => _tick;
}
