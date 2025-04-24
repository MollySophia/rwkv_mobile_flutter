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

  static String m0(demoName) => "${demoName} の探索へようこそ";

  static String m1(memUsed, memFree) => "使用メモリ：${memUsed}、空きメモリ：${memFree}";

  static String m2(modelName) => "現在 ${modelName} を使用しています";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "application_language": MessageLookupByLibrary.simpleMessage("言語"),
    "apply": MessageLookupByLibrary.simpleMessage("適用"),
    "are_you_sure_you_want_to_delete_this_model":
        MessageLookupByLibrary.simpleMessage("このモデルを削除してもよろしいですか？"),
    "auto": MessageLookupByLibrary.simpleMessage("自動"),
    "back_to_chat": MessageLookupByLibrary.simpleMessage("チャットに戻る"),
    "bot_message_edited": MessageLookupByLibrary.simpleMessage(
      "ボットメッセージが編集されました。新しいメッセージを送信できます",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "cancel_update": MessageLookupByLibrary.simpleMessage("更新をキャンセル"),
    "chat_copied_to_clipboard": MessageLookupByLibrary.simpleMessage(
      "クリップボードにコピーしました",
    ),
    "chat_empty_message": MessageLookupByLibrary.simpleMessage(
      "メッセージを入力してください",
    ),
    "chat_model_name": MessageLookupByLibrary.simpleMessage("モデル名"),
    "chat_please_select_a_model": MessageLookupByLibrary.simpleMessage(
      "モデルを選択してください",
    ),
    "chat_resume": MessageLookupByLibrary.simpleMessage("再開"),
    "chat_title": MessageLookupByLibrary.simpleMessage("RWKV World v7"),
    "chat_welcome_to_use": m0,
    "chat_you_need_download_model_if_you_want_to_use_it":
        MessageLookupByLibrary.simpleMessage("使用する前に、まずモデルをダウンロードする必要があります。"),
    "chatting": MessageLookupByLibrary.simpleMessage("チャット中"),
    "chinese": MessageLookupByLibrary.simpleMessage("中国語"),
    "choose_prebuilt_character": MessageLookupByLibrary.simpleMessage(
      "プリセットキャラクターを選択",
    ),
    "click_here_to_select_a_new_model": MessageLookupByLibrary.simpleMessage(
      "ここをクリックして新しいモデルを選択",
    ),
    "click_here_to_start_a_new_chat": MessageLookupByLibrary.simpleMessage(
      "ここをクリックして新しいチャットを開始",
    ),
    "click_to_select_model": MessageLookupByLibrary.simpleMessage(
      "クリックしてモデルを選択",
    ),
    "create_a_new_one_by_clicking_the_button_above":
        MessageLookupByLibrary.simpleMessage("上のボタンをクリックして新規作成します。"),
    "delete": MessageLookupByLibrary.simpleMessage("削除"),
    "delete_all": MessageLookupByLibrary.simpleMessage("すべて削除"),
    "download_missing": MessageLookupByLibrary.simpleMessage(
      "不足しているファイルをダウンロード",
    ),
    "download_model": MessageLookupByLibrary.simpleMessage("モデルをダウンロード"),
    "download_source": MessageLookupByLibrary.simpleMessage("ダウンロードソース"),
    "ensure_you_have_enough_memory_to_load_the_model":
        MessageLookupByLibrary.simpleMessage(
          "モデルをロードするのに十分なメモリがあることを確認してください。そうでない場合、アプリケーションがクラッシュする可能性があります。",
        ),
    "exploring": MessageLookupByLibrary.simpleMessage("探索中..."),
    "extra_large": MessageLookupByLibrary.simpleMessage("特に大きい (130%)"),
    "follow_system": MessageLookupByLibrary.simpleMessage("システム"),
    "font_setting": MessageLookupByLibrary.simpleMessage("フォント設定"),
    "font_size": MessageLookupByLibrary.simpleMessage("フォントサイズ"),
    "font_size_default": MessageLookupByLibrary.simpleMessage("デフォルト (100%)"),
    "foo_bar": MessageLookupByLibrary.simpleMessage("foo bar"),
    "i_want_rwkv_to_say": MessageLookupByLibrary.simpleMessage("RWKVに言わせたい..."),
    "intonations": MessageLookupByLibrary.simpleMessage("イントネーション"),
    "intro": MessageLookupByLibrary.simpleMessage(
      "RWKV v7を体験する準備をしましょう。0.1, 0.4, 1.5, 2.9億パラメータを持つコンパクトな言語モデル（LLM）シリーズで、シームレスなモバイルデバイス推論に最適化されています。ロード後は、サーバー通信を必要とせずにオフラインで機能します。",
    ),
    "large": MessageLookupByLibrary.simpleMessage("大きい (120%)"),
    "loading": MessageLookupByLibrary.simpleMessage("読み込み中..."),
    "medium": MessageLookupByLibrary.simpleMessage("中 (110%)"),
    "memory_used": m1,
    "network_error": MessageLookupByLibrary.simpleMessage("ネットワークエラー"),
    "new_chat": MessageLookupByLibrary.simpleMessage("新しいチャット"),
    "new_version_found": MessageLookupByLibrary.simpleMessage(
      "新しいバージョンが見つかりました",
    ),
    "or_you_can_start_a_new_empty_chat": MessageLookupByLibrary.simpleMessage(
      "または、新しい空のチャットを開始できます",
    ),
    "othello_title": MessageLookupByLibrary.simpleMessage("RWKV オセロ"),
    "please_select_a_world_type": MessageLookupByLibrary.simpleMessage(
      "World タイプを選択してください",
    ),
    "please_select_application_language": MessageLookupByLibrary.simpleMessage(
      "アプリケーションの言語を選択してください",
    ),
    "please_select_font_size": MessageLookupByLibrary.simpleMessage(
      "フォントサイズを選択してください",
    ),
    "please_wait_for_the_model_to_finish_generating":
        MessageLookupByLibrary.simpleMessage("モデルの生成完了をお待ちください"),
    "please_wait_for_the_model_to_load": MessageLookupByLibrary.simpleMessage(
      "モデルの読み込みをお待ちください",
    ),
    "prebuilt_voices": MessageLookupByLibrary.simpleMessage("プリセット音声"),
    "prefer": MessageLookupByLibrary.simpleMessage("優先"),
    "prefer_chinese": MessageLookupByLibrary.simpleMessage("中国語推論を優先"),
    "reason": MessageLookupByLibrary.simpleMessage("推論"),
    "reasoning_enabled": MessageLookupByLibrary.simpleMessage("推論が有効"),
    "remaining": MessageLookupByLibrary.simpleMessage("残り時間："),
    "reset": MessageLookupByLibrary.simpleMessage("リセット"),
    "rwkv_chat": MessageLookupByLibrary.simpleMessage("RWKV チャット"),
    "rwkv_othello": MessageLookupByLibrary.simpleMessage("RWKV オセロ"),
    "select_a_model": MessageLookupByLibrary.simpleMessage("モデルを選択"),
    "select_a_world_type": MessageLookupByLibrary.simpleMessage("World タイプを選択"),
    "send_message_to_rwkv": MessageLookupByLibrary.simpleMessage(
      "RWKVにメッセージを送信",
    ),
    "server_error": MessageLookupByLibrary.simpleMessage("サーバーエラー"),
    "session_configuration": MessageLookupByLibrary.simpleMessage("セッション構成"),
    "small": MessageLookupByLibrary.simpleMessage("小さい (90%)"),
    "speed": MessageLookupByLibrary.simpleMessage("速度："),
    "start_a_new_chat": MessageLookupByLibrary.simpleMessage("新しいチャットを開始"),
    "start_a_new_chat_by_clicking_the_button_below":
        MessageLookupByLibrary.simpleMessage("下のボタンをクリックして新しいチャットを開始できます。"),
    "start_to_chat": MessageLookupByLibrary.simpleMessage("チャットを開始"),
    "thinking": MessageLookupByLibrary.simpleMessage("考え中..."),
    "thought_result": MessageLookupByLibrary.simpleMessage("思考結果"),
    "ultra_large": MessageLookupByLibrary.simpleMessage("極めて大きい (140%)"),
    "update_now": MessageLookupByLibrary.simpleMessage("今すぐ更新"),
    "use_it_now": MessageLookupByLibrary.simpleMessage("今すぐ使用"),
    "very_small": MessageLookupByLibrary.simpleMessage("非常に小さい (80%)"),
    "voice_cloning": MessageLookupByLibrary.simpleMessage("音声クローニング"),
    "welcome_to_use_rwkv": MessageLookupByLibrary.simpleMessage("RWKVへようこそ"),
    "you_are_now_using": m2,
    "you_can_now_start_to_chat_with_rwkv": MessageLookupByLibrary.simpleMessage(
      "これでRWKVとチャットを開始できます",
    ),
    "you_can_select_a_role_to_chat": MessageLookupByLibrary.simpleMessage(
      "チャットする役割を選択できます",
    ),
  };
}
