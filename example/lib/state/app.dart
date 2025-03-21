part of 'p.dart';

class _App with WidgetsBindingObserver {
  final version = _gs<String>("");
  final buildNumber = _gs<String>("");

  /// Means the keyboard is shown if viewInsetBottom is not zero
  final viewInsetBottomIsZero = _gs(false);

  final paddingTop = _gs(0.0);
  final paddingBottom = _gs(0.0);
  final paddingLeft = _gs(0.0);
  final paddingRight = _gs(0.0);

  final viewPaddingTop = _gs(0.0);
  final viewPaddingBottom = _gs(0.0);
  final viewPaddingLeft = _gs(0.0);
  final viewPaddingRight = _gs(0.0);

  final viewInsetsTop = _gs(0.0);
  final viewInsetsBottom = _gs(0.0);
  final viewInsetsLeft = _gs(0.0);
  final viewInsetsRight = _gs(0.0);

  final screenWidth = _gs(0.0);
  final screenHeight = _gs(0.0);

  final gotContextOnce = _gs(false);

  final light = _gs(true);

  final isPortrait = _gs(true);

  final _pageKey = _gs(PageKey.first);

  late final pageKey = _gp((ref) => ref.watch(_pageKey));

  late final locale = _gsn<Locale>();

  // TODO: Check platform available
  late final tempDir = _gsn<Directory>();
  // TODO: Check platform available
  late final cacheDir = _gsn<Directory>();
  // TODO: Check platform available
  late final supportDir = _gsn<Directory>();
  // TODO: Check platform available
  late final libraryDir = _gsn<Directory>();
  // TODO: Check platform available
  late final downloadsDir = _gsn<Directory>();
  // TODO: Check platform available
  late final documentsDir = _gsn<Directory>();

  /// 当前正在运行的任务
  late final demoType = _gs(DemoType.chat);

  @override
  void didChangeMetrics() {
    final context = getContext();
    if (context == null) return;
    if (!context.mounted) return;
    _contextGot(context);
  }
}

/// Public methods
extension $App on _App {
  FV firstContextGot(BuildContext context) async {
    await Future.delayed(Duration.zero);
    // ignore: use_build_context_synchronously
    _contextGot(context);
  }
}

/// Private methods
extension _$App on _App {
  FV _init() async {
    if (kDebugMode) print("💬 $runtimeType._init");

    late final String name;
    if (kDebugMode) {
      name = (Args.demoType).replaceAll("__", "");
    } else {
      name = "__chat__".replaceAll("__", "");
    }
    demoType.u(DemoType.values.byName(name));

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;
      this.version.u(version);
      this.buildNumber.u(buildNumber);

      tempDir.u(await getTemporaryDirectory());
      supportDir.u(await getApplicationSupportDirectory());
      cacheDir.u(await getApplicationCacheDirectory());
      downloadsDir.u(await getDownloadsDirectory());
      documentsDir.u(await getApplicationDocumentsDirectory());
    } catch (e) {
      if (kDebugMode) print("😡 Error when calling _App._init");
      if (kDebugMode) print("😡 $e");
    }

    kRouter.routerDelegate.addListener(_routerListener);

    if (kDebugMode) {
      final context = getContext();
      Future.delayed(const Duration(seconds: 1), () {
        if (context != null && context.mounted) {
          FocusScope.of(context).unfocus();
        }
      });
    }

    WidgetsBinding.instance.addObserver(this);
  }

  void _routerListener() {
    final currentConfiguration = kRouter.routerDelegate.currentConfiguration;
    final matchedLocation = currentConfiguration.last.matchedLocation;
    final pageKey = PageKey.values.byName(matchedLocation.replaceAll("/", ""));
    if (kDebugMode) print("✅ navigate to page: ${pageKey.toString().split(".").last}");
    HF.wait(0).then((_) {
      _pageKey.u(pageKey);
    });
  }

  void _contextGot(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    final viewInsets = mediaQueryData.viewInsets;
    viewInsetBottomIsZero.u(viewInsets.bottom == 0);

    final padding = mediaQueryData.padding;
    paddingTop.u(padding.top);
    paddingBottom.u(padding.bottom);
    paddingLeft.u(padding.left);
    paddingRight.u(padding.right);

    final size = mediaQueryData.size;
    screenWidth.u(size.width);
    screenHeight.u(size.height);

    final viewPadding = mediaQueryData.viewPadding;
    viewPaddingTop.u(viewPadding.top);
    viewPaddingBottom.u(viewPadding.bottom);
    viewPaddingLeft.u(viewPadding.left);
    viewPaddingRight.u(viewPadding.right);

    final mediaPadding = mediaQueryData.viewInsets;
    viewInsetsTop.u(mediaPadding.top);
    viewInsetsBottom.u(mediaPadding.bottom);
    viewInsetsLeft.u(mediaPadding.left);
    viewInsetsRight.u(mediaPadding.right);

    final brightness = mediaQueryData.platformBrightness;
    light.u(brightness == Brightness.light);

    final orientation = mediaQueryData.orientation;
    isPortrait.u(orientation == Orientation.portrait);
  }
}
