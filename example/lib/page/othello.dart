import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/cell_type.dart';
import 'package:zone/state/p.dart';

class PageOthello extends ConsumerWidget {
  const PageOthello({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingTop = ref.watch(P.app.paddingTop);
    final usePortrait = ref.watch(P.othello.usePortrait);
    final playerShouldAtSameColumnWithSettings = ref.watch(P.othello.playerShouldAtSameColumnWithSettings);
    final settingsAndPlayersShouldAtDifferentColumnIsHorizontal = ref.watch(P.othello.settingsAndPlayersShouldAtDifferentColumnIsHorizontal);
    final screenWidth = ref.watch(P.app.screenWidth);
    final paddingRight = ref.watch(P.app.paddingRight);
    return Scaffold(
      backgroundColor: kW,
      body: usePortrait
          ? Co(
              children: [
                paddingTop.h,
                12.h,
                const _Title(),
                12.h,
                const _Score(),
                4.h,
                Ro(
                  c: CAA.center,
                  children: [
                    Exp(
                      child: Co(
                        children: [
                          const _ModelSettings(),
                          if (playerShouldAtSameColumnWithSettings) const _Players(),
                        ],
                      ),
                    ),
                    const _Othello(),
                    8.w,
                  ],
                ),
                if (!playerShouldAtSameColumnWithSettings) const _Players(),
                const Exp(child: _Console()),
              ],
            )
          : Ro(
              children: [
                const Exp(child: _Console()),
                Co(
                  c: CAA.center,
                  children: [
                    const _Title(),
                    4.h,
                    const _Score(),
                    4.h,
                    Ro(
                      children: [
                        Co(
                          children: [
                            const _Othello(),
                            if (!settingsAndPlayersShouldAtDifferentColumnIsHorizontal) const _ModelSettings(),
                            if (!settingsAndPlayersShouldAtDifferentColumnIsHorizontal) const _Players(),
                          ],
                        ),
                        if (settingsAndPlayersShouldAtDifferentColumnIsHorizontal)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth * 0.33,
                            ),
                            child: const Co(
                              c: CAA.center,
                              m: MAA.center,
                              children: [
                                _ModelSettings(),
                                _Players(),
                              ],
                            ),
                          ),
                      ],
                    )
                  ],
                ),
                paddingRight.w,
              ],
            ),
    );
  }
}

class _Title extends ConsumerWidget {
  const _Title();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(P.app.version);
    final buildNumber = ref.watch(P.app.buildNumber);
    final usePortrait = ref.watch(P.othello.usePortrait);
    return Ro(
      m: MAA.center,
      children: [
        12.w,
        T("$version($buildNumber)", s: TS(c: kB.wo(0.0), s: 10)),
        if (usePortrait) const Spacer(),
        const T("RWKV Othello", s: TS(c: kB, s: 20, w: FW.w700)),
        if (usePortrait) const Spacer(),
        if (!usePortrait) 32.w,
        T("$version($buildNumber)", s: TS(c: kB.wo(0.5), s: 10)),
        if (!usePortrait) 32.w,
        12.w,
      ],
    );
  }
}

class _ModelSettings extends ConsumerWidget {
  const _ModelSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usePortrait = ref.watch(P.othello.usePortrait);
    final searchDepth = ref.watch(P.othello.searchDepth);
    final searchBreadth = ref.watch(P.othello.searchBreadth);

    final searchDepthAddAvailable = searchDepth < 5;
    final searchDepthRemoveAvailable = searchDepth > 1;
    final searchBreadthAddAvailable = searchBreadth < 5;
    final searchBreadthRemoveAvailable = searchBreadth > 1;

