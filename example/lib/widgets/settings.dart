// ignore: unused_import
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zone/config.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/form_item.dart';

class Settings extends ConsumerWidget {
  final ScrollController? scrollController;

  const Settings({super.key, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingBottom = ref.watch(P.app.paddingBottom);
    final paddingTop = ref.watch(P.app.paddingTop);
    final demoType = ref.watch(P.app.demoType);
    final iconPath = "assets/img/${demoType.name}/icon.png";
    final version = ref.watch(P.app.version);
    final buildNumber = ref.watch(P.app.buildNumber);
    final preferredTextScaleFactor = ref.watch(P.preference.preferredTextScaleFactor);
    final preferredLanguage = ref.watch(P.preference.preferredLanguage);
    final paddingLeft = ref.watch(P.app.paddingLeft);

    final iconWidget = SB(
      width: 64,
      height: 64,
      child: ClipRRect(
        borderRadius: 12.r,
        child: Image.asset(iconPath),
      ),
    );

    return Scaffold(
      body: ListView(
        padding: EI.o(
          t: paddingTop,
          b: paddingBottom,
          l: 12 + paddingLeft,
          r: 12,
        ),
        controller: scrollController,
        children: [
          12.h,
          Ro(
            m: MAA.center,
            children: [iconWidget],
          ),
          16.h,
          const Ro(
            m: MAA.center,
            children: [
              T(
                Config.appTitle,
                s: TS(s: 24),
              ),
            ],
          ),
          4.h,
          Ro(
            m: MAA.center,
            children: [
              T(
                version,
                s: const TS(s: 12),
              ),
              T(
                " ($buildNumber)",
                s: const TS(s: 12),
              ),
            ],
          ),
          16.h,
          Ro(
            m: MAA.start,
            children: [
              T(
                S.current.application_settings,
                s: TS(w: FW.w500, c: kB.q(.8), s: 12),
              ),
            ],
          ),
          8.h,
          FormItem(
            isSectionStart: true,
            icon: Icon(Icons.format_size_outlined, color: kB.q(.667), size: 16),
            title: S.current.font_size,
            info: "${P.preference.textScalePairs[preferredTextScaleFactor]}",
            onTap: P.preference.showTextScaleFactorDialog,
          ),
          FormItem(
            isSectionEnd: true,
            icon: Icon(Icons.language_outlined, color: kB.q(.667), size: 16),
            title: S.current.application_language,
            info: preferredLanguage.display ?? S.current.follow_system,
            onTap: P.preference.showLocaleDialog,
          ),
          12.h,
          Ro(
            m: MAA.start,
            children: [
              T(
                S.current.join_the_community,
                s: TS(w: FW.w500, c: kB.q(.8), s: 12),
              ),
            ],
          ),
          8.h,
          FormItem(
            icon: Icon(Icons.chat_bubble_outline, color: kB.q(.667), size: 16),
            isSectionStart: true,
            title: S.current.qq_group_1,
            subtitle: "${S.current.application_internal_test_group}: 332381861",
            onTap: _openQQGroup1,
          ),
          FormItem(
            icon: Icon(Icons.chat_bubble_outline, color: kB.q(.667), size: 16),
            title: S.current.qq_group_2,
            subtitle: "${S.current.technical_research_group}: 325154699",
            onTap: _openQQGroup2,
          ),
          FormItem(
            icon: Icon(Icons.chat_bubble_outline, color: kB.q(.667), size: 16),
            title: S.current.discord,
            subtitle: S.current.join_our_discord_server,
            onTap: _openDiscord,
          ),
          FormItem(
            isSectionEnd: true,
            icon: Icon(Icons.tag, color: kB.q(.667), size: 16),
            title: S.current.twitter,
            subtitle: "@BlinkDL_AI",
            onTap: _openTwitter,
          ),
          12.h,
          Ro(
            m: MAA.start,
            children: [
              T(
                S.current.about,
                s: TS(w: FW.w500, c: kB.q(.8), s: 12),
              ),
            ],
          ),
          8.h,
          FormItem(
            isSectionStart: true,
            title: S.current.feedback,
            icon: Icon(Icons.feedback_outlined, color: kB.q(.667), size: 16),
            onTap: _openFeedback,
          ),
          FormItem(
            isSectionEnd: true,
            title: S.current.license,
            icon: Icon(Icons.contact_page_outlined, color: kB.q(.667), size: 16),
            onTap: () => _showLicensePage(context, version, buildNumber, iconWidget),
          ),
          paddingBottom.h,
        ],
      ),
    );
  }

  void _openQQGroup1() async {
    qq;
    final mqqapiString = "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=332381861&card_type=group";
    if (await canLaunchUrl(Uri.parse(mqqapiString))) {
      launchUrl(Uri.parse(mqqapiString));
    } else {
      launchUrlString("https://qm.qq.com/q/y0gOHcguty", mode: LaunchMode.externalApplication);
    }
  }

  void _openQQGroup2() async {
    final mqqapiString = "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=325154699&card_type=group";
    if (await canLaunchUrl(Uri.parse(mqqapiString))) {
      launchUrl(Uri.parse(mqqapiString));
    } else {
      launchUrlString("https://qm.qq.com/q/YqveLmzFYG", mode: LaunchMode.externalApplication);
    }
  }

  void _openDiscord() {
    launchUrlString("https://discord.gg/8NvyXcAP5W", mode: LaunchMode.externalApplication);
  }

  void _openTwitter() {
    launchUrlString("https://x.com/BlinkDL_AI?mx=2", mode: LaunchMode.externalApplication);
  }

  void _openFeedback() {
    launchUrlString("https://community.rwkv.cn/", mode: LaunchMode.externalApplication);
  }

  void _showLicensePage(
    BuildContext context,
    String version,
    String buildNumber,
    Widget iconWidget,
  ) {
    showLicensePage(
      context: context,
      applicationName: Config.appTitle,
      applicationVersion: "$version ($buildNumber)",
      applicationIcon: C(
        margin: const EI.o(t: 12, b: 12),
        child: iconWidget,
      ),
      useRootNavigator: true,
    );
  }
}
