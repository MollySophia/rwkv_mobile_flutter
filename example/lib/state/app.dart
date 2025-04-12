part of 'p.dart';

class _App extends RawApp with WidgetsBindingObserver {
  final gotContextOnce = qs(false);

  final lifecycleState = qs(AppLifecycleState.resumed);

  final _pageKey = qs(PageKey.first);

  late final pageKey = qp((ref) => ref.watch(_pageKey));

  /// 当前正在运行的任务
  late final demoType = qs(DemoType.chat);

  late final latestBuild = qs(-1);
  late final noteZh = qs<List<String>>([]);
  late final noteEn = qs<List<String>>([]);
  late final modelConfig = qs<List<JSON>>([]);
  late final androidUrl = qsn<String>();
  late final iosUrl = qsn<String>();

  late final newVersionDialogShown = qs(false);

  @override
  void didChangeMetrics() {
    final context = getContext();
    if (context == null) return;
    if (!context.mounted) return;
    contextGot(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    lifecycleState.u(state);
  }
}

/// Public methods
extension $App on _App {
  FV firstContextGot(BuildContext context) async {
    await Future.delayed(Duration.zero);
    // ignore: use_build_context_synchronously
    contextGot(context);
  }

  FV getConfig() async {
    qq;
    await HF.wait(17);
    try {
      final res = await _get("get-demo-config");
      qqq("res: $res");

      if (res is! Map) {
        throw "res is not a Map, res: ${res.runtimeType}";
      }
      final success = res["success"];
      final message = res["message"];
      final data = res["data"];
      if (success != true) {
        throw "success is false, success: $success, message: $message";
      }
      if (data is! Map) {
        throw "data is not a Map, data: ${data.runtimeType}";
      }
      final config = data[demoType.v.name];
      if (config is! Map) {
        throw "config is not a Map, config: ${config.runtimeType}";
      }
      final build = config["latest_build"];
      if (build is! num) {
        throw "build is not an num, build: $build";
      }
      latestBuild.u(build.toInt());
      noteZh.u((config["note_zh"] as List<dynamic>).m((e) => e.toString()));
      noteEn.u((config["note_en"] as List<dynamic>).m((e) => e.toString()));
      modelConfig.u(HF.listJSON(config["model_config"]));
      androidUrl.u(config["android_url"].toString());
      iosUrl.u(config["ios_url"].toString());
      if (latestBuild.v <= int.parse(buildNumber.v)) return;
      _showNewVersionDialog();
    } catch (e) {
      qqe("e: $e");
      qe;
      Sentry.captureException(e);
    }
  }
}

/// Private methods
extension _$App on _App {
  FV _init() async {
    qq;

    await init();

    late final String name;
    if (kDebugMode) {
      name = (Args.demoType).replaceAll("__", "");
    } else {
      name = "__chat__".replaceAll("__", "");
    }
    demoType.u(DemoType.values.byName(name));

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
    getConfig();
  }

  FV _showNewVersionDialog() async {
    qq;
    if (!kDebugMode) {
      if (P.app.demoType.v == DemoType.chat && !Platform.isIOS && !Platform.isAndroid) {
        return;
      }

      if (P.app.demoType.v == DemoType.othello && !Platform.isAndroid) {
        return;
      }
    }

    final androidUrl = this.androidUrl.v;
    final iosUrl = this.iosUrl.v;

    if (Platform.isAndroid && (androidUrl == null || androidUrl.isEmpty)) {
      return;
    }

    if (Platform.isIOS && (iosUrl == null || iosUrl.isEmpty)) {
      return;
    }

    await HF.wait(1);

    final noteZh = this.noteZh.v;
    final noteEn = this.noteEn.v;

    final currentLocale = Intl.getCurrentLocale();
    final useEn = currentLocale.startsWith("en");

    final message = useEn ? noteEn.join("\n") : noteZh.join("\n");

    newVersionDialogShown.u(true);
    final res = await showOkCancelAlertDialog(
      context: getContext()!,
      title: S.current.new_version_found,
      message: message,
      okLabel: S.current.update_now,
      cancelLabel: S.current.cancel_update,
    );
    newVersionDialogShown.u(false);

    if (res != OkCancelResult.ok) return;

    if (Platform.isAndroid) {
      if (androidUrl == null) {
        qqe("androidUrl is null");
        return;
      }
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

  void _routerListener() {
    final currentConfiguration = kRouter.routerDelegate.currentConfiguration;
    final matchedLocation = currentConfiguration.last.matchedLocation;
    final pageKey = PageKey.values.byName(matchedLocation.replaceAll("/", ""));
    qqr("navigate to page: ${pageKey.toString().split(".").last}");
    HF.wait(0).then((_) {
      _pageKey.u(pageKey);
    });
  }
}
