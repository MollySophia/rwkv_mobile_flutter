// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ko locale. All the
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
  String get localeName => 'ko';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "chat_copied_to_clipboard": MessageLookupByLibrary.simpleMessage(
      "클립보드에 복사됨",
    ),
    "chat_empty_message": MessageLookupByLibrary.simpleMessage("메시지를 입력하세요"),
    "chat_title": MessageLookupByLibrary.simpleMessage("RWKV World v7"),
    "chat_title_placeholder": MessageLookupByLibrary.simpleMessage(
      "메시지를 입력하세요...",
    ),
    "othello_title": MessageLookupByLibrary.simpleMessage("RWKV 흑백 체스"),
  };
}
