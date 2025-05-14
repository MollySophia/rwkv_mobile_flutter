part of 'p.dart';

const _kMaxStackDepth = 10;

class _Sudoku {
  /// Stop token
  static const tokenStop = 105;

  static String merged = '';
  final staticData = qs<List<List<int>>>([]);
  final dynamicData = qs<List<List<int>>>([]);
  final logs = qs<List<String>>([]);

  late final hasPuzzle = qp<bool>((ref) {
    final puzzle = ref.watch(staticData);
    for (final row in puzzle) {
      for (final grid in row) {
        if (grid != 0) return true;
      }
    }
    return false;
  });

  final running = qs<bool>(false);

  // TODO: 用户强制终止 exec
  final bool _forceStop = false;

  // final streamController = StreamController<(int output, String decoded)>.broadcast();

  bool _recordingTagBoard = false;
  bool _recordingTagStack = false;

  final List<(int, String)> _tempBoardEvents = [];
  final List<(int, String)> _tempStackEvents = [];

  final tokensCount = qs<int>(0);
  final tokensPerSecond = qs<double>(0);
  final widgetPosition = qs<Map<String, Offset>>(const {});
  final uiOffset = qs<Offset>(Offset.zero);

  final showStack = qs<bool>(true);

  final currentStack = qs<List<(int, int)>>([]);

  late final File _file;
  late IOSink _fileSink;
}

/// Public methods
extension $Sudoku on _Sudoku {
  (func_sudoku.SudokuGrid solved, func_sudoku.SudokuGrid puzzle) generate({required int difficulty}) {
    final solved = func_sudoku.genSolved();
    final puzzle = func_sudoku.genPuzzle(solved, difficulty: difficulty);
    return (solved, puzzle);
  }

  FV onGeneratePressed(BuildContext context) async {
    final _running = running.v;
    if (_running) {
      await showOkAlertDialog(
        context: context,
        title: "Inference is running",
        message: "Please wait for it to finish",
      );
      return;
    }

    final difficulty = await showTextInputDialog(
      context: context,
      title: "Generate random Sudoku puzzle",
      message: "Please enter the difficulty",
      textFields: [
        const DialogTextField(
          hintText: "difficulty",
          initialText: kDebugMode ? "40" : "10",
          keyboardType: TextInputType.numberWithOptions(
            signed: false,
            decimal: false,
          ),
        ),
      ],
    );
    if (difficulty == null) return;
    if (difficulty.isEmpty) return;
    final value = difficulty.first;
    final difficultyInt = int.tryParse(value);
    if (difficultyInt == null) return;

    if (difficultyInt < 1) {
      if (context.mounted) {
        await showOkAlertDialog(
          context: context,
          title: "Can not generate",
          message: "Difficulty must be greater than 0",
        );
      }
      return;
    }

    if (difficultyInt > 81) {
      if (context.mounted) {
        await showOkAlertDialog(
          context: context,
          title: "Can not generate",
          message: "Difficulty must be less than 81",
        );
      }
      return;
    }

    clear();
    final (solved, puzzle) = generate(difficulty: difficultyInt);
    staticData.u(puzzle);
  }

  FV onInferencePressed(BuildContext context) async {
    final _running = running.v;
    if (_running) {
      await showOkAlertDialog(
        context: context,
        title: "Inference is running",
        message: "Please wait for it to finish",
      );
      return;
    }

    tokensCount.u(0);
    running.u(true);

    func_sudoku.SudokuGrid grid = staticData.v;
    final prompt = _genPrompt(grid);
    // TODO: send
    // final encodedPrompt = tokenizer.encode(prompt);
    // while (modelSendPort == null) {}
    // modelSendPort!.send('clearStates');
    // modelSendPort!.send(encodedPrompt);
  }

  void clear() {
    final newValue = func_sudoku.genEmpty();
    staticData.u(func_sudoku.deepCopyList(newValue));
    dynamicData.u(func_sudoku.deepCopyList(newValue));
    logs.u([]);
    tokensCount.u(0);
    currentStack.u([]);
    _recordingTagBoard = false;
    _recordingTagStack = false;
    _tempStackEvents.clear();
  }

