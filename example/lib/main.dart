import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:zone/args.dart';
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
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await P.init();
  FlutterNativeSplash.remove();
  runApp(const _App());
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
          appBarTheme: const AppBarTheme(scrolledUnderElevation: 0, backgroundColor: Color(0xFFF4F8FF)),
          scaffoldBackgroundColor: const Color(0xFFF4F8FF),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(scrolledUnderElevation: 0, backgroundColor: Color(0xFFF4F8FF)),
          scaffoldBackgroundColor: const Color(0xFFF4F8FF),
        ),
        debugShowCheckedModeBanner: !Args.hideDebugBanner,
        routerConfig: kRouter,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
            child: Stack(
              children: [
                C(color: Theme.of(context).scaffoldBackgroundColor),
                if (child != null) child,
                Alert.deploy(),
                if (Args.enableChatDebugger) const ChatDebugger(),
                if (Args.enableOthelloDebugger) const OthelloDebugger(),
              ],
            ),
          );
        },
      ),
    );
  }
}
