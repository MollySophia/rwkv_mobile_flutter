// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_Hans locale. All the
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
  String get localeName => 'zh_Hans';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "chat_copied_to_clipboard": MessageLookupByLibrary.simpleMessage("已复制到剪贴板"),
    "chat_empty_message": MessageLookupByLibrary.simpleMessage("请输入消息"),
    "chat_model_name": MessageLookupByLibrary.simpleMessage("模型名称"),
    "chat_please_select_a_model": MessageLookupByLibrary.simpleMessage(
      "请选择一个模型",
    ),
    "chat_title": MessageLookupByLibrary.simpleMessage("RWKV Chat v7"),
    "chat_welcome_to_use": MessageLookupByLibrary.simpleMessage(
      "欢迎体验 RWKV Chat v7",
    ),
    "chat_you_need_download_model_if_you_want_to_use_it":
        MessageLookupByLibrary.simpleMessage("你需要先下载模型, 才能使用它们"),
    "choose_prebuilt_character": MessageLookupByLibrary.simpleMessage("选择预设角色"),
    "download_model": MessageLookupByLibrary.simpleMessage("下载模型"),
    "othello_title": MessageLookupByLibrary.simpleMessage("RWKV 黑白棋"),
    "rwkv_chat": MessageLookupByLibrary.simpleMessage("RWKV 聊天"),
    "rwkv_othello": MessageLookupByLibrary.simpleMessage("RWKV 黑白棋"),
    "send_message_to_rwkv": MessageLookupByLibrary.simpleMessage("输入你的消息..."),
    "start_to_chat": MessageLookupByLibrary.simpleMessage("开始聊天"),
    "use_it_now": MessageLookupByLibrary.simpleMessage("立即使用"),
  };
}