  void debugRenderingRandom() {
    final solvedGrid = func_sudoku.genSolved();
    final difficulty = HF.randomInt(min: 1, max: 1);
    final newValue = func_sudoku.genPuzzle(solvedGrid, difficulty: difficulty);
    staticData.u(newValue);
  }

  void onGridPressed(BuildContext context, int col, int row) async {
    if (kDebugMode) print("💬 onGridPressed: $col, $row");
    final _running = running.v;
    if (_running) {
      await showOkAlertDialog(
        context: context,
        title: "Inference is running",
        message: "Please wait for it to finish",
      );
      return;
    }

    final currentPuzzle = staticData.v;
    final currentValue = currentPuzzle[row][col];

    final value = await showTextInputDialog(
      context: context,
      title: "Set the value of grid",
      message: "Please enter a number. 0 means empty.",
      textFields: [
        DialogTextField(
          hintText: "number",
          initialText: currentValue.toString(),
          keyboardType: const TextInputType.numberWithOptions(
            signed: false,
            decimal: false,
          ),
        ),
      ],
    );

    if (value == null) return;
    if (value.isEmpty) return;
    final valueInt = int.tryParse(value.first);
    if (valueInt == null) return;
    if (valueInt < 0 || valueInt > 9) {
      if (context.mounted) {
        await showOkAlertDialog(
          context: context,
          title: "Invalid value",
          message: "Value must be between 0 and 9",
        );
      }
      return;
    }

    final newPuzzle = func_sudoku.deepCopyList(currentPuzzle);
    newPuzzle[row][col] = valueInt;

    final isValid = func_sudoku.isValid(newPuzzle, solved: false);
    if (!isValid) {
      if (context.mounted) {
        await showOkAlertDialog(
          context: context,
          title: "Invalid puzzle",
          message: "The puzzle is not valid",
        );
      }
      return;
    }

    staticData.u(newPuzzle);
    // debugger();
  }

  void onClearPressed(BuildContext context) async {
    final _running = running.v;
    if (_running) {
      await showOkAlertDialog(
        context: context,
        title: "Inference is running",
        message: "Please wait for it to finish",
      );
      return;
    }
    clear();
  }

  void onToggleShowStack(BuildContext context) {
    showStack.u(!showStack.v);
  }

  void loadHardestSudoku() {
    clear();

    // "hardest"
    // https://abcnews.go.com/blogs/headlines/2012/06/can-you-solve-the-hardest-ever-sudoku
    const puzzle = [
      [8, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 3, 6, 0, 0, 0, 0, 0],
      [0, 7, 0, 0, 9, 0, 2, 0, 0],
      [0, 5, 0, 0, 0, 7, 0, 0, 0],
      [0, 0, 0, 0, 4, 5, 7, 0, 0],
      [0, 0, 0, 1, 0, 0, 0, 3, 0],
      [0, 0, 1, 0, 0, 0, 0, 6, 8],
      [0, 0, 8, 5, 0, 0, 0, 1, 0],
      [0, 9, 0, 0, 0, 0, 4, 0, 0],
    ];

    // moderate
    // https://www.7sudoku.com/moderate
    // const puzzle = [
    //   [0, 0, 1, 0, 0, 3, 0, 0, 0],
    //   [0, 0, 0, 0, 9, 0, 7, 0, 5],
    //   [8, 2, 5, 0, 6, 0, 0, 9, 0],
    //   [4, 0, 9, 0, 1, 0, 0, 0, 0],
    //   [2, 5, 0, 0, 0, 0, 0, 1, 7],
    //   [0, 0, 0, 0, 5, 0, 9, 0, 4],
    //   [0, 6, 0, 0, 4, 0, 8, 7, 3],
    //   [9, 0, 3, 0, 2, 0, 0, 0, 0],
    //   [0, 0, 0, 3, 0, 0, 2, 0, 0],
    // ];

    // https://www.7sudoku.com/difficult
    // https://www.7sudoku.com/view-puzzle?p=a7383154d89311efb2a7509a4c9d0656
    // 600100385000000007000028009901003070000000000080500903500240000100000000823005006
    // const puzzle = [
    //   [6, 0, 0, 1, 0, 0, 3, 8, 5],
    //   [0, 0, 0, 0, 0, 0, 0, 0, 7],
    //   [0, 0, 0, 0, 2, 8, 0, 0, 9],
    //   [9, 0, 1, 0, 0, 3, 0, 7, 0],
    //   [0, 0, 0, 0, 0, 0, 0, 0, 0],
    //   [0, 8, 0, 5, 0, 0, 9, 0, 3],
    //   [5, 0, 0, 2, 4, 0, 0, 0, 0],
    //   [1, 0, 0, 0, 0, 0, 0, 0, 0],
    //   [8, 2, 3, 0, 0, 5, 0, 0, 6],
    // ];

    staticData.u(puzzle);
  }
}

