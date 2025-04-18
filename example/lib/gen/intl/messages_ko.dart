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

  static String m0(demoName) => "${demoName} 을 탐색해 보세요";

  static String m1(memUsed, memFree) =>
      "사용 중 메모리: ${memUsed}, 여유 메모리: ${memFree}";

  static String m2(modelName) => "현재 ${modelName}을(를) 사용 중입니다";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "apply": MessageLookupByLibrary.simpleMessage("적용"),
    "auto": MessageLookupByLibrary.simpleMessage("자동"),
    "bot_message_edited": MessageLookupByLibrary.simpleMessage(
      "봇 메시지가 수정되었습니다. 새 메시지를 보낼 수 있습니다",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("취소"),
    "chat_copied_to_clipboard": MessageLookupByLibrary.simpleMessage(
      "클립보드에 복사됨",
    ),
    "chat_empty_message": MessageLookupByLibrary.simpleMessage("메시지를 입력해 주세요"),
    "chat_model_name": MessageLookupByLibrary.simpleMessage("모델 이름"),
    "chat_please_select_a_model": MessageLookupByLibrary.simpleMessage(
      "모델을 선택해 주세요",
    ),
    "chat_title": MessageLookupByLibrary.simpleMessage("RWKV World v7"),
    "chat_welcome_to_use": m0,
    "chat_you_need_download_model_if_you_want_to_use_it":
        MessageLookupByLibrary.simpleMessage("사용하려면 먼저 모델을 다운로드해야 합니다"),
    "chatting": MessageLookupByLibrary.simpleMessage("채팅 중"),
    "choose_prebuilt_character": MessageLookupByLibrary.simpleMessage(
      "预制 캐릭터 선택",
    ),
    "click_here_to_select_a_new_model": MessageLookupByLibrary.simpleMessage(
      "여기를 클릭하여 새 모델 선택",
    ),
    "click_here_to_start_a_new_chat": MessageLookupByLibrary.simpleMessage(
      "여기를 클릭하여 새 채팅 시작",
    ),
    "create_a_new_one_by_clicking_the_button_above":
        MessageLookupByLibrary.simpleMessage("위 버튼을 클릭하여 새로 만들기"),
    "download_model": MessageLookupByLibrary.simpleMessage("모델 다운로드"),
    "download_source": MessageLookupByLibrary.simpleMessage("다운로드 소스"),
    "ensure_you_have_enough_memory_to_load_the_model":
        MessageLookupByLibrary.simpleMessage(
          "메모리가 충분한지 확인하세요. 그렇지 않으면 앱이 충돌할 수 있습니다",
        ),
    "foo_bar": MessageLookupByLibrary.simpleMessage("foo bar"),
    "intro": MessageLookupByLibrary.simpleMessage(
      "RWKV v7 시리즈 경량 언어 모델을 경험해 보세요. 0.1B/0.4B/1.5B/2.9B 파라미터 버전으로 모바일 최적화되어 오프라인에서도 서버 연결 없이 작동합니다",
    ),
    "loading": MessageLookupByLibrary.simpleMessage("로딩 중..."),
    "memory_used": m1,
    "new_chat": MessageLookupByLibrary.simpleMessage("새 채팅"),
    "or_you_can_start_a_new_empty_chat": MessageLookupByLibrary.simpleMessage(
      "또는 빈 채팅을 시작할 수 있습니다",
    ),
    "othello_title": MessageLookupByLibrary.simpleMessage("RWKV 오델로"),
    "please_select_a_world_type": MessageLookupByLibrary.simpleMessage(
      "월드 타입을 선택해 주세요",
    ),
    "remaining": MessageLookupByLibrary.simpleMessage("남음:"),
    "reset": MessageLookupByLibrary.simpleMessage("초기화"),
    "rwkv_chat": MessageLookupByLibrary.simpleMessage("RWKV 채팅"),
    "rwkv_othello": MessageLookupByLibrary.simpleMessage("RWKV 오델로"),
    "select_a_model": MessageLookupByLibrary.simpleMessage("모델 선택"),
    "select_a_world_type": MessageLookupByLibrary.simpleMessage("월드 타입 선택"),
    "send_message_to_rwkv": MessageLookupByLibrary.simpleMessage(
      "RWKV에게 메시지 보내기",
    ),
    "session_configuration": MessageLookupByLibrary.simpleMessage("세션 설정"),
    "speed": MessageLookupByLibrary.simpleMessage("속도:"),
    "start_a_new_chat": MessageLookupByLibrary.simpleMessage("새 채팅 시작"),
    "start_a_new_chat_by_clicking_the_button_below":
        MessageLookupByLibrary.simpleMessage("아래 버튼을 클릭하여 새 채팅 시작"),
    "start_to_chat": MessageLookupByLibrary.simpleMessage("채팅 시작"),
    "use_it_now": MessageLookupByLibrary.simpleMessage("지금 사용하기"),
    "welcome_to_use_rwkv": MessageLookupByLibrary.simpleMessage(
      "RWKV를 사용해 주셔서 환영합니다",
    ),
    "you_are_now_using": m2,
    "you_can_now_start_to_chat_with_rwkv": MessageLookupByLibrary.simpleMessage(
      "이제 RWKV와 채팅을 시작할 수 있습니다",
    ),
    "you_can_select_a_role_to_chat": MessageLookupByLibrary.simpleMessage(
      "채팅할 역할을 선택할 수 있습니다",
    ),
  };
}
