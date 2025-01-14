part of 'p.dart';

// 黑白棋（英语：Reversi），又称翻转棋、苹果棋或奥赛罗棋（Othello），是一种双人对弈的棋类游戏。据日本棋类游戏专家长谷川五郎在2005年的统计数据，在日本，黑白棋爱好者的数目约为六千万人（日本将棋爱好者约一千五百万人；围棋爱好者约五百万人；国际象棋爱好者约三百万人）[1]。

enum CellType {
  empty,
  black,
  white,
  available,
}

class _Othello {
  late final state = _gs(List.generate(8, (_) => List.filled(8, CellType.empty)));
}

/// Public methods
extension $Othello on _Othello {
  void start() {
    final state = this.state.v;
    state[3][3] = CellType.black;
    state[3][4] = CellType.white;
    state[4][3] = CellType.white;
    state[4][4] = CellType.black;
    this.state.u([...state]);
  }

}

/// Private methods
extension _$ on _Othello {
  FV _init() async {}
}
