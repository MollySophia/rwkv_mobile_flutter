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

  static String m0(demoName) => "${demoName} 탐색에 오신 것을 환영합니다";

  static String m1(memUsed, memFree) =>
      "사용된 메모리: ${memUsed}, 사용 가능한 메모리: ${memFree}";

  static String m2(modelName) => "현재 ${modelName}을(를) 사용 중입니다";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "application_language": MessageLookupByLibrary.simpleMessage("언어"),
    "apply": MessageLookupByLibrary.simpleMessage("적용"),
    "are_you_sure_you_want_to_delete_this_model":
        MessageLookupByLibrary.simpleMessage("이 모델을 삭제하시겠습니까?"),
    "auto": MessageLookupByLibrary.simpleMessage("자동"),
    "back_to_chat": MessageLookupByLibrary.simpleMessage("채팅으로 돌아가기"),
    "bot_message_edited": MessageLookupByLibrary.simpleMessage(
      "봇 메시지가 수정되었습니다. 이제 새 메시지를 보낼 수 있습니다",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("취소"),
    "cancel_update": MessageLookupByLibrary.simpleMessage("업데이트 취소"),
    "chat_copied_to_clipboard": MessageLookupByLibrary.simpleMessage(
      "클립보드에 복사됨",
    ),
    "chat_empty_message": MessageLookupByLibrary.simpleMessage("메시지를 입력하세요"),
    "chat_model_name": MessageLookupByLibrary.simpleMessage("모델 이름"),
    "chat_please_select_a_model": MessageLookupByLibrary.simpleMessage(
      "모델을 선택하세요",
    ),
    "chat_resume": MessageLookupByLibrary.simpleMessage("재개"),
    "chat_title": MessageLookupByLibrary.simpleMessage("RWKV 채팅"),
    "chat_welcome_to_use": m0,
    "chat_you_need_download_model_if_you_want_to_use_it":
        MessageLookupByLibrary.simpleMessage("모델을 사용하려면 먼저 다운로드해야 합니다."),
    "chatting": MessageLookupByLibrary.simpleMessage("채팅 중"),
    "chinese": MessageLookupByLibrary.simpleMessage("중국어"),
    "choose_prebuilt_character": MessageLookupByLibrary.simpleMessage(
      "사전 빌드된 캐릭터 선택",
    ),
    "click_here_to_select_a_new_model": MessageLookupByLibrary.simpleMessage(
      "새 모델을 선택하려면 여기를 클릭하세요.",
    ),
    "click_here_to_start_a_new_chat": MessageLookupByLibrary.simpleMessage(
      "새 채팅을 시작하려면 여기를 클릭하세요",
    ),
    "click_to_select_model": MessageLookupByLibrary.simpleMessage("클릭하여 모델 선택"),
    "create_a_new_one_by_clicking_the_button_above":
        MessageLookupByLibrary.simpleMessage("위 버튼을 클릭하여 새로 만듭니다."),
    "delete": MessageLookupByLibrary.simpleMessage("삭제"),
    "delete_all": MessageLookupByLibrary.simpleMessage("모두 삭제"),
    "download_missing": MessageLookupByLibrary.simpleMessage("누락된 파일 다운로드"),
    "download_model": MessageLookupByLibrary.simpleMessage("모델 다운로드"),
    "download_source": MessageLookupByLibrary.simpleMessage("다운로드 소스"),
    "ensure_you_have_enough_memory_to_load_the_model":
        MessageLookupByLibrary.simpleMessage(
          "모델을 로드할 충분한 메모리가 있는지 확인하십시오. 그렇지 않으면 애플리케이션이 충돌할 수 있습니다.",
        ),
    "exploring": MessageLookupByLibrary.simpleMessage("탐색 중..."),
    "extra_large": MessageLookupByLibrary.simpleMessage("매우 큼 (130%)"),
    "follow_system": MessageLookupByLibrary.simpleMessage("시스템"),
    "font_setting": MessageLookupByLibrary.simpleMessage("글꼴 설정"),
    "font_size": MessageLookupByLibrary.simpleMessage("글꼴 크기"),
    "font_size_default": MessageLookupByLibrary.simpleMessage("기본값 (100%)"),
    "foo_bar": MessageLookupByLibrary.simpleMessage("foo bar"),
    "i_want_rwkv_to_say": MessageLookupByLibrary.simpleMessage(
      "RWKV가 말하길 원해요...",
    ),
    "intonations": MessageLookupByLibrary.simpleMessage("억양"),
    "intro": MessageLookupByLibrary.simpleMessage(
      "0.1, 0.4, 1.5, 2.9억 개의 매개변수를 가진 소형 언어 모델(LLM) 시리즈인 RWKV v7을 경험해 보세요. 원활한 모바일 기기 추론에 최적화되어 있습니다. 로드되면 서버 통신 없이 오프라인으로 작동합니다.",
    ),
    "large": MessageLookupByLibrary.simpleMessage("큼 (120%)"),
    "loading": MessageLookupByLibrary.simpleMessage("로드 중..."),
    "medium": MessageLookupByLibrary.simpleMessage("중간 (110%)"),
    "memory_used": m1,
    "network_error": MessageLookupByLibrary.simpleMessage("네트워크 오류"),
    "new_chat": MessageLookupByLibrary.simpleMessage("새 채팅"),
    "new_version_found": MessageLookupByLibrary.simpleMessage("새 버전 발견됨"),
    "or_you_can_start_a_new_empty_chat": MessageLookupByLibrary.simpleMessage(
      "또는 새 빈 채팅을 시작할 수 있습니다",
    ),
    "othello_title": MessageLookupByLibrary.simpleMessage("RWKV 오델로"),
    "please_select_a_world_type": MessageLookupByLibrary.simpleMessage(
      "World 유형을 선택하세요",
    ),
    "please_select_application_language": MessageLookupByLibrary.simpleMessage(
      "애플리케이션 언어를 선택하세요",
    ),
    "please_select_font_size": MessageLookupByLibrary.simpleMessage(
      "글꼴 크기를 선택하세요",
    ),
    "please_wait_for_the_model_to_finish_generating":
        MessageLookupByLibrary.simpleMessage("모델 생성 완료를 기다려주세요"),
    "please_wait_for_the_model_to_load": MessageLookupByLibrary.simpleMessage(
      "모델 로드를 기다려주세요",
    ),
    "prebuilt_voices": MessageLookupByLibrary.simpleMessage("사전 빌드된 음성"),
    "prefer": MessageLookupByLibrary.simpleMessage("선호"),
    "prefer_chinese": MessageLookupByLibrary.simpleMessage("중국어 추론 선호"),
    "reason": MessageLookupByLibrary.simpleMessage("추론"),
    "reasoning_enabled": MessageLookupByLibrary.simpleMessage("추론 활성화됨"),
    "remaining": MessageLookupByLibrary.simpleMessage("남은 시간:"),
    "reset": MessageLookupByLibrary.simpleMessage("재설정"),
    "rwkv_chat": MessageLookupByLibrary.simpleMessage("RWKV 채팅"),
    "rwkv_othello": MessageLookupByLibrary.simpleMessage("RWKV 오델로"),
    "select_a_model": MessageLookupByLibrary.simpleMessage("모델 선택"),
    "select_a_world_type": MessageLookupByLibrary.simpleMessage("World 유형 선택"),
    "send_message_to_rwkv": MessageLookupByLibrary.simpleMessage(
      "RWKV에 메시지 보내기",
    ),
    "server_error": MessageLookupByLibrary.simpleMessage("서버 오류"),
    "session_configuration": MessageLookupByLibrary.simpleMessage("세션 구성"),
    "small": MessageLookupByLibrary.simpleMessage("작음 (90%)"),
    "speed": MessageLookupByLibrary.simpleMessage("속도:"),
    "start_a_new_chat": MessageLookupByLibrary.simpleMessage("새 채팅 시작"),
    "start_a_new_chat_by_clicking_the_button_below":
        MessageLookupByLibrary.simpleMessage("아래 버튼을 클릭하여 새 채팅을 시작할 수 있습니다."),
    "start_to_chat": MessageLookupByLibrary.simpleMessage("채팅 시작"),
    "thinking": MessageLookupByLibrary.simpleMessage("생각 중..."),
    "thought_result": MessageLookupByLibrary.simpleMessage("사고 결과"),
    "ultra_large": MessageLookupByLibrary.simpleMessage("엄청 큼 (140%)"),
    "update_now": MessageLookupByLibrary.simpleMessage("지금 업데이트"),
    "use_it_now": MessageLookupByLibrary.simpleMessage("지금 사용하기"),
    "very_small": MessageLookupByLibrary.simpleMessage("매우 작음 (80%)"),
    "voice_cloning": MessageLookupByLibrary.simpleMessage("음성 복제"),
    "welcome_to_use_rwkv": MessageLookupByLibrary.simpleMessage(
      "RWKV 사용을 환영합니다",
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
