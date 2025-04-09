part of 'p.dart';

class _App extends RawApp with WidgetsBindingObserver {
  final gotContextOnce = qs(false);

  final lifecycleState = qs(AppLifecycleState.resumed);

  final _pageKey = qs(PageKey.first);

  late final pageKey = qp((ref) => ref.watch(_pageKey));

  late final locale = qsn<Locale>();

  /// 当前正在运行的任务
  late final demoType = qs(DemoType.chat);

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
