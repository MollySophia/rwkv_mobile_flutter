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

  /// `RWKV Chat`
  String get chat_title {
    return Intl.message('RWKV Chat', name: 'chat_title', desc: '', args: []);
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

  /// `Message RWKV`
  String get send_message_to_rwkv {
    return Intl.message(
      'Message RWKV',
      name: 'send_message_to_rwkv',
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

  /// `Welcome to explore RWKV Chat`
  String get chat_welcome_to_use {
    return Intl.message(
      'Welcome to explore RWKV Chat',
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

  /// `You need to download the model first, before you can use it.`
  String get chat_you_need_download_model_if_you_want_to_use_it {
    return Intl.message(
      'You need to download the model first, before you can use it.',
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

  /// `RWKV Othello`
  String get rwkv_othello {
    return Intl.message(
      'RWKV Othello',
      name: 'rwkv_othello',
      desc: '',
      args: [],
    );
  }

  /// `RWKV Chat`
  String get rwkv_chat {
    return Intl.message('RWKV Chat', name: 'rwkv_chat', desc: '', args: []);
  }

  /// `You can start a new chat by clicking the button below.`
  String get start_a_new_chat_by_clicking_the_button_below {
    return Intl.message(
      'You can start a new chat by clicking the button below.',
      name: 'start_a_new_chat_by_clicking_the_button_below',
      desc: '',
      args: [],
    );
  }

  /// `Get ready to experience RWKV-x070-World, series of compact language models with 0.1, 0.4, 1.5, 3.0 billion parameters, optimized for seamless mobile devices inference. Once loaded, it functions offline without requiring any server communication.`
  String get intro {
    return Intl.message(
      'Get ready to experience RWKV-x070-World, series of compact language models with 0.1, 0.4, 1.5, 3.0 billion parameters, optimized for seamless mobile devices inference. Once loaded, it functions offline without requiring any server communication.',
      name: 'intro',
      desc: '',
      args: [],
    );
  }

  /// `Select a model`
  String get select_a_model {
    return Intl.message(
      'Select a model',
      name: 'select_a_model',
      desc: '',
      args: [],
    );
  }

  /// `You are now using {modelName}`
  String you_are_now_using(Object modelName) {
    return Intl.message(
      'You are now using $modelName',
      name: 'you_are_now_using',
      desc: '',
      args: [modelName],
    );
  }

  /// `Click here to start a new chat`
  String get click_here_to_start_a_new_chat {
    return Intl.message(
      'Click here to start a new chat',
      name: 'click_here_to_start_a_new_chat',
      desc: '',
      args: [],
    );
  }

  /// `Click here to select a new model.`
  String get click_here_to_select_a_new_model {
    return Intl.message(
      'Click here to select a new model.',
      name: 'click_here_to_select_a_new_model',
      desc: '',
      args: [],
    );
  }

  /// `Please ensure you have enough memory to load the model, otherwise the application may crash.`
  String get ensure_you_have_enough_memory_to_load_the_model {
    return Intl.message(
      'Please ensure you have enough memory to load the model, otherwise the application may crash.',
      name: 'ensure_you_have_enough_memory_to_load_the_model',
      desc: '',
      args: [],
    );
  }

  /// `Memory used: {memUsed}, Memory free: {memFree}`
  String memory_used(Object memUsed, Object memFree) {
    return Intl.message(
      'Memory used: $memUsed, Memory free: $memFree',
      name: 'memory_used',
      desc: '',
      args: [memUsed, memFree],
    );
  }

  /// `You can select a role to chat`
  String get you_can_select_a_role_to_chat {
    return Intl.message(
      'You can select a role to chat',
      name: 'you_can_select_a_role_to_chat',
      desc: '',
      args: [],
    );
  }

  /// `New chat`
  String get new_chat {
    return Intl.message('New chat', name: 'new_chat', desc: '', args: []);
  }

  /// `Or you can start a new empty chat`
  String get or_you_can_start_a_new_empty_chat {
    return Intl.message(
      'Or you can start a new empty chat',
      name: 'or_you_can_start_a_new_empty_chat',
      desc: '',
      args: [],
    );
  }

  /// `Start a new chat`
  String get start_a_new_chat {
    return Intl.message(
      'Start a new chat',
      name: 'start_a_new_chat',
      desc: '',
      args: [],
    );
  }

  /// `You can now start to chat with RWKV`
  String get you_can_now_start_to_chat_with_rwkv {
    return Intl.message(
      'You can now start to chat with RWKV',
      name: 'you_can_now_start_to_chat_with_rwkv',
      desc: '',
      args: [],
    );
  }

  /// `Bot message edited, you can now send new message`
  String get bot_message_edited {
    return Intl.message(
      'Bot message edited, you can now send new message',
      name: 'bot_message_edited',
      desc: '',
      args: [],
    );
  }

  /// `Download source`
  String get download_source {
    return Intl.message(
      'Download source',
      name: 'download_source',
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
