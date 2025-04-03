import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:halo/halo.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/language.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:zone/widgets/debugger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await P.init();
  if (kDebugMode) {
    await _debugAppRunner();
  } else {
    await _sentryAppRunner();
  }
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterNativeSplash.remove();
}

FV _sentryAppRunner() async {
  await SentryFlutter.init(_configureSentry, appRunner: () async {
    runApp(const _App());
  });
}

FV _debugAppRunner() async {
  runApp(const _App());
}

FutureOr<void> _configureSentry(SentryFlutterOptions options) {
  options.dsn = 'https://320015d75031601a48829d02f17a8394@o4506895545597952.ingest.us.sentry.io/4508996340482048';
  options.tracesSampleRate = kDebugMode ? 1.0 : 0.05;
  options.profilesSampleRate = kDebugMode ? 1.0 : 0.05;
  options.debug = kDebugMode;
  options.diagnosticLevel = SentryLevel.warning;
  if (kReleaseMode) {
    options.environment = 'production';
  } else if (kProfileMode) {
    options.environment = 'testing';
  } else {
    options.environment = 'development';
  }
}

final _supportedLocales = Language.values.map((e) => e.locale).toList();
Language? _debugLatestLanguage;

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    qq;
    P.app.firstContextGot(context);

    if (kDebugMode) {
      _debugLatestLanguage = [Language.zh_Hans, Language.en].firstWhereOrNull((e) => e != _debugLatestLanguage);
    }

    final locale = !kDebugMode ? null : _debugLatestLanguage?.locale;

    return StateWrapper(
      child: MaterialApp.router(
        locale: locale,
        supportedLocales: _supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(scrolledUnderElevation: 0, backgroundColor: kBG),
          scaffoldBackgroundColor: kBG,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(scrolledUnderElevation: 0, backgroundColor: kBG),
          scaffoldBackgroundColor: kBG,
        ),
        debugShowCheckedModeBanner: kDebugMode,
        routerConfig: kRouter,
        builder: _builder,
      ),
    );
  }

  Widget _builder(BuildContext context, Widget? child) {
    qq;
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 1,
      maxScaleFactor: 1.5,
      child: Stack(
        children: [
          C(color: kBG),
          if (child != null) child,
          const Alert(),
          if (kDebugMode) const Debugger(),
        ],
      ),
    );
  }
}
