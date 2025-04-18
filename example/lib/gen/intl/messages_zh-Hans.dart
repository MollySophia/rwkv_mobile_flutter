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

  static String m0(demoName) => "欢迎探索 ${demoName}";

  static String m1(memUsed, memFree) => "已用内存：${memUsed}，剩余内存：${memFree}";

  static String m2(modelName) => "您当前正在使用 ${modelName}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "apply": MessageLookupByLibrary.simpleMessage("应用"),
    "are_you_sure_you_want_to_delete_this_model":
        MessageLookupByLibrary.simpleMessage("确定要删除这个模型吗？"),
    "auto": MessageLookupByLibrary.simpleMessage("自动"),
    "back_to_chat": MessageLookupByLibrary.simpleMessage("返回聊天"),
    "bot_message_edited": MessageLookupByLibrary.simpleMessage(
      "机器人消息已编辑，现在可以发送新消息",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancel_update": MessageLookupByLibrary.simpleMessage("暂不更新"),
    "chat_copied_to_clipboard": MessageLookupByLibrary.simpleMessage("已复制到剪贴板"),
    "chat_empty_message": MessageLookupByLibrary.simpleMessage("请输入消息内容"),
    "chat_model_name": MessageLookupByLibrary.simpleMessage("模型名称"),
    "chat_please_select_a_model": MessageLookupByLibrary.simpleMessage(
      "请选择一个模型",
    ),
    "chat_resume": MessageLookupByLibrary.simpleMessage("继续"),
    "chat_title": MessageLookupByLibrary.simpleMessage("RWKV Chat"),
    "chat_welcome_to_use": m0,
    "chat_you_need_download_model_if_you_want_to_use_it":
        MessageLookupByLibrary.simpleMessage("您需要先下载模型才能使用"),
    "chatting": MessageLookupByLibrary.simpleMessage("聊天中"),
    "chinese": MessageLookupByLibrary.simpleMessage("中文"),
    "choose_prebuilt_character": MessageLookupByLibrary.simpleMessage("选择预设角色"),
    "click_here_to_select_a_new_model": MessageLookupByLibrary.simpleMessage(
      "点击此处选择新模型",
    ),
    "click_here_to_start_a_new_chat": MessageLookupByLibrary.simpleMessage(
      "点击此处开始新聊天",
    ),
    "click_to_select_model": MessageLookupByLibrary.simpleMessage("点击选择模型"),
    "create_a_new_one_by_clicking_the_button_above":
        MessageLookupByLibrary.simpleMessage("点击上方按钮创建新会话"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "delete_all": MessageLookupByLibrary.simpleMessage("全部删除"),
    "download_missing": MessageLookupByLibrary.simpleMessage("下载缺失文件"),
    "download_model": MessageLookupByLibrary.simpleMessage("下载模型"),
    "download_source": MessageLookupByLibrary.simpleMessage("下载源"),
    "ensure_you_have_enough_memory_to_load_the_model":
        MessageLookupByLibrary.simpleMessage("请确保设备内存充足，否则可能导致应用崩溃"),
    "exploring": MessageLookupByLibrary.simpleMessage("探索中..."),
    "foo_bar": MessageLookupByLibrary.simpleMessage("foo bar"),
    "i_want_rwkv_to_say": MessageLookupByLibrary.simpleMessage("我想让 RWKV 说..."),
    "intro": MessageLookupByLibrary.simpleMessage(
      "欢迎探索 RWKV v7 系列大语言模型，包含 0.1B/0.4B/1.5B/2.9B 参数版本，专为移动设备优化，加载后可完全离线运行，无需服务器通信",
    ),
    "loading": MessageLookupByLibrary.simpleMessage("加载中..."),
    "memory_used": m1,
    "network_error": MessageLookupByLibrary.simpleMessage("网络错误"),
    "new_chat": MessageLookupByLibrary.simpleMessage("新聊天"),
    "new_version_found": MessageLookupByLibrary.simpleMessage("发现新版本"),
    "or_you_can_start_a_new_empty_chat": MessageLookupByLibrary.simpleMessage(
      "或开始一个空白聊天",
    ),
    "othello_title": MessageLookupByLibrary.simpleMessage("RWKV 黑白棋"),
    "please_select_a_world_type": MessageLookupByLibrary.simpleMessage(
      "请选择 World 类型",
    ),
    "please_wait_for_the_model_to_finish_generating":
        MessageLookupByLibrary.simpleMessage("请等待模型生成完成"),
    "please_wait_for_the_model_to_load": MessageLookupByLibrary.simpleMessage(
      "请等待模型加载",
    ),
    "prefer": MessageLookupByLibrary.simpleMessage("使用"),
    "prefer_chinese": MessageLookupByLibrary.simpleMessage("使用中文推理"),
    "reason": MessageLookupByLibrary.simpleMessage("推理"),
    "reasoning_enabled": MessageLookupByLibrary.simpleMessage("推理模式"),
    "remaining": MessageLookupByLibrary.simpleMessage("剩余时间："),
    "reset": MessageLookupByLibrary.simpleMessage("重置"),
    "rwkv_chat": MessageLookupByLibrary.simpleMessage("RWKV 聊天"),
    "rwkv_othello": MessageLookupByLibrary.simpleMessage("RWKV 黑白棋"),
    "select_a_model": MessageLookupByLibrary.simpleMessage("选择模型"),
    "select_a_world_type": MessageLookupByLibrary.simpleMessage("选择 World 类型"),
    "send_message_to_rwkv": MessageLookupByLibrary.simpleMessage("发送消息给 RWKV"),
    "server_error": MessageLookupByLibrary.simpleMessage("服务器错误"),
    "session_configuration": MessageLookupByLibrary.simpleMessage("会话配置"),
    "speed": MessageLookupByLibrary.simpleMessage("下载速度："),
    "start_a_new_chat": MessageLookupByLibrary.simpleMessage("开始新聊天"),
    "start_a_new_chat_by_clicking_the_button_below":
        MessageLookupByLibrary.simpleMessage("点击下方按钮开始新聊天"),
    "start_to_chat": MessageLookupByLibrary.simpleMessage("开始聊天"),
    "thinking": MessageLookupByLibrary.simpleMessage("思考中..."),
    "thought_result": MessageLookupByLibrary.simpleMessage("思考结果"),
    "update_now": MessageLookupByLibrary.simpleMessage("立即更新"),
    "use_it_now": MessageLookupByLibrary.simpleMessage("立即使用"),
    "welcome_to_use_rwkv": MessageLookupByLibrary.simpleMessage("欢迎使用 RWKV"),
    "you_are_now_using": m2,
    "you_can_now_start_to_chat_with_rwkv": MessageLookupByLibrary.simpleMessage(
      "现在可以开始与 RWKV 聊天了",
    ),
    "you_can_select_a_role_to_chat": MessageLookupByLibrary.simpleMessage(
      "您可以选择角色进行聊天",
    ),
  };
}
