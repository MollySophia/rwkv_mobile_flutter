import 'package:zone/launch_arguments.dart';
import 'package:zone/widgets/chat_debugger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:halo/halo.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/alert.dart';
import 'package:zone/widgets/othello_debugger.dart';

void main() async {
  await P.init();
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    P.app.firstContextGot(context);
    final split = LaunchArgs.localeString.split("_");
    final defaultLocale = LaunchArgs.localeString.isNotEmpty ? Locale(split.first, split.last) : null;
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
        ),
        darkTheme: ThemeData(
          brightness: Brightness.light,
        ),
        debugShowCheckedModeBanner: !LaunchArgs.hideDebugBanner,
        routerConfig: kRouter,
        builder: (context, child) {
          return Stack(
            children: [
              C(color: Theme.of(context).scaffoldBackgroundColor),
              if (child != null) child,
              Alert.deploy(),
              if (LaunchArgs.enableChatDebugger) const ChatDebugger(),
              if (LaunchArgs.enableOthelloDebugger) const OthelloDebugger(),
            ],
          );
        },
      ),
    );
  }
}
