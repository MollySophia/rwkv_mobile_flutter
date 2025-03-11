// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_Hant locale. All the
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
  String get localeName => 'zh_Hant';

  static String m0(memUsed, memFree) => "已用記憶體：${memUsed}，剩餘記憶體：${memFree}";

  static String m1(modelName) => "您當前正在使用 ${modelName}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "bot_message_edited": MessageLookupByLibrary.simpleMessage(
      "機器人訊息已編輯，現在可以傳送新訊息",
    ),
    "chat_copied_to_clipboard": MessageLookupByLibrary.simpleMessage("已複製到剪貼簿"),
    "chat_empty_message": MessageLookupByLibrary.simpleMessage("請輸入訊息內容"),
    "chat_model_name": MessageLookupByLibrary.simpleMessage("模型名稱"),
    "chat_please_select_a_model": MessageLookupByLibrary.simpleMessage(
      "請選擇一個模型",
    ),
    "chat_title": MessageLookupByLibrary.simpleMessage("RWKV World v7"),
    "chat_welcome_to_use": MessageLookupByLibrary.simpleMessage(
      "歡迎探索 RWKV World v7",
    ),
    "chat_you_need_download_model_if_you_want_to_use_it":
        MessageLookupByLibrary.simpleMessage("您需要先下載模型才能使用"),
    "chatting": MessageLookupByLibrary.simpleMessage("聊天中"),
    "choose_prebuilt_character": MessageLookupByLibrary.simpleMessage("選擇預設角色"),
    "click_here_to_select_a_new_model": MessageLookupByLibrary.simpleMessage(
      "點擊此處選擇新模型",
    ),
    "click_here_to_start_a_new_chat": MessageLookupByLibrary.simpleMessage(
      "點擊此處開始新聊天",
    ),
    "download_model": MessageLookupByLibrary.simpleMessage("下載模型"),
    "ensure_you_have_enough_memory_to_load_the_model":
        MessageLookupByLibrary.simpleMessage("請確保裝置記憶體充足，否則可能導致應用程式崩潰"),
    "foo_bar": MessageLookupByLibrary.simpleMessage("foo bar"),
    "intro": MessageLookupByLibrary.simpleMessage(
      "即將體驗 RWKV v7 系列緊湊型語言模型，包含 0.1B/0.4B/1.5B/3.0B 參數版本，專為行動裝置優化，載入後可完全離線運行，無需伺服器通訊",
    ),
    "memory_used": m0,
    "new_chat": MessageLookupByLibrary.simpleMessage("新聊天"),
    "or_you_can_start_a_new_empty_chat": MessageLookupByLibrary.simpleMessage(
      "或開始一個空白聊天",
    ),
    "othello_title": MessageLookupByLibrary.simpleMessage("RWKV 黑白棋"),
    "rwkv_chat": MessageLookupByLibrary.simpleMessage("RWKV 聊天"),
    "rwkv_othello": MessageLookupByLibrary.simpleMessage("RWKV 黑白棋"),
    "select_a_model": MessageLookupByLibrary.simpleMessage("選擇模型"),
    "send_message_to_rwkv": MessageLookupByLibrary.simpleMessage("傳送訊息給 RWKV"),
    "start_a_new_chat": MessageLookupByLibrary.simpleMessage("開始新聊天"),
    "start_a_new_chat_by_clicking_the_button_below":
        MessageLookupByLibrary.simpleMessage("點擊下方按鈕開始新聊天"),
    "start_to_chat": MessageLookupByLibrary.simpleMessage("開始聊天"),
    "use_it_now": MessageLookupByLibrary.simpleMessage("立即使用"),
    "welcome_to_use_rwkv": MessageLookupByLibrary.simpleMessage("歡迎使用 RWKV"),
    "you_are_now_using": m1,
    "you_can_now_start_to_chat_with_rwkv": MessageLookupByLibrary.simpleMessage(
      "現在可以開始與 RWKV 聊天了",
    ),
    "you_can_select_a_role_to_chat": MessageLookupByLibrary.simpleMessage(
      "您可以選擇角色進行聊天",
    ),
  };
}
