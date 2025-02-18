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

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
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
    "chat_title": MessageLookupByLibrary.simpleMessage("RWKV World v7"),
    "chat_title_placeholder": MessageLookupByLibrary.simpleMessage(
      "Enter your message...",
    ),
    "chat_welcome_to_use": MessageLookupByLibrary.simpleMessage(
      "Welcome to explore RWKV World v7",
    ),
    "chat_you_need_download_model_if_you_want_to_use_it":
        MessageLookupByLibrary.simpleMessage(
          "You need to download the model first, before you can use it",
        ),
    "chatting": MessageLookupByLibrary.simpleMessage("Chatting"),
    "choose_prebuilt_character": MessageLookupByLibrary.simpleMessage(
      "Choose prebuilt character",
    ),
    "download_model": MessageLookupByLibrary.simpleMessage("Download model"),
    "foo_bar": MessageLookupByLibrary.simpleMessage("foo bar"),
    "othello_title": MessageLookupByLibrary.simpleMessage("RWKV Othello"),
    "start_to_chat": MessageLookupByLibrary.simpleMessage("Start to chat"),
    "use_it_now": MessageLookupByLibrary.simpleMessage("Use it now"),
    "welcome_to_use_rwkv": MessageLookupByLibrary.simpleMessage(
      "Welcome to use RWKV",
    ),
  };
}
