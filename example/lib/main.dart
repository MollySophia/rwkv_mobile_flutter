import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:halo/halo.dart';
import 'package:chat/config.dart';
import 'package:chat/gen/l10n.dart';
import 'package:chat/route/router.dart';
import 'package:chat/state/p.dart';
import 'package:chat/widgets/alert.dart';

void main() async {
  await P.init();
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    P.app.firstContextGot(context);
    final split = Config.localeString.split("_");
    final defaultLocale = Config.localeString.isNotEmpty ? Locale(split.first, split.last) : null;
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
          fontFamily: "TONEOZ-TSUIPITA-TC",
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
        ),
        darkTheme: ThemeData(
          fontFamily: "TONEOZ-TSUIPITA-TC",
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
        ),
        debugShowCheckedModeBanner: kDebugMode,
        routerConfig: kRouter,
        builder: (context, child) {
          return Stack(
            children: [
              C(color: Theme.of(context).scaffoldBackgroundColor),
              if (child != null) child,
              Alert.deploy(),
            ],
          );
        },
      ),
    );
  }
}