    final searchDepthControls = Ro(mainAxisSize: MainAxisSize.min, m: MAA.center, children: [
      SB(
        width: 32,
        height: 32,
        child: IconButton(
          padding: EI.zero,
          onPressed: searchDepthRemoveAvailable
              ? () {
                  P.othello.searchDepth.ua(-1);
                }
              : null,
          icon: const Icon(Icons.remove),
          iconSize: 14,
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(16, 16)),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
          ),
        ),
      ),
      T(searchDepth.toString()),
      SizedBox(
        width: 32,
        height: 32,
        child: IconButton(
          onPressed: searchDepthAddAvailable
              ? () {
                  P.othello.searchDepth.ua(1);
                }
              : null,
          icon: const Icon(Icons.add),
          iconSize: 14,
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(16, 16)),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
          ),
        ),
      ),
    ]);

    final searchBreadthControls = Ro(mainAxisSize: MainAxisSize.min, m: MAA.center, children: [
      SizedBox(
        width: 32,
        height: 32,
        child: IconButton(
          onPressed: searchBreadthRemoveAvailable
              ? () {
                  P.othello.searchBreadth.ua(-1);
                }
              : null,
          icon: const Icon(Icons.remove),
          iconSize: 14,
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(16, 16)),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
          ),
        ),
      ),
      T(searchBreadth.toString()),
      SizedBox(
        width: 32,
        height: 32,
        child: IconButton(
          onPressed: searchBreadthAddAvailable
              ? () {
                  P.othello.searchBreadth.ua(1);
                }
              : null,
          icon: const Icon(Icons.add),
          iconSize: 14,
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(16, 16)),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
          ),
        ),
      ),
    ]);

    return Material(
      color: kB.wo(0.0),
      textStyle: const TS(ff: "monospace", c: kB, s: 10),
      child: C(
        padding: const EI.a(4),
        margin: const EI.a(4),
        decoration: BD(
          color: kB.wo(0.0),
          borderRadius: 4.r,
          border: Border.all(color: kB.wo(0.5), width: 0.5),
        ),
        child: Co(
          c: CAA.start,
          m: MAA.center,
          children: [
            const T(
              "Model Settings",
              s: TS(w: FW.w700),
            ),
            8.h,
            T("In-context search will be activated when both breadth and depth are greater than 2", s: TS(c: kB.wo(0.5), s: 10)),
            8.h,
            usePortrait
                ? Co(
                    c: CAA.stretch,
                    children: [
                      const T("Search Depth", textAlign: TextAlign.center),
                      searchDepthControls,
                      4.h,
                      const T("Search Breadth", textAlign: TextAlign.center),
                      searchBreadthControls,
                    ],
                  )
                : Wrap(
                    children: [
                      Row(
                        children: [
                          const T("Search Depth", textAlign: TextAlign.center),
                          searchDepthControls,
                        ],
                      ),
                      Row(
                        children: [
                          const T("Search Breadth", textAlign: TextAlign.center),
                          searchBreadthControls,
                        ],
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _Players extends ConsumerWidget {
  const _Players();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blackIsAI = ref.watch(P.othello.blackIsAI);
    final whiteIsAI = ref.watch(P.othello.whiteIsAI);
    final playerShouldAtSameColumnWithSettings = ref.watch(P.othello.playerShouldAtSameColumnWithSettings);
    final settingsAndPlayersShouldAtDifferentColumnIsHorizontal = ref.watch(P.othello.settingsAndPlayersShouldAtDifferentColumnIsHorizontal);
    final usePortrait = ref.watch(P.othello.usePortrait);

    final blackOptions = C(
      decoration: BD(color: kC, borderRadius: 4.r, border: Border.all(color: kB.wo(0.5), width: 0.5)),
      padding: const EI.o(l: 8, r: 8, t: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const T("Black:", textAlign: TextAlign.center, s: TS(w: FW.w700)),
          Wrap(
            children: [
              Ro(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio(
                    value: false,
                    groupValue: blackIsAI,
                    onChanged: (value) {
                      P.othello.blackIsAI.u(false);
                    },
                  ),
                  const T("Human"),
                ],
              ),
              Ro(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio(
                    value: true,
                    groupValue: blackIsAI,
                    onChanged: (value) {
                      P.othello.blackIsAI.u(true);
                    },
                  ),
                  const T("AI"),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final whiteOptions = C(
      decoration: BD(color: kC, borderRadius: 4.r, border: Border.all(color: kB.wo(0.5), width: 0.5)),
      padding: const EI.o(l: 8, r: 8, t: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const T("White:", textAlign: TextAlign.center, s: TS(w: FW.w700)),
          Wrap(
            children: [
              Ro(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio(
                    value: false,
                    groupValue: whiteIsAI,
                    onChanged: (value) {
                      P.othello.whiteIsAI.u(false);
                    },
                  ),
                  const T("Human"),
                ],
              ),
              Ro(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio(
                    value: true,
                    groupValue: whiteIsAI,
                    onChanged: (value) {
                      P.othello.whiteIsAI.u(true);
                    },
                  ),
                  const T("AI"),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return Material(
      color: kB.wo(0.0),
      textStyle: const TS(ff: "monospace", c: kB, s: 10),
      child: C(
        margin: const EI.a(4),
        padding: const EI.a(4),
        decoration: BD(
          color: kB.wo(0.0),
          borderRadius: 4.r,
          border: Border.all(color: kB.wo(0.5), width: 0.5),
        ),
        child: Co(
          c: CAA.start,
          children: [
            const T(
              "Players",
              s: TS(w: FW.w700),
            ),
            12.h,
            if (usePortrait && !playerShouldAtSameColumnWithSettings && !settingsAndPlayersShouldAtDifferentColumnIsHorizontal)
              Ro(
                m: MAA.center,
                children: [
                  Exp(
                    child: blackOptions,
                  ),
                  16.w,
                  Exp(
                    child: whiteOptions,
                  ),
                ],
              ),
            if (settingsAndPlayersShouldAtDifferentColumnIsHorizontal)
              Ro(
                m: MAA.center,
                children: [
                  Exp(
                    child: blackOptions,
                  ),
                  16.w,
                  Exp(
                    child: whiteOptions,
                  ),
                ],
              ),
            if (playerShouldAtSameColumnWithSettings && !settingsAndPlayersShouldAtDifferentColumnIsHorizontal)
              Co(
                children: [
                  blackOptions,
                  4.h,
                  whiteOptions,
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Score extends ConsumerWidget {
  const _Score();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blackScore = ref.watch(P.othello.blackScore);
    final whiteScore = ref.watch(P.othello.whiteScore);
    final blackTurn = ref.watch(P.othello.blackTurn);
    final thinking = ref.watch(P.othello.thinking);
    final usePortrait = ref.watch(P.othello.usePortrait);

    final thinkingWidget = AnimatedOpacity(
      opacity: thinking ? 1.0 : 0.2,
      duration: const Duration(milliseconds: 150),
      child: Center(
        child: T(
          "Thinking",
          s: TS(c: kB, s: 10, w: thinking ? FW.w500 : FW.w400),
        ),
      ),
    );

    final newGameButton = TextButton(
      onPressed: thinking
          ? null
          : () {
              P.othello.start();
            },
      child: const T("New Game", s: TS(c: kB, s: 10, w: FW.w500)),
    );

    return Ro(
      c: CAA.center,
      children: [
        if (usePortrait) Exp(child: thinkingWidget),
        if (!usePortrait) thinkingWidget,
        if (!usePortrait) 16.w,
        T(
          "Black\n$blackScore",
          textAlign: TextAlign.center,
        ),
        16.w,
        C(
          padding: const EI.o(t: 0, b: 8, l: 8, r: 8),
          decoration: BD(
            color: kC,
            borderRadius: 8.r,
            border: Border.all(color: kB.wo(0.5), width: 0.5),
          ),
          child: Co(
            children: [
              const T("Currnet"),
              4.h,
              if (blackTurn) const _Black(minSize: 5, maxSize: 25),
              if (!blackTurn) const _White(minSize: 5, maxSize: 25),
            ],
          ),
        ),
        16.w,
        T(
          "White\n$whiteScore",
          textAlign: TextAlign.center,
        ),
        if (usePortrait) Exp(child: newGameButton),
        if (!usePortrait) 16.w,
        if (!usePortrait) newGameButton,
      ],
    );
  }
}

class _Othello extends ConsumerWidget {
  const _Othello();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = ref.watch(P.app.screenWidth);
    final screenHeight = ref.watch(P.app.screenHeight);
    return Ro(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.65,
            maxHeight: screenHeight * 0.65,
          ),
          child: const _Grid(),
        ),
      ],
    );
  }
}

class _Grid extends ConsumerWidget {
  const _Grid();

  static final double _sepWidth = 2.0;
  static final int _cellPerLine = 8;
  static final int _sepPerLine = _cellPerLine - 1;

  void _onCellTap({required int row, required int col}) async {
    P.othello.onCellTap(row: row, col: col);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(P.othello.state);
    final blackTurn = ref.watch(P.othello.blackTurn);
    final eatCountMatrixForBlack = ref.watch(P.othello.eatCountMatrixForBlack);
    final eatCountMatrixForWhite = ref.watch(P.othello.eatCountMatrixForWhite);
    final rulesHorizontalNames = ["a", "b", "c", "d", "e", "f", "g", "h"];
    final rulesVerticalNames = ["1", "2", "3", "4", "5", "6", "7", "8"];
    final labelSize = 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final size = min(width, height);
        final sizeForCells = size - labelSize - _sepPerLine * _sepWidth;
        final sizeForCell = sizeForCells / _cellPerLine;

        final cells = state
            .indexMap((row, line) {
              return line.indexMap((col, cellType) {
                final left = col * sizeForCell + col * _sepWidth;
                final top = row * sizeForCell + row * _sepWidth;
                final available = blackTurn ? eatCountMatrixForBlack[row][col] > 0 : eatCountMatrixForWhite[row][col] > 0;
                return Positioned(
                  left: left + labelSize,
                  top: top + labelSize,
                  width: sizeForCell,
                  height: sizeForCell,
                  child: GD(
                    onTap: () {
                      _onCellTap(row: row, col: col);
                    },
                    child: C(
                      decoration: BD(color: const Color(0xFF808080).wo(0.5)),
                      child: _Cell(
                        row: row,
                        col: col,
                        cellType: cellType,
                        available: available,
                      ),
                    ),
                  ),
                );
              });
            })
            .expand((e) => e)
            .toList();

        final rulesHorizontal = rulesHorizontalNames.indexMap((col, e) {
          final left = col * sizeForCell + col * _sepWidth + labelSize;
          return Positioned(
            left: left,
            top: 0,
            width: sizeForCell,
            height: labelSize,
            child: Center(child: T(e, s: const TS(c: kB, s: 10, w: FW.w700))),
          );
        }).toList();

        final rulesVertical = rulesVerticalNames.indexMap((row, e) {
          final top = row * sizeForCell + row * _sepWidth + labelSize;
          return Positioned(
            left: 0,
            top: top,
            height: sizeForCell,
            width: labelSize,
            child: Center(child: T(e, s: const TS(c: kB, s: 10, w: FW.w700))),
          );
        }).toList();

        return C(
          width: size,
          height: size,
          decoration: const BD(color: kC),
          child: Stack(
            children: [
              ...cells,
              ...rulesHorizontal,
              ...rulesVertical,
            ],
          ),
        );
      },
    );
  }
}

String _indexToChar(int index) {
  if (index == 0) return " ";
  return String.fromCharCode(index + 64);
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.row,
    required this.col,
    required this.cellType,
    required this.available,
  });

  final int row;
  final int col;
  final CellType cellType;
  final bool available;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxSize = min(constraints.maxWidth, constraints.maxHeight) * 0.7;
      final minSize = 5.0;

      final maxAvailableSize = min(constraints.maxWidth, constraints.maxHeight) * 0.2;
      final minAvailableSize = minSize - 2;

      if (available) {
        return Center(
          child: Stack(
            children: [
              C(
                constraints: BoxConstraints(
                  minWidth: minAvailableSize,
                  minHeight: minAvailableSize,
                  maxWidth: maxAvailableSize,
                  maxHeight: maxAvailableSize,
                ),
                decoration: BD(color: Colors.green, borderRadius: 100.r),
              ),
            ],
          ),
        );
      }

      switch (cellType) {
        case CellType.empty:
          return const Center(
            child: SizedBox.shrink(),
          );
        case CellType.black:
          return Center(
            child: _Black(minSize: minSize, maxSize: maxSize),
          );
        case CellType.white:
          return Center(
            child: _White(minSize: minSize, maxSize: maxSize),
          );
      }
    });
  }
}

class _White extends StatelessWidget {
  const _White({
    required this.minSize,
    required this.maxSize,
  });

  final double minSize;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    return C(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
        maxWidth: maxSize,
        maxHeight: maxSize,
      ),
      decoration: BD(
        boxShadow: [
          BoxShadow(
            color: kB.wo(0.3),
            offset: const Offset(1, 1),
            blurRadius: 3,
          ),
        ],
        gradient: RadialGradient(
          center: const Alignment(-0.5, -0.5),
          colors: [
            Colors.white,
            Colors.grey[300]!,
          ],
        ),
        borderRadius: 100.r,
      ),
    );
  }
}

class _Black extends StatelessWidget {
  const _Black({
    required this.minSize,
    required this.maxSize,
  });

  final double minSize;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    return C(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
        maxWidth: maxSize,
        maxHeight: maxSize,
      ),
      decoration: BD(
        boxShadow: [
          BoxShadow(
            color: kB.wo(0.3),
            offset: const Offset(1, 1),
            blurRadius: 3,
          ),
        ],
        gradient: RadialGradient(
          center: const Alignment(-0.5, -0.5),
          colors: [
            Colors.grey[700]!,
            Colors.black,
          ],
        ),
        borderRadius: 100.r,
      ),
    );
  }
}

class _Console extends ConsumerWidget {
  const _Console();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = P.othello.receivedScrollController;
    final received = (ref.watch(P.othello.received)).split("\n");
    final usePortrait = ref.watch(P.othello.usePortrait);
    final paddingTop = ref.watch(P.app.paddingTop);
    final paddingBottom = ref.watch(P.app.paddingBottom);
    final paddingLeft = ref.watch(P.app.paddingLeft);

    return Material(
      color: kB,
      textStyle: TS(ff: (Platform.isIOS || Platform.isMacOS) ? "Menlo" : "Monospace", c: kW, s: 10),
      child: ListView.builder(
        padding: EI.o(
          t: 8 + (usePortrait ? 0 : paddingTop),
          b: 8 + (usePortrait ? paddingBottom : paddingBottom),
          l: 8 + (usePortrait ? 0 : paddingLeft),
          r: 8,
        ),
        controller: controller,
        itemCount: received.length,
        itemBuilder: (context, index) {
          final List<CellType> girds = [];

          final line = received[index];
          final chars = line.split("");

          // debugger();

          for (var i = 0; i < chars.length; i++) {
            final e = chars[i];
            if (e == "●") {
              girds.add(CellType.black);
            } else if (e == "○") {
              girds.add(CellType.white);
            } else if (e == "·") {
              girds.add(CellType.empty);
            } else {}
          }

          final text = line.replaceAll("● ", "").replaceAll("○ ", "").replaceAll("· ", "").trim();

          // if (kDebugMode) print("💬 girds: $girds");

          // return T(received[index]);

          return Text.rich(
            TextSpan(
              children: [
                if (text.isNotEmpty) TextSpan(text: text),
                if (girds.isNotEmpty)
                  ...girds.map((e) {
                    if (e == CellType.black) {
                      return const WidgetSpan(child: _ConsoleCell(cellType: CellType.black));
                    } else if (e == CellType.white) {
                      return const WidgetSpan(child: _ConsoleCell(cellType: CellType.white));
                    } else {
                      return const WidgetSpan(child: _ConsoleCell(cellType: CellType.empty));
                    }
                  }),
              ],
            ),
            style: const TS(c: kW, s: 12, w: FW.w500),
          );
        },
      ),
    );
  }
}

class _ConsoleCell extends StatelessWidget {
  const _ConsoleCell({required this.cellType});

  final CellType cellType;

  @override
  Widget build(BuildContext context) {
    Color color = kC;
    switch (cellType) {
      case CellType.black:
        color = Colors.black;
        break;
      case CellType.white:
        color = Colors.white;
        break;
      case CellType.empty:
        color = kC;
        break;
    }
    return C(
      height: 12,
      width: 12,
      margin: const EI.s(h: 1),
      decoration: BD(color: kW.wo(0.33)),
      child: Center(
        child: Icon(
          Icons.circle,
          size: 10,
          color: color,
        ),
      ),
    );
  }
}