/// Private methods
extension _$Sudoku on _Sudoku {
  FV _init() async {
    switch (P.app.demoType.q) {
      case DemoType.sudoku:
        break;
      case DemoType.fifthteenPuzzle:
      case DemoType.othello:
      case DemoType.chat:
      case DemoType.tts:
      case DemoType.world:
        return;
    }

    qq;

    HF.wait(1000).then((_) {
      final loaded = P.rwkv.loaded.q;
      qr;
      if (!loaded) {
        P.fileManager.modelSelectorShown.q = true;
      }
    });

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/output_log.txt';
    final file = File(filePath);

    // 先清除文件内容
    await file.writeAsString('', mode: FileMode.write);

    // 然后再以追加模式打开文件流
    _fileSink = file.openWrite(mode: FileMode.append);
    _file = file;

    clear();
    _loadDefaultPuzzle();
  }

  void parseStack() {
    final events = _tempStackEvents;
    List<(int, int)> stack = events.where((e) {
      final token = e.$1;
      return _kStackMap.containsKey(token);
    }).map((e) {
      final token = e.$1;
      return _kStackMap[token]!;
    }).toList();
    // debugger();

    // 最大深度为 10
    // 如果超过最大深度，则只保留最后的 10 个
    if (stack.length > _kMaxStackDepth) {
      stack = stack.sublist(stack.length - _kMaxStackDepth);
    }

    currentStack.u(stack);
  }

  void qparseBoard() {
    final events = _tempBoardEvents;
    const gridValues = ["0 ", "1 ", "2 ", "3 ", "4 ", "5 ", "6 ", "7 ", "8 ", "9 "];
    final grids = events.map((e) => e.$2).toList().where((e) => gridValues.contains(e)).toList().map((e) => int.parse(e.replaceAll(" ", ""))).toList();
    final grid = func_sudoku.genFromList(grids);
    dynamicData.u(grid);
    if (kDebugMode) {
      final staticData = this.staticData.v;
      final dynamicData = this.dynamicData.v;
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          final staticValue = staticData[i][j];
          final dynamicValue = dynamicData[i][j];
          if (staticValue != 0) {
            if (dynamicValue != staticValue) {
              if (kDebugMode) print("🔥 $i $j $staticValue $dynamicValue");
              throw "";
            }
          }
        }
      }
    }
  }

  String _genPrompt(func_sudoku.SudokuGrid grid) {
    final newPrompt = '''<input>
${grid.map((row) => row.join(' ') + " \n").join("")}</input>

''';
    return newPrompt;
  }

  Future<void> copyToCache(String assetPath, String cachePath) async {
    final rawAssetFile = await rootBundle.load(assetPath);
    final bytes = rawAssetFile.buffer.asUint8List();
    final libFile = File(cachePath);
    await libFile.writeAsBytes(bytes);
  }

  void _loadDefaultPuzzle() {
    const defaultPuzzle = [
      [0, 0, 8, 1, 6, 7, 0, 2, 0],
      [5, 0, 0, 2, 3, 0, 0, 0, 0],
      [7, 6, 0, 0, 5, 4, 8, 0, 1],
      [8, 7, 0, 0, 4, 0, 0, 0, 0],
      [0, 2, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 4, 0, 0, 3, 0, 9, 0],
      [0, 0, 0, 0, 0, 0, 3, 7, 0],
      [0, 4, 0, 0, 0, 0, 0, 8, 0],
      [3, 1, 0, 8, 0, 6, 9, 0, 4],
    ];

    staticData.u(defaultPuzzle);
  }

  Future<void> _closeFileSink() async {
    await _fileSink.flush();
    await _fileSink.close();
  }

  void _initializeFileSink() {
    final file = File('your_fileqpath');
    _fileSink = file.openWrite(mode: FileMode.append);
  }
}

