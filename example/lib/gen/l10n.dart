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
    return Intl.message(
      'RWKV Chat',
      name: 'chat_title',
      desc: 'Title of the chat screen',
      args: [],
    );
  }

  /// `RWKV Othello`
  String get othello_title {
    return Intl.message(
      'RWKV Othello',
      name: 'othello_title',
      desc: 'Title of the othello game',
      args: [],
    );
  }

  /// `Message RWKV`
  String get send_message_to_rwkv {
    return Intl.message(
      'Message RWKV',
      name: 'send_message_to_rwkv',
      desc: 'Placeholder for the message input field',
      args: [],
    );
  }

  /// `Copied to clipboard`
  String get chat_copied_to_clipboard {
    return Intl.message(
      'Copied to clipboard',
      name: 'chat_copied_to_clipboard',
      desc:
          'Message displayed when the chat content is copied to the clipboard',
      args: [],
    );
  }

  /// `Please enter a message`
  String get chat_empty_message {
    return Intl.message(
      'Please enter a message',
      name: 'chat_empty_message',
      desc: 'Placeholder for the message input field',
      args: [],
    );
  }

  /// `Welcome to explore {demoName}`
  String chat_welcome_to_use(String demoName) {
    return Intl.message(
      'Welcome to explore $demoName',
      name: 'chat_welcome_to_use',
      desc: 'Welcome message for the chat demo',
      args: [demoName],
    );
  }

  /// `Please select a model`
  String get chat_please_select_a_model {
    return Intl.message(
      'Please select a model',
      name: 'chat_please_select_a_model',
      desc: 'Placeholder for the model selection dropdown',
      args: [],
    );
  }

  /// `You need to download the model first, before you can use it.`
  String get chat_you_need_download_model_if_you_want_to_use_it {
    return Intl.message(
      'You need to download the model first, before you can use it.',
      name: 'chat_you_need_download_model_if_you_want_to_use_it',
      desc: 'Message displayed when the model needs to be downloaded',
      args: [],
    );
  }

  /// `Download model`
  String get download_model {
    return Intl.message(
      'Download model',
      name: 'download_model',
      desc: 'Button text for downloading the model',
      args: [],
    );
  }

  /// `Use it now`
  String get use_it_now {
    return Intl.message(
      'Use it now',
      name: 'use_it_now',
      desc: 'Button text for using the model',
      args: [],
    );
  }

  /// `Choose prebuilt character`
  String get choose_prebuilt_character {
    return Intl.message(
      'Choose prebuilt character',
      name: 'choose_prebuilt_character',
      desc: 'Button text for choosing a prebuilt character',
      args: [],
    );
  }

  /// `Start to chat`
  String get start_to_chat {
    return Intl.message(
      'Start to chat',
      name: 'start_to_chat',
      desc: 'Button text for starting a chat',
      args: [],
    );
  }

  /// `Model name`
  String get chat_model_name {
    return Intl.message(
      'Model name',
      name: 'chat_model_name',
      desc: 'Label for the model name',
      args: [],
    );
  }

  /// `foo bar`
  String get foo_bar {
    return Intl.message(
      'foo bar',
      name: 'foo_bar',
      desc: 'Example of a placeholder',
      args: [],
    );
  }

  /// `Chatting`
  String get chatting {
    return Intl.message(
      'Chatting',
      name: 'chatting',
      desc: 'Label for the chatting section',
      args: [],
    );
  }

  /// `Welcome to use RWKV`
  String get welcome_to_use_rwkv {
    return Intl.message(
      'Welcome to use RWKV',
      name: 'welcome_to_use_rwkv',
      desc: 'Welcome message for the chat demo',
      args: [],
    );
  }

  /// `RWKV Othello`
  String get rwkv_othello {
    return Intl.message(
      'RWKV Othello',
      name: 'rwkv_othello',
      desc: 'Label for the othello game',
      args: [],
    );
  }

  /// `RWKV Chat`
  String get rwkv_chat {
    return Intl.message(
      'RWKV Chat',
      name: 'rwkv_chat',
      desc: 'Label for the chat demo',
      args: [],
    );
  }

  /// `You can start a new chat by clicking the button below.`
  String get start_a_new_chat_by_clicking_the_button_below {
    return Intl.message(
      'You can start a new chat by clicking the button below.',
      name: 'start_a_new_chat_by_clicking_the_button_below',
      desc: 'Helper text explaining how to start a new chat',
      args: [],
    );
  }

  /// `Get ready to experience RWKV v7, series of compact language models with 0.1, 0.4, 1.5, 2.9 billion parameters, optimized for seamless mobile devices inference. Once loaded, it functions offline without requiring any server communication.`
  String get intro {
    return Intl.message(
      'Get ready to experience RWKV v7, series of compact language models with 0.1, 0.4, 1.5, 2.9 billion parameters, optimized for seamless mobile devices inference. Once loaded, it functions offline without requiring any server communication.',
      name: 'intro',
      desc: 'Introduction text explaining RWKV v7 capabilities',
      args: [],
    );
  }

  /// `Select a model`
  String get select_a_model {
    return Intl.message(
      'Select a model',
      name: 'select_a_model',
      desc: 'Label for model selection action',
      args: [],
    );
  }

  /// `You are now using {modelName}`
  String you_are_now_using(String modelName) {
    return Intl.message(
      'You are now using $modelName',
      name: 'you_are_now_using',
      desc: 'Message indicating which model is currently in use',
      args: [modelName],
    );
  }

  /// `Click here to start a new chat`
  String get click_here_to_start_a_new_chat {
    return Intl.message(
      'Click here to start a new chat',
      name: 'click_here_to_start_a_new_chat',
      desc: 'Call to action for starting a new chat',
      args: [],
    );
  }

  /// `Click here to select a new model.`
  String get click_here_to_select_a_new_model {
    return Intl.message(
      'Click here to select a new model.',
      name: 'click_here_to_select_a_new_model',
      desc: 'Call to action for selecting a new model',
      args: [],
    );
  }

  /// `Please ensure you have enough memory to load the model, otherwise the application may crash.`
  String get ensure_you_have_enough_memory_to_load_the_model {
    return Intl.message(
      'Please ensure you have enough memory to load the model, otherwise the application may crash.',
      name: 'ensure_you_have_enough_memory_to_load_the_model',
      desc: 'Warning message about memory requirements',
      args: [],
    );
  }

  /// `Memory used: {memUsed}, Memory free: {memFree}`
  String memory_used(String memUsed, String memFree) {
    return Intl.message(
      'Memory used: $memUsed, Memory free: $memFree',
      name: 'memory_used',
      desc: 'Display of memory usage statistics',
      args: [memUsed, memFree],
    );
  }

  /// `You can select a role to chat`
  String get you_can_select_a_role_to_chat {
    return Intl.message(
      'You can select a role to chat',
      name: 'you_can_select_a_role_to_chat',
      desc: 'Instruction for role selection in chat',
      args: [],
    );
  }

  /// `New chat`
  String get new_chat {
    return Intl.message(
      'New chat',
      name: 'new_chat',
      desc: 'Label for starting a new chat',
      args: [],
    );
  }

  /// `Or you can start a new empty chat`
  String get or_you_can_start_a_new_empty_chat {
    return Intl.message(
      'Or you can start a new empty chat',
      name: 'or_you_can_start_a_new_empty_chat',
      desc: 'Alternative option to start an empty chat',
      args: [],
    );
  }

  /// `Start a new chat`
  String get start_a_new_chat {
    return Intl.message(
      'Start a new chat',
      name: 'start_a_new_chat',
      desc: 'Button label for starting a new chat',
      args: [],
    );
  }

  /// `You can now start to chat with RWKV`
  String get you_can_now_start_to_chat_with_rwkv {
    return Intl.message(
      'You can now start to chat with RWKV',
      name: 'you_can_now_start_to_chat_with_rwkv',
      desc: 'Confirmation message that chat is ready to begin',
      args: [],
    );
  }

  /// `Bot message edited, you can now send new message`
  String get bot_message_edited {
    return Intl.message(
      'Bot message edited, you can now send new message',
      name: 'bot_message_edited',
      desc: 'Notification that bot\'s message has been edited',
      args: [],
    );
  }

  /// `Download source`
  String get download_source {
    return Intl.message(
      'Download source',
      name: 'download_source',
      desc: 'Label for downloading source content',
      args: [],
    );
  }

  /// `Select a world type`
  String get select_a_world_type {
    return Intl.message(
      'Select a world type',
      name: 'select_a_world_type',
      desc: 'Label for world type selection',
      args: [],
    );
  }

  /// `Please select a world type`
  String get please_select_a_world_type {
    return Intl.message(
      'Please select a world type',
      name: 'please_select_a_world_type',
      desc: 'Prompt to select a world type',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: 'Label for loading state',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'Label for cancel action',
      args: [],
    );
  }

  /// `Session Configuration`
  String get session_configuration {
    return Intl.message(
      'Session Configuration',
      name: 'session_configuration',
      desc: 'Label for session configuration',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: 'Label for apply action',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: 'Label for reset action',
      args: [],
    );
  }

  /// `Auto`
  String get auto {
    return Intl.message(
      'Auto',
      name: 'auto',
      desc: 'Label for auto action',
      args: [],
    );
  }

  /// `Create a new one by clicking the button above.`
  String get create_a_new_one_by_clicking_the_button_above {
    return Intl.message(
      'Create a new one by clicking the button above.',
      name: 'create_a_new_one_by_clicking_the_button_above',
      desc: 'Helper text explaining how to create a new chat',
      args: [],
    );
  }

  /// `Speed:`
  String get speed {
    return Intl.message(
      'Speed:',
      name: 'speed',
      desc: 'Label for speed',
      args: [],
    );
  }

  /// `Remaining:`
  String get remaining {
    return Intl.message(
      'Remaining:',
      name: 'remaining',
      desc: 'Label for remaining',
      args: [],
    );
  }

  /// `Prefer Chinese`
  String get prefer_chinese {
    return Intl.message(
      'Prefer Chinese',
      name: 'prefer_chinese',
      desc: 'Label for prefer Chinese',
      args: [],
    );
  }

  /// `Please wait for the model to load`
  String get please_wait_for_the_model_to_load {
    return Intl.message(
      'Please wait for the model to load',
      name: 'please_wait_for_the_model_to_load',
      desc: 'Message displayed when the model needs to be loaded',
      args: [],
    );
  }

  /// `Please wait for the model to finish generating`
  String get please_wait_for_the_model_to_finish_generating {
    return Intl.message(
      'Please wait for the model to finish generating',
      name: 'please_wait_for_the_model_to_finish_generating',
      desc: 'Message displayed when the model needs to finish generating',
      args: [],
    );
  }

  /// `Reason`
  String get reason {
    return Intl.message(
      'Reason',
      name: 'reason',
      desc: 'Label for reason',
      args: [],
    );
  }

  /// `Reasoning enabled`
  String get reasoning_enabled {
    return Intl.message(
      'Reasoning enabled',
      name: 'reasoning_enabled',
      desc: 'Message displayed when reasoning is enabled',
      args: [],
    );
  }

  /// `Click to select a model`
  String get click_to_select_model {
    return Intl.message(
      'Click to select a model',
      name: 'click_to_select_model',
      desc: 'Label for click to select a model',
      args: [],
    );
  }

  /// `Are you sure you want to delete this model?`
  String get are_you_sure_you_want_to_delete_this_model {
    return Intl.message(
      'Are you sure you want to delete this model?',
      name: 'are_you_sure_you_want_to_delete_this_model',
      desc: 'Label for delete model',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: 'Label for delete action',
      args: [],
    );
  }

  /// `Prefer`
  String get prefer {
    return Intl.message(
      'Prefer',
      name: 'prefer',
      desc: 'Label for prefer',
      args: [],
    );
  }

  /// `Chinese`
  String get chinese {
    return Intl.message(
      'Chinese',
      name: 'chinese',
      desc: 'Label for chinese',
      args: [],
    );
  }

  /// `Thinking...`
  String get thinking {
    return Intl.message(
      'Thinking...',
      name: 'thinking',
      desc: 'Label for thinking',
      args: [],
    );
  }

  /// `Thought result`
  String get thought_result {
    return Intl.message(
      'Thought result',
      name: 'thought_result',
      desc: 'Label for thought result',
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
