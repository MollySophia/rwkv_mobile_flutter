// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(memUsed, memFree) =>
      "Memory used: ${memUsed}, Memory free: ${memFree}";

  static String m1(modelName) => "You are now using ${modelName}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "bot_message_edited": MessageLookupByLibrary.simpleMessage(
      "Bot message edited, you can now send new message",
    ),
    "chat_copied_to_clipboard": MessageLookupByLibrary.simpleMessage(
      "Copied to clipboard",
    ),
    "chat_empty_message": MessageLookupByLibrary.simpleMessage(
      "Please enter a message",
    ),
    "chat_model_name": MessageLookupByLibrary.simpleMessage("Model name"),
    "chat_please_select_a_model": MessageLookupByLibrary.simpleMessage(
      "Please select a model",
    ),
    "chat_title": MessageLookupByLibrary.simpleMessage("RWKV Chat"),
    "chat_welcome_to_use": MessageLookupByLibrary.simpleMessage(
      "Welcome to explore RWKV Chat",
    ),
    "chat_you_need_download_model_if_you_want_to_use_it":
        MessageLookupByLibrary.simpleMessage(
          "You need to download the model first, before you can use it.",
        ),
    "chatting": MessageLookupByLibrary.simpleMessage("Chatting"),
    "choose_prebuilt_character": MessageLookupByLibrary.simpleMessage(
      "Choose prebuilt character",
    ),
    "click_here_to_select_a_new_model": MessageLookupByLibrary.simpleMessage(
      "Click here to select a new model.",
    ),
    "click_here_to_start_a_new_chat": MessageLookupByLibrary.simpleMessage(
      "Click here to start a new chat",
    ),
    "download_model": MessageLookupByLibrary.simpleMessage("Download model"),
    "download_source": MessageLookupByLibrary.simpleMessage("Download source"),
    "ensure_you_have_enough_memory_to_load_the_model":
        MessageLookupByLibrary.simpleMessage(
          "Please ensure you have enough memory to load the model, otherwise the application may crash.",
        ),
    "foo_bar": MessageLookupByLibrary.simpleMessage("foo bar"),
    "intro": MessageLookupByLibrary.simpleMessage(
      "Get ready to experience RWKV-x070-World, series of compact language models with 0.1, 0.4, 1.5, 3.0 billion parameters, optimized for seamless mobile devices inference. Once loaded, it functions offline without requiring any server communication.",
    ),
    "memory_used": m0,
    "new_chat": MessageLookupByLibrary.simpleMessage("New chat"),
    "or_you_can_start_a_new_empty_chat": MessageLookupByLibrary.simpleMessage(
      "Or you can start a new empty chat",
    ),
    "othello_title": MessageLookupByLibrary.simpleMessage("RWKV Othello"),
    "rwkv_chat": MessageLookupByLibrary.simpleMessage("RWKV Chat"),
    "rwkv_othello": MessageLookupByLibrary.simpleMessage("RWKV Othello"),
    "select_a_model": MessageLookupByLibrary.simpleMessage("Select a model"),
    "send_message_to_rwkv": MessageLookupByLibrary.simpleMessage(
      "Message RWKV",
    ),
    "start_a_new_chat": MessageLookupByLibrary.simpleMessage(
      "Start a new chat",
    ),
    "start_a_new_chat_by_clicking_the_button_below":
        MessageLookupByLibrary.simpleMessage(
          "You can start a new chat by clicking the button below.",
        ),
    "start_to_chat": MessageLookupByLibrary.simpleMessage("Start to chat"),
    "use_it_now": MessageLookupByLibrary.simpleMessage("Use it now"),
    "welcome_to_use_rwkv": MessageLookupByLibrary.simpleMessage(
      "Welcome to use RWKV",
    ),
    "you_are_now_using": m1,
    "you_can_now_start_to_chat_with_rwkv": MessageLookupByLibrary.simpleMessage(
      "You can now start to chat with RWKV",
    ),
    "you_can_select_a_role_to_chat": MessageLookupByLibrary.simpleMessage(
      "You can select a role to chat",
    ),
  };
}
