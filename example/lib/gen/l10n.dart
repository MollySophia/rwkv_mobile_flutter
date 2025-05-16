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

  /// `Welcome to explore {demoName}`
  String chat_welcome_to_use(Object demoName) {
    return Intl.message(
      'Welcome to explore $demoName',
      name: 'chat_welcome_to_use',
      desc: '',
      args: [demoName],
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

  /// `Get ready to experience RWKV v7, series of compact language models with 0.1, 0.4, 1.5, 2.9 billion parameters, optimized for seamless mobile devices inference. Once loaded, it functions offline without requiring any server communication.`
  String get intro {
    return Intl.message(
      'Get ready to experience RWKV v7, series of compact language models with 0.1, 0.4, 1.5, 2.9 billion parameters, optimized for seamless mobile devices inference. Once loaded, it functions offline without requiring any server communication.',
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

  /// `Select a world type`
  String get select_a_world_type {
    return Intl.message(
      'Select a world type',
      name: 'select_a_world_type',
      desc: '',
      args: [],
    );
  }

  /// `Please select a world type`
  String get please_select_a_world_type {
    return Intl.message(
      'Please select a world type',
      name: 'please_select_a_world_type',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Session Configuration`
  String get session_configuration {
    return Intl.message(
      'Session Configuration',
      name: 'session_configuration',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `Reset`
  String get reset {
    return Intl.message('Reset', name: 'reset', desc: '', args: []);
  }

  /// `Auto`
  String get auto {
    return Intl.message('Auto', name: 'auto', desc: '', args: []);
  }

  /// `Create a new one by clicking the button above.`
  String get create_a_new_one_by_clicking_the_button_above {
    return Intl.message(
      'Create a new one by clicking the button above.',
      name: 'create_a_new_one_by_clicking_the_button_above',
      desc: '',
      args: [],
    );
  }

  /// `Speed:`
  String get speed {
    return Intl.message('Speed:', name: 'speed', desc: '', args: []);
  }

  /// `Remaining:`
  String get remaining {
    return Intl.message('Remaining:', name: 'remaining', desc: '', args: []);
  }

  /// `Prefer Chinese`
  String get prefer_chinese {
    return Intl.message(
      'Prefer Chinese',
      name: 'prefer_chinese',
      desc: '',
      args: [],
    );
  }

  /// `Reasoning enabled`
  String get reasoning_enabled {
    return Intl.message(
      'Reasoning enabled',
      name: 'reasoning_enabled',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for the model to load`
  String get please_wait_for_the_model_to_load {
    return Intl.message(
      'Please wait for the model to load',
      name: 'please_wait_for_the_model_to_load',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for the model to finish generating`
  String get please_wait_for_the_model_to_finish_generating {
    return Intl.message(
      'Please wait for the model to finish generating',
      name: 'please_wait_for_the_model_to_finish_generating',
      desc: '',
      args: [],
    );
  }

  /// `Reason`
  String get reason {
    return Intl.message('Reason', name: 'reason', desc: '', args: []);
  }

  /// `Click to select a model`
  String get click_to_select_model {
    return Intl.message(
      'Click to select a model',
      name: 'click_to_select_model',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this model?`
  String get are_you_sure_you_want_to_delete_this_model {
    return Intl.message(
      'Are you sure you want to delete this model?',
      name: 'are_you_sure_you_want_to_delete_this_model',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Prefer`
  String get prefer {
    return Intl.message('Prefer', name: 'prefer', desc: '', args: []);
  }

  /// `Chinese`
  String get chinese {
    return Intl.message('Chinese', name: 'chinese', desc: '', args: []);
  }

  /// `Thinking...`
  String get thinking {
    return Intl.message('Thinking...', name: 'thinking', desc: '', args: []);
  }

  /// `Thought result`
  String get thought_result {
    return Intl.message(
      'Thought result',
      name: 'thought_result',
      desc: '',
      args: [],
    );
  }

  /// `Resume`
  String get chat_resume {
    return Intl.message('Resume', name: 'chat_resume', desc: '', args: []);
  }

  /// `Network error`
  String get network_error {
    return Intl.message(
      'Network error',
      name: 'network_error',
      desc: '',
      args: [],
    );
  }

  /// `Server error`
  String get server_error {
    return Intl.message(
      'Server error',
      name: 'server_error',
      desc: '',
      args: [],
    );
  }

  /// `New version found`
  String get new_version_found {
    return Intl.message(
      'New version found',
      name: 'new_version_found',
      desc: '',
      args: [],
    );
  }

  /// `Cancel update`
  String get cancel_update {
    return Intl.message(
      'Cancel update',
      name: 'cancel_update',
      desc: '',
      args: [],
    );
  }

  /// `Update now`
  String get update_now {
    return Intl.message('Update now', name: 'update_now', desc: '', args: []);
  }

  /// `Back to Chat`
  String get back_to_chat {
    return Intl.message(
      'Back to Chat',
      name: 'back_to_chat',
      desc: '',
      args: [],
    );
  }

  /// `Delete all`
  String get delete_all {
    return Intl.message('Delete all', name: 'delete_all', desc: '', args: []);
  }

  /// `Download missing files`
  String get download_missing {
    return Intl.message(
      'Download missing files',
      name: 'download_missing',
      desc: '',
      args: [],
    );
  }

  /// `Exploring...`
  String get exploring {
    return Intl.message('Exploring...', name: 'exploring', desc: '', args: []);
  }

  /// `I want RWKV to say...`
  String get i_want_rwkv_to_say {
    return Intl.message(
      'I want RWKV to say...',
      name: 'i_want_rwkv_to_say',
      desc: '',
      args: [],
    );
  }

  /// `Voice cloning`
  String get voice_cloning {
    return Intl.message(
      'Voice cloning',
      name: 'voice_cloning',
      desc: '',
      args: [],
    );
  }

  /// `Prebuilt voices`
  String get prebuilt_voices {
    return Intl.message(
      'Prebuilt voices',
      name: 'prebuilt_voices',
      desc: '',
      args: [],
    );
  }

  /// `Intonations`
  String get intonations {
    return Intl.message('Intonations', name: 'intonations', desc: '', args: []);
  }

  /// `System`
  String get follow_system {
    return Intl.message('System', name: 'follow_system', desc: '', args: []);
  }

  /// `Language`
  String get application_language {
    return Intl.message(
      'Language',
      name: 'application_language',
      desc: '',
      args: [],
    );
  }

  /// `Please select application language`
  String get please_select_application_language {
    return Intl.message(
      'Please select application language',
      name: 'please_select_application_language',
      desc: '',
      args: [],
    );
  }

  /// `Please select font size`
  String get please_select_font_size {
    return Intl.message(
      'Please select font size',
      name: 'please_select_font_size',
      desc: '',
      args: [],
    );
  }

  /// `Font size`
  String get font_size {
    return Intl.message('Font size', name: 'font_size', desc: '', args: []);
  }

  /// `Font setting`
  String get font_setting {
    return Intl.message(
      'Font setting',
      name: 'font_setting',
      desc: '',
      args: [],
    );
  }

  /// `Very small (80%)`
  String get very_small {
    return Intl.message(
      'Very small (80%)',
      name: 'very_small',
      desc: '',
      args: [],
    );
  }

  /// `Small (90%)`
  String get small {
    return Intl.message('Small (90%)', name: 'small', desc: '', args: []);
  }

  /// `Default (100%)`
  String get font_size_default {
    return Intl.message(
      'Default (100%)',
      name: 'font_size_default',
      desc: '',
      args: [],
    );
  }

  /// `Medium (110%)`
  String get medium {
    return Intl.message('Medium (110%)', name: 'medium', desc: '', args: []);
  }

  /// `Large (120%)`
  String get large {
    return Intl.message('Large (120%)', name: 'large', desc: '', args: []);
  }

  /// `Extra large (130%)`
  String get extra_large {
    return Intl.message(
      'Extra large (130%)',
      name: 'extra_large',
      desc: '',
      args: [],
    );
  }

  /// `Ultra large (140%)`
  String get ultra_large {
    return Intl.message(
      'Ultra large (140%)',
      name: 'ultra_large',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedback {
    return Intl.message('Feedback', name: 'feedback', desc: '', args: []);
  }

  /// `Open source license`
  String get license {
    return Intl.message(
      'Open source license',
      name: 'license',
      desc: '',
      args: [],
    );
  }

  /// `Application settings`
  String get application_settings {
    return Intl.message(
      'Application settings',
      name: 'application_settings',
      desc: '',
      args: [],
    );
  }

  /// `Join the community`
  String get join_the_community {
    return Intl.message(
      'Join the community',
      name: 'join_the_community',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `Target`
  String get imitate_target {
    return Intl.message('Target', name: 'imitate_target', desc: '', args: []);
  }

  /// `Hello, I can't answer this question yet, let's talk about something else.`
  String get filter {
    return Intl.message(
      'Hello, I can\'t answer this question yet, let\'s talk about something else.',
      name: 'filter',
      desc: '',
      args: [],
    );
  }

  /// `Game over!`
  String get game_over {
    return Intl.message('Game over!', name: 'game_over', desc: '', args: []);
  }

  /// `Black wins!`
  String get black_wins {
    return Intl.message('Black wins!', name: 'black_wins', desc: '', args: []);
  }

  /// `White wins!`
  String get white_wins {
    return Intl.message('White wins!', name: 'white_wins', desc: '', args: []);
  }

  /// `Draw!`
  String get draw {
    return Intl.message('Draw!', name: 'draw', desc: '', args: []);
  }

  /// `Black score`
  String get black_score {
    return Intl.message('Black score', name: 'black_score', desc: '', args: []);
  }

  /// `White score`
  String get white_score {
    return Intl.message('White score', name: 'white_score', desc: '', args: []);
  }

  /// `Search Depth`
  String get search_depth {
    return Intl.message(
      'Search Depth',
      name: 'search_depth',
      desc: '',
      args: [],
    );
  }

  /// `Search Breadth`
  String get search_breadth {
    return Intl.message(
      'Search Breadth',
      name: 'search_breadth',
      desc: '',
      args: [],
    );
  }

  /// `White`
  String get white {
    return Intl.message('White', name: 'white', desc: '', args: []);
  }

  /// `Black`
  String get black {
    return Intl.message('Black', name: 'black', desc: '', args: []);
  }

  /// `Human`
  String get human {
    return Intl.message('Human', name: 'human', desc: '', args: []);
  }

  /// `Players`
  String get players {
    return Intl.message('Players', name: 'players', desc: '', args: []);
  }

  /// `Model Settings`
  String get model_settings {
    return Intl.message(
      'Model Settings',
      name: 'model_settings',
      desc: '',
      args: [],
    );
  }

  /// `In-context search will be activated when both breadth and depth are greater than 2`
  String
  get in_context_search_will_be_activated_when_both_breadth_and_depth_are_greater_than_2 {
    return Intl.message(
      'In-context search will be activated when both breadth and depth are greater than 2',
      name:
          'in_context_search_will_be_activated_when_both_breadth_and_depth_are_greater_than_2',
      desc: '',
      args: [],
    );
  }

  /// `New Game`
  String get new_game {
    return Intl.message('New Game', name: 'new_game', desc: '', args: []);
  }

  /// `RWKV`
  String get rwkv {
    return Intl.message('RWKV', name: 'rwkv', desc: '', args: []);
  }

  /// `Prefill`
  String get prefill {
    return Intl.message('Prefill', name: 'prefill', desc: '', args: []);
  }

  /// `Decode`
  String get decode {
    return Intl.message('Decode', name: 'decode', desc: '', args: []);
  }

  /// `Current Turn`
  String get current_turn {
    return Intl.message(
      'Current Turn',
      name: 'current_turn',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start_a_new_game {
    return Intl.message('Start', name: 'start_a_new_game', desc: '', args: []);
  }

  /// `Please wait for the model to generate`
  String get please_wait_for_the_model_to_generate {
    return Intl.message(
      'Please wait for the model to generate',
      name: 'please_wait_for_the_model_to_generate',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Download`
  String get cancel_download {
    return Intl.message(
      'Cancel Download',
      name: 'cancel_download',
      desc: '',
      args: [],
    );
  }

  /// `Continue Download`
  String get continue_download {
    return Intl.message(
      'Continue Download',
      name: 'continue_download',
      desc: '',
      args: [],
    );
  }

  /// `Generate`
  String get generate {
    return Intl.message('Generate', name: 'generate', desc: '', args: []);
  }

  /// `Inference is running`
  String get inference_is_running {
    return Intl.message(
      'Inference is running',
      name: 'inference_is_running',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for it to finish`
  String get please_wait_for_it_to_finish {
    return Intl.message(
      'Please wait for it to finish',
      name: 'please_wait_for_it_to_finish',
      desc: '',
      args: [],
    );
  }

  /// `😎 Just watch me!`
  String get just_watch_me {
    return Intl.message(
      '😎 Just watch me!',
      name: 'just_watch_me',
      desc: '',
      args: [],
    );
  }

  /// `This is the hardest Sudoku in the world`
  String get this_is_the_hardest_sudoku_in_the_world {
    return Intl.message(
      'This is the hardest Sudoku in the world',
      name: 'this_is_the_hardest_sudoku_in_the_world',
      desc: '',
      args: [],
    );
  }

  /// `It's your turn~`
  String get its_your_turn {
    return Intl.message(
      'It\'s your turn~',
      name: 'its_your_turn',
      desc: '',
      args: [],
    );
  }

  /// `Generate Hardest Sudoku in the world`
  String get generate_hardest_sudoku_in_the_world {
    return Intl.message(
      'Generate Hardest Sudoku in the world',
      name: 'generate_hardest_sudoku_in_the_world',
      desc: '',
      args: [],
    );
  }

  /// `Start to Inference`
  String get start_to_inference {
    return Intl.message(
      'Start to Inference',
      name: 'start_to_inference',
      desc: '',
      args: [],
    );
  }

  /// `No puzzle`
  String get no_puzzle {
    return Intl.message('No puzzle', name: 'no_puzzle', desc: '', args: []);
  }

  /// `Hide CoT Stack`
  String get hide_stack {
    return Intl.message(
      'Hide CoT Stack',
      name: 'hide_stack',
      desc: '',
      args: [],
    );
  }

  /// `Show CoT Stack`
  String get show_stack {
    return Intl.message(
      'Show CoT Stack',
      name: 'show_stack',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message('Clear', name: 'clear', desc: '', args: []);
  }

  /// `Set the value of grid`
  String get set_the_value_of_grid {
    return Intl.message(
      'Set the value of grid',
      name: 'set_the_value_of_grid',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a number. 0 means empty.`
  String get please_enter_a_number_0_means_empty {
    return Intl.message(
      'Please enter a number. 0 means empty.',
      name: 'please_enter_a_number_0_means_empty',
      desc: '',
      args: [],
    );
  }

  /// `Invalid value`
  String get invalid_value {
    return Intl.message(
      'Invalid value',
      name: 'invalid_value',
      desc: '',
      args: [],
    );
  }

  /// `Value must be between 0 and 9`
  String get value_must_be_between_0_and_9 {
    return Intl.message(
      'Value must be between 0 and 9',
      name: 'value_must_be_between_0_and_9',
      desc: '',
      args: [],
    );
  }

  /// `Invalid puzzle`
  String get invalid_puzzle {
    return Intl.message(
      'Invalid puzzle',
      name: 'invalid_puzzle',
      desc: '',
      args: [],
    );
  }

  /// `The puzzle is not valid`
  String get the_puzzle_is_not_valid {
    return Intl.message(
      'The puzzle is not valid',
      name: 'the_puzzle_is_not_valid',
      desc: '',
      args: [],
    );
  }

  /// `Difficulty`
  String get difficulty {
    return Intl.message('Difficulty', name: 'difficulty', desc: '', args: []);
  }

  /// `Can not generate`
  String get can_not_generate {
    return Intl.message(
      'Can not generate',
      name: 'can_not_generate',
      desc: '',
      args: [],
    );
  }

  /// `Difficulty must be greater than 0`
  String get difficulty_must_be_greater_than_0 {
    return Intl.message(
      'Difficulty must be greater than 0',
      name: 'difficulty_must_be_greater_than_0',
      desc: '',
      args: [],
    );
  }

  /// `Generate random Sudoku puzzle`
  String get generate_random_sudoku_puzzle {
    return Intl.message(
      'Generate random Sudoku puzzle',
      name: 'generate_random_sudoku_puzzle',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the difficulty`
  String get please_enter_the_difficulty {
    return Intl.message(
      'Please enter the difficulty',
      name: 'please_enter_the_difficulty',
      desc: '',
      args: [],
    );
  }

  /// `Difficulty must be less than 81`
  String get difficulty_must_be_less_than_81 {
    return Intl.message(
      'Difficulty must be less than 81',
      name: 'difficulty_must_be_less_than_81',
      desc: '',
      args: [],
    );
  }

  /// `Number`
  String get number {
    return Intl.message('Number', name: 'number', desc: '', args: []);
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `According to the following audio file`
  String get according_to_the_following_audio_file {
    return Intl.message(
      'According to the following audio file',
      name: 'according_to_the_following_audio_file',
      desc: '',
      args: [],
    );
  }

  /// `QQ Group 1`
  String get qq_group_1 {
    return Intl.message('QQ Group 1', name: 'qq_group_1', desc: '', args: []);
  }

  /// `QQ Group 2`
  String get qq_group_2 {
    return Intl.message('QQ Group 2', name: 'qq_group_2', desc: '', args: []);
  }

  /// `Discord`
  String get discord {
    return Intl.message('Discord', name: 'discord', desc: '', args: []);
  }

  /// `Twitter`
  String get twitter {
    return Intl.message('Twitter', name: 'twitter', desc: '', args: []);
  }

  /// `Application Internal Test Group`
  String get application_internal_test_group {
    return Intl.message(
      'Application Internal Test Group',
      name: 'application_internal_test_group',
      desc: '',
      args: [],
    );
  }

  /// `Technical Research Group`
  String get technical_research_group {
    return Intl.message(
      'Technical Research Group',
      name: 'technical_research_group',
      desc: '',
      args: [],
    );
  }

  /// `Join our Discord server`
  String get join_our_discord_server {
    return Intl.message(
      'Join our Discord server',
      name: 'join_our_discord_server',
      desc: '',
      args: [],
    );
  }

  /// `Follow us on Twitter`
  String get follow_us_on_twitter {
    return Intl.message(
      'Follow us on Twitter',
      name: 'follow_us_on_twitter',
      desc: '',
      args: [],
    );
  }

  /// `Please load model first`
  String get please_load_model_first {
    return Intl.message(
      'Please load model first',
      name: 'please_load_model_first',
      desc: '',
      args: [],
    );
  }

  /// `🎉 Inference is done`
  String get inference_is_done {
    return Intl.message(
      '🎉 Inference is done',
      name: 'inference_is_done',
      desc: '',
      args: [],
    );
  }

  /// `Please check the result`
  String get please_check_the_result {
    return Intl.message(
      'Please check the result',
      name: 'please_check_the_result',
      desc: '',
      args: [],
    );
  }

  /// `Generating...`
  String get generating {
    return Intl.message(
      'Generating...',
      name: 'generating',
      desc: '',
      args: [],
    );
  }

  /// `All done`
  String get all_done {
    return Intl.message('All done', name: 'all_done', desc: '', args: []);
  }

  /// `Playing partial generated audio`
  String get playing_partial_generated_audio {
    return Intl.message(
      'Playing partial generated audio',
      name: 'playing_partial_generated_audio',
      desc: '',
      args: [],
    );
  }

  /// `No cell available`
  String get no_cell_available {
    return Intl.message(
      'No cell available',
      name: 'no_cell_available',
      desc: '',
      args: [],
    );
  }

  /// `Turn transfer`
  String get turn_transfer {
    return Intl.message(
      'Turn transfer',
      name: 'turn_transfer',
      desc: '',
      args: [],
    );
  }

  /// `Continue using smaller model`
  String get continue_using_smaller_model {
    return Intl.message(
      'Continue using smaller model',
      name: 'continue_using_smaller_model',
      desc: '',
      args: [],
    );
  }

  /// `Reselect model`
  String get reselect_model {
    return Intl.message(
      'Reselect model',
      name: 'reselect_model',
      desc: '',
      args: [],
    );
  }

  /// `It is recommended to choose at least a 1.5B model for better performance.`
  String get size_recommendation {
    return Intl.message(
      'It is recommended to choose at least a 1.5B model for better performance.',
      name: 'size_recommendation',
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
