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

  static String m0(demoName) => "歡迎探索 ${demoName}";

  static String m1(memUsed, memFree) => "已用記憶體：${memUsed}，剩餘記憶體：${memFree}";

  static String m2(modelName) => "您目前正在使用 ${modelName}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "application_language": MessageLookupByLibrary.simpleMessage("應用程式語言"),
    "apply": MessageLookupByLibrary.simpleMessage("套用"),
    "are_you_sure_you_want_to_delete_this_model":
        MessageLookupByLibrary.simpleMessage("確定要刪除這個模型嗎？"),
    "auto": MessageLookupByLibrary.simpleMessage("自動"),
    "back_to_chat": MessageLookupByLibrary.simpleMessage("返回聊天"),
    "bot_message_edited": MessageLookupByLibrary.simpleMessage(
      "機器人訊息已編輯，現在可以傳送新訊息",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancel_update": MessageLookupByLibrary.simpleMessage("暫不更新"),
    "chat_copied_to_clipboard": MessageLookupByLibrary.simpleMessage("已複製到剪貼簿"),
    "chat_empty_message": MessageLookupByLibrary.simpleMessage("請輸入訊息內容"),
    "chat_model_name": MessageLookupByLibrary.simpleMessage("模型名稱"),
    "chat_please_select_a_model": MessageLookupByLibrary.simpleMessage(
      "請選擇一個模型",
    ),
    "chat_resume": MessageLookupByLibrary.simpleMessage("繼續"),
    "chat_title": MessageLookupByLibrary.simpleMessage("RWKV 聊天"),
    "chat_welcome_to_use": m0,
    "chat_you_need_download_model_if_you_want_to_use_it":
        MessageLookupByLibrary.simpleMessage("您需要先下載模型才能使用"),
    "chatting": MessageLookupByLibrary.simpleMessage("聊天中"),
    "chinese": MessageLookupByLibrary.simpleMessage("中文"),
    "choose_prebuilt_character": MessageLookupByLibrary.simpleMessage("選擇預設角色"),
    "click_here_to_select_a_new_model": MessageLookupByLibrary.simpleMessage(
      "點擊此處選擇新模型",
    ),
    "click_here_to_start_a_new_chat": MessageLookupByLibrary.simpleMessage(
      "點擊此處開始新聊天",
    ),
    "click_to_select_model": MessageLookupByLibrary.simpleMessage("點擊選擇模型"),
    "create_a_new_one_by_clicking_the_button_above":
        MessageLookupByLibrary.simpleMessage("點擊上方按鈕建立新會話"),
    "delete": MessageLookupByLibrary.simpleMessage("刪除"),
    "delete_all": MessageLookupByLibrary.simpleMessage("全部刪除"),
    "download_missing": MessageLookupByLibrary.simpleMessage("下載缺失檔案"),
    "download_model": MessageLookupByLibrary.simpleMessage("下載模型"),
    "download_source": MessageLookupByLibrary.simpleMessage("下載來源"),
    "ensure_you_have_enough_memory_to_load_the_model":
        MessageLookupByLibrary.simpleMessage("請確保裝置記憶體充足，否則可能導致應用程式崩潰"),
    "exploring": MessageLookupByLibrary.simpleMessage("探索中..."),
    "extra_large": MessageLookupByLibrary.simpleMessage("特大 (130%)"),
    "follow_system": MessageLookupByLibrary.simpleMessage("跟隨系統"),
    "font_setting": MessageLookupByLibrary.simpleMessage("字型設定"),
    "font_size": MessageLookupByLibrary.simpleMessage("字型大小"),
    "font_size_default": MessageLookupByLibrary.simpleMessage("預設 (100%)"),
    "foo_bar": MessageLookupByLibrary.simpleMessage("foo bar"),
    "i_want_rwkv_to_say": MessageLookupByLibrary.simpleMessage("我想讓 RWKV 說..."),
    "intonations": MessageLookupByLibrary.simpleMessage("語氣詞"),
    "intro": MessageLookupByLibrary.simpleMessage(
      "歡迎探索 RWKV v7 系列大型語言模型 (Large Language Models)，包含 0.1B/0.4B/1.5B/2.9B 參數版本，專為行動裝置最佳化，載入後可完全離線運行，無需伺服器通訊",
    ),
    "large": MessageLookupByLibrary.simpleMessage("大 (120%)"),
    "loading": MessageLookupByLibrary.simpleMessage("載入中..."),
    "medium": MessageLookupByLibrary.simpleMessage("中 (110%)"),
    "memory_used": m1,
    "network_error": MessageLookupByLibrary.simpleMessage("網路錯誤"),
    "new_chat": MessageLookupByLibrary.simpleMessage("新聊天"),
    "new_version_found": MessageLookupByLibrary.simpleMessage("發現新版本"),
    "or_you_can_start_a_new_empty_chat": MessageLookupByLibrary.simpleMessage(
      "或開始一個空白聊天",
    ),
    "othello_title": MessageLookupByLibrary.simpleMessage("RWKV 黑白棋"),
    "please_select_a_world_type": MessageLookupByLibrary.simpleMessage(
      "請選擇 World 類型",
    ),
    "please_select_application_language": MessageLookupByLibrary.simpleMessage(
      "請選擇應用程式語言",
    ),
    "please_select_font_size": MessageLookupByLibrary.simpleMessage("請選擇字型大小"),
    "please_wait_for_the_model_to_finish_generating":
        MessageLookupByLibrary.simpleMessage("請等待模型生成完成"),
    "please_wait_for_the_model_to_load": MessageLookupByLibrary.simpleMessage(
      "請等待模型載入",
    ),
    "prebuilt_voices": MessageLookupByLibrary.simpleMessage("預設聲音"),
    "prefer": MessageLookupByLibrary.simpleMessage("使用"),
    "prefer_chinese": MessageLookupByLibrary.simpleMessage("使用中文推理"),
    "reason": MessageLookupByLibrary.simpleMessage("推理"),
    "reasoning_enabled": MessageLookupByLibrary.simpleMessage("推理模式"),
    "remaining": MessageLookupByLibrary.simpleMessage("剩餘時間："),
    "reset": MessageLookupByLibrary.simpleMessage("重設"),
    "rwkv_chat": MessageLookupByLibrary.simpleMessage("RWKV 聊天"),
    "rwkv_othello": MessageLookupByLibrary.simpleMessage("RWKV 黑白棋"),
    "select_a_model": MessageLookupByLibrary.simpleMessage("選擇模型"),
    "select_a_world_type": MessageLookupByLibrary.simpleMessage("選擇 World 類型"),
    "send_message_to_rwkv": MessageLookupByLibrary.simpleMessage("傳送訊息給 RWKV"),
    "server_error": MessageLookupByLibrary.simpleMessage("伺服器錯誤"),
    "session_configuration": MessageLookupByLibrary.simpleMessage("會話設定"),
    "small": MessageLookupByLibrary.simpleMessage("小 (90%)"),
    "speed": MessageLookupByLibrary.simpleMessage("下載速度："),
    "start_a_new_chat": MessageLookupByLibrary.simpleMessage("開始新聊天"),
    "start_a_new_chat_by_clicking_the_button_below":
        MessageLookupByLibrary.simpleMessage("點擊下方按鈕開始新聊天"),
    "start_to_chat": MessageLookupByLibrary.simpleMessage("開始聊天"),
    "thinking": MessageLookupByLibrary.simpleMessage("思考中..."),
    "thought_result": MessageLookupByLibrary.simpleMessage("思考結果"),
    "ultra_large": MessageLookupByLibrary.simpleMessage("超大 (140%)"),
    "update_now": MessageLookupByLibrary.simpleMessage("立即更新"),
    "use_it_now": MessageLookupByLibrary.simpleMessage("立即使用"),
    "very_small": MessageLookupByLibrary.simpleMessage("非常小 (80%)"),
    "voice_cloning": MessageLookupByLibrary.simpleMessage("聲音克隆"),
    "welcome_to_use_rwkv": MessageLookupByLibrary.simpleMessage("歡迎使用 RWKV"),
    "you_are_now_using": m2,
    "you_can_now_start_to_chat_with_rwkv": MessageLookupByLibrary.simpleMessage(
      "現在可以開始與 RWKV 聊天了",
    ),
    "you_can_select_a_role_to_chat": MessageLookupByLibrary.simpleMessage(
      "您可以選擇角色進行聊天",
    ),
  };
}