/// 仅仅记录 stack 标签中的 grid 坐标
const _kStackMap = {
  11: (0, 0),
  12: (0, 1),
  13: (0, 2),
  14: (0, 3),
  15: (0, 4),
  16: (0, 5),
  17: (0, 6),
  18: (0, 7),
  19: (0, 8),
  20: (1, 0),
  21: (1, 1),
  22: (1, 2),
  23: (1, 3),
  24: (1, 4),
  25: (1, 5),
  26: (1, 6),
  27: (1, 7),
  28: (1, 8),
  29: (2, 0),
  30: (2, 1),
  31: (2, 2),
  32: (2, 3),
  33: (2, 4),
  34: (2, 5),
  35: (2, 6),
  36: (2, 7),
  37: (2, 8),
  38: (3, 0),
  39: (3, 1),
  40: (3, 2),
  41: (3, 3),
  42: (3, 4),
  43: (3, 5),
  44: (3, 6),
  45: (3, 7),
  46: (3, 8),
  47: (4, 0),
  48: (4, 1),
  49: (4, 2),
  50: (4, 3),
  51: (4, 4),
  52: (4, 5),
  53: (4, 6),
  54: (4, 7),
  55: (4, 8),
  56: (5, 0),
  57: (5, 1),
  58: (5, 2),
  59: (5, 3),
  60: (5, 4),
  61: (5, 5),
  62: (5, 6),
  63: (5, 7),
  64: (5, 8),
  65: (6, 0),
  66: (6, 1),
  67: (6, 2),
  68: (6, 3),
  69: (6, 4),
  70: (6, 5),
  71: (6, 6),
  72: (6, 7),
  73: (6, 8),
  74: (7, 0),
  75: (7, 1),
  76: (7, 2),
  77: (7, 3),
  78: (7, 4),
  79: (7, 5),
  80: (7, 6),
  81: (7, 7),
  82: (7, 8),
  83: (8, 0),
  84: (8, 1),
  85: (8, 2),
  86: (8, 3),
  87: (8, 4),
  88: (8, 5),
  89: (8, 6),
  90: (8, 7),
  91: (8, 8),
};

class SandboxFileHandler {
  IOSink? _fileSink;
  String? _filePath;

  // Initialize and open the file
  Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _filePath = '${directory.path}/output_log.txt';
      final file = File(_filePath!);
      _fileSink = file.openWrite(mode: FileMode.append);
      if (kDebugMode) print('File opened for writing: $_filePath');
    } catch (e) {
      if (kDebugMode) print('Error initializing file: $e');
    }
  }

  // Append content to the file
  void appendContent(String content) {
    if (_fileSink != null) {
      _fileSink!.write(content);
    } else {
      if (kDebugMode) print('Warning: File sink not initialized. Call init() first.');
    }
  }

  // Close the file
  Future<void> close() async {
    if (_fileSink != null) {
      await _fileSink!.flush();
      await _fileSink!.close();
      _fileSink = null;
      if (kDebugMode) print('File closed: $_filePath');
    }
  }
}
