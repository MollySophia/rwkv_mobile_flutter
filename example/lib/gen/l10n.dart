// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `RWKV World v7`
  String get chat_title {
    return Intl.message(
      'RWKV World v7',
      name: 'chat_title',
      desc: '',
      args: [],
    );
  }

  /// `RWKV Othello`
  String get othello_title {
    return Intl.message(
      'RWKV Othello',
      name: 'othello_title',
      desc: '',
      args: [],
    );
  }

  /// `Enter your message...`
  String get chat_title_placeholder {
    return Intl.message(
      'Enter your message...',
      name: 'chat_title_placeholder',
      desc: '',
      args: [],
    );
  }

  /// `Copied to clipboard`
  String get chat_copied_to_clipboard {
    return Intl.message(
      'Copied to clipboard',
      name: 'chat_copied_to_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a message`
  String get chat_empty_message {
    return Intl.message(
      'Please enter a message',
      name: 'chat_empty_message',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to explore RWKV World v7`
  String get chat_welcome_to_use {
    return Intl.message(
      'Welcome to explore RWKV World v7',
      name: 'chat_welcome_to_use',
      desc: '',
      args: [],
    );
  }

  /// `Please select a model`
  String get chat_please_select_a_model {
    return Intl.message(
      'Please select a model',
      name: 'chat_please_select_a_model',
      desc: '',
      args: [],
    );
  }

  /// `You need to download the model first, before you can use it`
  String get chat_you_need_download_model_if_you_want_to_use_it {
    return Intl.message(
      'You need to download the model first, before you can use it',
      name: 'chat_you_need_download_model_if_you_want_to_use_it',
      desc: '',
      args: [],
    );
  }

  /// `Download model`
  String get download_model {
    return Intl.message(
      'Download model',
      name: 'download_model',
      desc: '',
      args: [],
    );
  }

  /// `Use it now`
  String get use_it_now {
    return Intl.message('Use it now', name: 'use_it_now', desc: '', args: []);
  }

  /// `Choose prebuilt character`
  String get choose_prebuilt_character {
    return Intl.message(
      'Choose prebuilt character',
      name: 'choose_prebuilt_character',
      desc: '',
      args: [],
    );
  }

  /// `Start to chat`
  String get start_to_chat {
    return Intl.message(
      'Start to chat',
      name: 'start_to_chat',
      desc: '',
      args: [],
    );
  }

  /// `Model name`
  String get chat_model_name {
    return Intl.message(
      'Model name',
      name: 'chat_model_name',
      desc: '',
      args: [],
    );
  }

  /// `foo bar`
  String get foo_bar {
    return Intl.message('foo bar', name: 'foo_bar', desc: '', args: []);
  }

  /// `Chatting`
  String get chatting {
    return Intl.message('Chatting', name: 'chatting', desc: '', args: []);
  }

  /// `Welcome to use RWKV`
  String get welcome_to_use_rwkv {
    return Intl.message(
      'Welcome to use RWKV',
      name: 'welcome_to_use_rwkv',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
