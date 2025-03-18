import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:zone/args.dart';
import 'package:zone/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:halo/halo.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:zone/widgets/debugger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await SentryFlutter.init(_configureSentry, appRunner: () async {
    await P.init();
    runApp(SentryWidget(child: const _App()));
  });
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterNativeSplash.remove();
}

FutureOr<void> _configureSentry(options) {
  options.dsn = 'https://320015d75031601a48829d02f17a8394@o4506895545597952.ingest.us.sentry.io/4508996340482048';
  options.tracesSampleRate = kDebugMode ? 1.0 : 0.05;
  options.profilesSampleRate = kDebugMode ? 1.0 : 0.05;
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    P.app.firstContextGot(context);
    final split = Args.localeString.split("_");
    final defaultLocale = Args.localeString.isNotEmpty ? Locale(split.first, split.last) : null;
    return StateWrapper(
      child: MaterialApp.router(
        locale: defaultLocale,
        supportedLocales: const [
          Locale("zh", "Hans"),
          Locale("zh", "Hant"),
          Locale("en", "US"),
          Locale("ja", "JP"),
        ],
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
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
            child: Stack(
              children: [
                C(color: Theme.of(context).scaffoldBackgroundColor),
                if (child != null) child,
                Alert.deploy(),
                if (kDebugMode) const Debugger(),
              ],
            ),
          );
        },
      ),
    );
  }
}
