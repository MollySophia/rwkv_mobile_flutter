part of 'p.dart';

class _App extends RawApp {
  final _pageKey = qs(PageKey.first);
  late final pageKey = qp((ref) => ref.watch(_pageKey));

  /// 当前正在运行的任务
  late final demoType = qs(DemoType.chat);

  late final latestBuild = qs(-1);
  late final latestBuildIos = qs(-1);
  late final noteZh = qs<List<String>>([]);
  late final noteEn = qs<List<String>>([]);
  late final modelConfig = qs<List<JSON>>([]);
  late final androidUrl = qsn<String>();
  late final iosUrl = qsn<String>();

  late final newVersionDialogShown = qs(false);

  static const String _remoteDemoConfigKey = "demo-config.json";

  late final isDesktop = qp((ref) => ref.watch(_isDesktop));
  final _isDesktop = qs(false);
  late final isMobile = qp((ref) => ref.watch(_isMobile));
  final _isMobile = qs(true);

  @override
  BuildContext? get context => getContext();
}

/// Public methods
extension $App on _App {
  FV getConfig() async {
    qq;

    if (Args.disableRemoteConfig) {
      qqw("Remote config is disabled");
      return;
    }

    final sp = await SharedPreferences.getInstance();

    if (sp.containsKey(_App._remoteDemoConfigKey)) {
      qqr("Load cached remote config from local");
      await _parseConfig(jsonDecode(sp.getString(_App._remoteDemoConfigKey)!));
    }

    await HF.wait(17);

    try {
      final res = await _get("get-demo-config", timeout: 10000.ms);
      if (res is! Map) {
        qqe("res is not a Map, res: ${res.runtimeType}");
        return;
      }
      final success = res["success"];
      final message = res["message"];
      final data = res["data"];
      if (success != true) throw "success is false, success: $success, message: $message";
      if (data is! Map) throw "data is not a Map, data: ${data.runtimeType}";
      final config = data[demoType.q.name];
      await _parseConfig(config);

      // 将 res 写入本地沙盒文件

      sp.setString(_App._remoteDemoConfigKey, jsonEncode(config));
    } catch (e) {
      qe;
      qqe("e: $e");
      if (!kDebugMode) Sentry.captureException(e, stackTrace: StackTrace.current);
    }
  }

  void hapticLight() {
    if (_isMobile.q) Gaimon.light();
  }

  void hapticSoft() {
    if (_isMobile.q) Gaimon.soft();
  }

  void hapticMedium() {
    if (_isMobile.q) Gaimon.medium();
  }
}

/// Private methods
extension _$App on _App {
  FV _init() async {
    qq;

    _isDesktop.q = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    _isMobile.q = Platform.isAndroid || Platform.isIOS;

    await init();

    preferredThemeMode.q = ThemeMode.light;

    late final String name;
    if (kDebugMode) {
      name = (Args.demoType).replaceAll("__", "");
    } else {
      name = "__chat__".replaceAll("__", "");
    }
    demoType.q = DemoType.values.byName(name);

    if (isDesktop.q) {
      final desktopOrientations = demoType.q.desktopOrientations;
      if (desktopOrientations != null) SystemChrome.setPreferredOrientations(desktopOrientations);
    } else {
      final mobileOrientations = demoType.q.mobileOrientations;
      if (mobileOrientations != null) SystemChrome.setPreferredOrientations(mobileOrientations);
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

    if (!Args.disableRemoteConfig) {
      getConfig().then((_) async {
        await HF.wait(1000);
        _showNewVersionDialogIfNeeded();
      });
    }
  }

  FV _showNewVersionDialogIfNeeded() async {
    qq;

    if (Platform.isAndroid && latestBuild.q <= int.parse(buildNumber.q)) return;
    if (Platform.isIOS && latestBuildIos.q <= int.parse(buildNumber.q)) return;

    if (!Platform.isIOS && !Platform.isAndroid) {
      qqw("This feature is not supported on this platform");
      return;
    }

    final androidUrl = this.androidUrl.q;
    final iosUrl = this.iosUrl.q;

    if (Platform.isAndroid && (androidUrl == null || androidUrl.isEmpty)) return;

    if (Platform.isIOS && (iosUrl == null || iosUrl.isEmpty)) return;

    await HF.wait(1);

    final noteZh = this.noteZh.q;
    final noteEn = this.noteEn.q;

    final currentLocale = Intl.getCurrentLocale();
    final useEn = currentLocale.startsWith("en");

    final message = useEn ? noteEn.join("\n") : noteZh.join("\n");

    newVersionDialogShown.q = true;
    final res = await showOkCancelAlertDialog(
      context: getContext()!,
      title: S.current.new_version_found,
      message: message,
      okLabel: S.current.update_now,
      cancelLabel: S.current.cancel_update,
    );
    newVersionDialogShown.q = false;

    if (res != OkCancelResult.ok) return;

    if (Platform.isAndroid) {
      if (androidUrl == null) {
        qqe("androidUrl is null");
        return;
      }
      // todo AppUpdateDialog.show(getContext()!, url: "");
      launchUrl(Uri.parse(androidUrl), mode: LaunchMode.externalApplication);
    }

    if (Platform.isIOS) {
      if (iosUrl == null) {
        qqe("iosUrl is null");
        return;
      }
      launchUrl(Uri.parse(iosUrl), mode: LaunchMode.externalApplication);
    }
  }

  FV _parseConfig(dynamic config) async {
    if (config is! Map) {
      qqe("config is not a Map, config: ${config.runtimeType}");
      Sentry.captureException(Exception("config is not a Map, config: ${config.runtimeType}"), stackTrace: StackTrace.current);
      return;
    }

    final build = config["latest_build"];
    final buildIos = config["latest_build_ios"];

    if (build is! num) {
      qqe("build is not an num, build: $build");
      Sentry.captureException(Exception("build is not an num, build: $build"), stackTrace: StackTrace.current);
      return;
    }

    if (buildIos is! num) {
      qqe("buildIos is not an num, buildIos: $buildIos");
      Sentry.captureException(Exception("buildIos is not an num, buildIos: $buildIos"), stackTrace: StackTrace.current);
      return;
    }

    latestBuild.q = build.toInt();
    latestBuildIos.q = buildIos.toInt();
    noteZh.q = (config["note_zh"] as List<dynamic>).m((e) => e.toString());
    noteEn.q = (config["note_en"] as List<dynamic>).m((e) => e.toString());
    modelConfig.q = HF.listJSON(config["model_config"]);
    androidUrl.q = config["android_url"].toString();
    iosUrl.q = config["ios_url"].toString();
    await P.fileManager.syncAvailableModels();
    await P.fileManager.checkLocal();
  }

  void _routerListener() {
    final currentConfiguration = kRouter.routerDelegate.currentConfiguration;
    final matchedLocation = currentConfiguration.last.matchedLocation;
    final pageKey = PageKey.values.byName(matchedLocation.replaceAll("/", ""));
    qqr("navigate to page: ${pageKey.toString().split(".").last}");
    HF.wait(0).then((_) {
      _pageKey.q = pageKey;
    });
  }
}
