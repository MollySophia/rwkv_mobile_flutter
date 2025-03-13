// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
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
  String get localeName => 'ja';

  static String m0(demoName) => "RWKV ワールド v7へようこそ";

  static String m1(memUsed, memFree) => "使用メモリ: ${memUsed}、空きメモリ: ${memFree}";

  static String m2(modelName) => "現在 ${modelName} を使用中です";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "bot_message_edited": MessageLookupByLibrary.simpleMessage(
      "ボットメッセージが編集されました。新しいメッセージを送信できます",
    ),
    "chat_copied_to_clipboard": MessageLookupByLibrary.simpleMessage(
      "クリップボードにコピーされました",
    ),
    "chat_empty_message": MessageLookupByLibrary.simpleMessage(
      "メッセージを入力してください",
    ),
    "chat_model_name": MessageLookupByLibrary.simpleMessage("モデル名"),
    "chat_please_select_a_model": MessageLookupByLibrary.simpleMessage(
      "モデルを選択してください",
    ),
    "chat_title": MessageLookupByLibrary.simpleMessage("RWKV World v7"),
    "chat_welcome_to_use": m0,
    "chat_you_need_download_model_if_you_want_to_use_it":
        MessageLookupByLibrary.simpleMessage("使用するにはモデルのダウンロードが必要です"),
    "chatting": MessageLookupByLibrary.simpleMessage("チャット中"),
    "choose_prebuilt_character": MessageLookupByLibrary.simpleMessage(
      "プリセットキャラクターを選択",
    ),
    "click_here_to_select_a_new_model": MessageLookupByLibrary.simpleMessage(
      "ここをクリックして新規モデルを選択",
    ),
    "click_here_to_start_a_new_chat": MessageLookupByLibrary.simpleMessage(
      "ここをクリックして新規チャットを開始",
    ),
    "download_model": MessageLookupByLibrary.simpleMessage("モデルをダウンロード"),
    "ensure_you_have_enough_memory_to_load_the_model":
        MessageLookupByLibrary.simpleMessage("メモリが不足するとアプリがクラッシュする可能性があります"),
    "foo_bar": MessageLookupByLibrary.simpleMessage("foo bar"),
    "intro": MessageLookupByLibrary.simpleMessage(
      "RWKV v7シリーズの軽量言語モデルを体験。0.1B/0.4B/1.5B/3.0Bパラメータ版をモバイル最適化。オフラインでサーバー通信不要",
    ),
    "memory_used": m1,
    "new_chat": MessageLookupByLibrary.simpleMessage("新規チャット"),
    "or_you_can_start_a_new_empty_chat": MessageLookupByLibrary.simpleMessage(
      "または空白のチャットを開始",
    ),
    "othello_title": MessageLookupByLibrary.simpleMessage("RWKV オセロ"),
    "rwkv_chat": MessageLookupByLibrary.simpleMessage("RWKV チャット"),
    "rwkv_othello": MessageLookupByLibrary.simpleMessage("RWKV オセロ"),
    "select_a_model": MessageLookupByLibrary.simpleMessage("モデルを選択"),
    "send_message_to_rwkv": MessageLookupByLibrary.simpleMessage(
      "RWKVへメッセージを送信",
    ),
    "start_a_new_chat": MessageLookupByLibrary.simpleMessage("新規チャットを開始"),
    "start_a_new_chat_by_clicking_the_button_below":
        MessageLookupByLibrary.simpleMessage("下のボタンをクリックして新規チャットを開始"),
    "start_to_chat": MessageLookupByLibrary.simpleMessage("チャットを開始"),
    "use_it_now": MessageLookupByLibrary.simpleMessage("今すぐ使用"),
    "welcome_to_use_rwkv": MessageLookupByLibrary.simpleMessage(
      "RWKVをご利用いただきありがとうございます",
    ),
    "you_are_now_using": m2,
    "you_can_now_start_to_chat_with_rwkv": MessageLookupByLibrary.simpleMessage(
      "RWKVとのチャットを開始できます",
    ),
    "you_can_select_a_role_to_chat": MessageLookupByLibrary.simpleMessage(
      "チャットするロールを選択できます",
    ),
  };
}
