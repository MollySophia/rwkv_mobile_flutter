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
    "about": MessageLookupByLibrary.simpleMessage("정보"),
    "according_to_the_following_audio_file":
        MessageLookupByLibrary.simpleMessage("다음 오디오 파일에 따르면"),
    "application_internal_test_group": MessageLookupByLibrary.simpleMessage(
      "애플리케이션 내부 테스트 그룹",
    ),
    "application_language": MessageLookupByLibrary.simpleMessage("언어"),
    "application_settings": MessageLookupByLibrary.simpleMessage("애플리케이션 설정"),
    "apply": MessageLookupByLibrary.simpleMessage("적용"),
    "are_you_sure_you_want_to_delete_this_model":
        MessageLookupByLibrary.simpleMessage("이 모델을 삭제하시겠습니까?"),
    "auto": MessageLookupByLibrary.simpleMessage("자동"),
    "back_to_chat": MessageLookupByLibrary.simpleMessage("채팅으로 돌아가기"),
    "black": MessageLookupByLibrary.simpleMessage("흑"),
    "black_score": MessageLookupByLibrary.simpleMessage("흑 점수"),
    "black_wins": MessageLookupByLibrary.simpleMessage("흑 승리!"),
    "bot_message_edited": MessageLookupByLibrary.simpleMessage(
      "봇 메시지가 수정되었습니다. 이제 새 메시지를 보낼 수 있습니다",
    ),
    "can_not_generate": MessageLookupByLibrary.simpleMessage("생성할 수 없습니다"),
    "cancel": MessageLookupByLibrary.simpleMessage("취소"),
    "cancel_download": MessageLookupByLibrary.simpleMessage("다운로드 취소"),
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
    "chat_title": MessageLookupByLibrary.simpleMessage("RWKV World v7"),
    "chat_welcome_to_use": m0,
    "chat_you_need_download_model_if_you_want_to_use_it":
        MessageLookupByLibrary.simpleMessage("모델을 사용하려면 먼저 다운로드해야 합니다."),
    "chatting": MessageLookupByLibrary.simpleMessage("채팅 중"),
    "chinese": MessageLookupByLibrary.simpleMessage("중국어"),
    "choose_prebuilt_character": MessageLookupByLibrary.simpleMessage(
      "사전 빌드된 캐릭터 선택",
    ),
    "clear": MessageLookupByLibrary.simpleMessage("지우기"),
    "click_here_to_select_a_new_model": MessageLookupByLibrary.simpleMessage(
      "새 모델을 선택하려면 여기를 클릭하세요.",
    ),
    "click_here_to_start_a_new_chat": MessageLookupByLibrary.simpleMessage(
      "새 채팅을 시작하려면 여기를 클릭하세요",
    ),
    "click_to_select_model": MessageLookupByLibrary.simpleMessage("클릭하여 모델 선택"),
    "continue_download": MessageLookupByLibrary.simpleMessage("다운로드 계속"),
    "create_a_new_one_by_clicking_the_button_above":
        MessageLookupByLibrary.simpleMessage("위 버튼을 클릭하여 새로 만듭니다."),
    "current_turn": MessageLookupByLibrary.simpleMessage("현재 턴"),
    "decode": MessageLookupByLibrary.simpleMessage("디코드"),
    "delete": MessageLookupByLibrary.simpleMessage("삭제"),
    "delete_all": MessageLookupByLibrary.simpleMessage("모두 삭제"),
    "difficulty": MessageLookupByLibrary.simpleMessage("난이도"),
    "difficulty_must_be_greater_than_0": MessageLookupByLibrary.simpleMessage(
      "난이도는 0보다 커야 합니다",
    ),
    "difficulty_must_be_less_than_81": MessageLookupByLibrary.simpleMessage(
      "난이도는 81 미만이어야 합니다",
    ),
    "discord": MessageLookupByLibrary.simpleMessage("Discord"),
    "download_missing": MessageLookupByLibrary.simpleMessage("누락된 파일 다운로드"),
    "download_model": MessageLookupByLibrary.simpleMessage("모델 다운로드"),
    "download_source": MessageLookupByLibrary.simpleMessage("다운로드 소스"),
    "draw": MessageLookupByLibrary.simpleMessage("무승부!"),
    "ensure_you_have_enough_memory_to_load_the_model":
        MessageLookupByLibrary.simpleMessage(
          "모델을 로드할 충분한 메모리가 있는지 확인하십시오. 그렇지 않으면 애플리케이션이 충돌할 수 있습니다.",
        ),
    "exploring": MessageLookupByLibrary.simpleMessage("탐색 중..."),
    "extra_large": MessageLookupByLibrary.simpleMessage("매우 큼 (130%)"),
    "feedback": MessageLookupByLibrary.simpleMessage("피드백"),
    "filter": MessageLookupByLibrary.simpleMessage(
      "안녕하세요, 이 질문에는 아직 답할 수 없습니다. 다른 주제에 대해 이야기해 볼까요.",
    ),
    "follow_system": MessageLookupByLibrary.simpleMessage("시스템"),
    "font_setting": MessageLookupByLibrary.simpleMessage("글꼴 설정"),
    "font_size": MessageLookupByLibrary.simpleMessage("글꼴 크기"),
    "font_size_default": MessageLookupByLibrary.simpleMessage("기본값 (100%)"),
    "foo_bar": MessageLookupByLibrary.simpleMessage("foo bar"),
    "game_over": MessageLookupByLibrary.simpleMessage("게임 오버!"),
    "generate": MessageLookupByLibrary.simpleMessage("생성"),
    "generate_hardest_sudoku_in_the_world":
        MessageLookupByLibrary.simpleMessage("세계에서 가장 어려운 스도쿠 생성"),
    "generate_random_sudoku_puzzle": MessageLookupByLibrary.simpleMessage(
      "랜덤 스도쿠 퍼즐 생성",
    ),
    "hide_stack": MessageLookupByLibrary.simpleMessage("CoT 스택 숨기기"),
    "human": MessageLookupByLibrary.simpleMessage("인간"),
    "i_want_rwkv_to_say": MessageLookupByLibrary.simpleMessage(
      "RWKV가 말하길 원해요...",
    ),
    "imitate_target": MessageLookupByLibrary.simpleMessage("대상"),
    "in_context_search_will_be_activated_when_both_breadth_and_depth_are_greater_than_2":
        MessageLookupByLibrary.simpleMessage(
          "탐색 깊이와 너비가 모두 2보다 클 경우 In-context 검색이 활성화됩니다",
        ),
    "inference_is_running": MessageLookupByLibrary.simpleMessage("추론 실행 중"),
    "intonations": MessageLookupByLibrary.simpleMessage("억양"),
    "intro": MessageLookupByLibrary.simpleMessage(
      "0.1, 0.4, 1.5, 2.9억 개의 매개변수를 가진 소형 언어 모델(LLM) 시리즈인 RWKV v7을 경험해 보세요. 원활한 모바일 기기 추론에 최적화되어 있습니다. 로드되면 서버 통신 없이 오프라인으로 작동합니다.",
    ),
    "invalid_puzzle": MessageLookupByLibrary.simpleMessage("잘못된 퍼즐"),
    "invalid_value": MessageLookupByLibrary.simpleMessage("잘못된 값"),
    "its_your_turn": MessageLookupByLibrary.simpleMessage("네 차례야~"),
    "join_the_community": MessageLookupByLibrary.simpleMessage("커뮤니티 참여"),
    "just_watch_me": MessageLookupByLibrary.simpleMessage("😎 제가 하는 것을 보세요!"),
    "large": MessageLookupByLibrary.simpleMessage("큼 (120%)"),
    "license": MessageLookupByLibrary.simpleMessage("오픈 소스 라이선스"),
    "loading": MessageLookupByLibrary.simpleMessage("로드 중..."),
    "medium": MessageLookupByLibrary.simpleMessage("중간 (110%)"),
    "memory_used": m1,
    "model_settings": MessageLookupByLibrary.simpleMessage("모델 설정"),
    "network_error": MessageLookupByLibrary.simpleMessage("네트워크 오류"),
    "new_chat": MessageLookupByLibrary.simpleMessage("새 채팅"),
    "new_game": MessageLookupByLibrary.simpleMessage("새 게임"),
    "new_version_found": MessageLookupByLibrary.simpleMessage("새 버전 발견됨"),
    "no_puzzle": MessageLookupByLibrary.simpleMessage("퍼즐 없음"),
    "number": MessageLookupByLibrary.simpleMessage("숫자"),
    "ok": MessageLookupByLibrary.simpleMessage("확인"),
    "or_you_can_start_a_new_empty_chat": MessageLookupByLibrary.simpleMessage(
      "또는 새 빈 채팅을 시작할 수 있습니다",
    ),
    "othello_title": MessageLookupByLibrary.simpleMessage("RWKV 오델로"),
    "players": MessageLookupByLibrary.simpleMessage("플레이어"),
    "please_enter_a_number_0_means_empty": MessageLookupByLibrary.simpleMessage(
      "숫자를 입력하세요. 0은 비어 있음을 의미합니다.",
    ),
    "please_enter_the_difficulty": MessageLookupByLibrary.simpleMessage(
      "난이도를 입력해주세요",
    ),
    "please_select_a_world_type": MessageLookupByLibrary.simpleMessage(
      "World 유형을 선택하세요",
    ),
    "please_select_application_language": MessageLookupByLibrary.simpleMessage(
      "애플리케이션 언어를 선택하세요",
    ),
    "please_select_font_size": MessageLookupByLibrary.simpleMessage(
      "글꼴 크기를 선택하세요",
    ),
    "please_wait_for_it_to_finish": MessageLookupByLibrary.simpleMessage(
      "완료될 때까지 기다려주세요",
    ),
    "please_wait_for_the_model_to_finish_generating":
        MessageLookupByLibrary.simpleMessage("모델 생성 완료를 기다려주세요"),
    "please_wait_for_the_model_to_generate":
        MessageLookupByLibrary.simpleMessage("모델 생성을 기다려주세요"),
    "please_wait_for_the_model_to_load": MessageLookupByLibrary.simpleMessage(
      "모델 로드를 기다려주세요",
    ),
    "prebuilt_voices": MessageLookupByLibrary.simpleMessage("사전 빌드된 음성"),
    "prefer": MessageLookupByLibrary.simpleMessage("선호"),
    "prefer_chinese": MessageLookupByLibrary.simpleMessage("중국어 추론 선호"),
    "prefill": MessageLookupByLibrary.simpleMessage("미리 채우기"),
    "qq_group_1": MessageLookupByLibrary.simpleMessage("QQ 그룹 1"),
    "qq_group_2": MessageLookupByLibrary.simpleMessage("QQ 그룹 2"),
    "reason": MessageLookupByLibrary.simpleMessage("추론"),
    "reasoning_enabled": MessageLookupByLibrary.simpleMessage("추론 활성화됨"),
    "remaining": MessageLookupByLibrary.simpleMessage("남은 시간:"),
    "reset": MessageLookupByLibrary.simpleMessage("재설정"),
    "rwkv": MessageLookupByLibrary.simpleMessage("RWKV"),
    "rwkv_chat": MessageLookupByLibrary.simpleMessage("RWKV 채팅"),
    "rwkv_othello": MessageLookupByLibrary.simpleMessage("RWKV 오델로"),
    "search_breadth": MessageLookupByLibrary.simpleMessage("탐색 너비"),
    "search_depth": MessageLookupByLibrary.simpleMessage("탐색 깊이"),
    "select_a_model": MessageLookupByLibrary.simpleMessage("모델 선택"),
    "select_a_world_type": MessageLookupByLibrary.simpleMessage("World 유형 선택"),
    "send_message_to_rwkv": MessageLookupByLibrary.simpleMessage(
      "RWKV에 메시지 보내기",
    ),
    "server_error": MessageLookupByLibrary.simpleMessage("서버 오류"),
    "session_configuration": MessageLookupByLibrary.simpleMessage("세션 구성"),
    "set_the_value_of_grid": MessageLookupByLibrary.simpleMessage("그리드 값 설정"),
    "show_stack": MessageLookupByLibrary.simpleMessage("CoT 스택 표시"),
    "small": MessageLookupByLibrary.simpleMessage("작음 (90%)"),
    "speed": MessageLookupByLibrary.simpleMessage("속도:"),
    "start_a_new_chat": MessageLookupByLibrary.simpleMessage("새 채팅 시작"),
    "start_a_new_chat_by_clicking_the_button_below":
        MessageLookupByLibrary.simpleMessage("아래 버튼을 클릭하여 새 채팅을 시작할 수 있습니다."),
    "start_a_new_game": MessageLookupByLibrary.simpleMessage("시작"),
    "start_to_chat": MessageLookupByLibrary.simpleMessage("채팅 시작"),
    "start_to_inference": MessageLookupByLibrary.simpleMessage("추론 시작"),
    "technical_research_group": MessageLookupByLibrary.simpleMessage(
      "기술 연구 그룹",
    ),
    "the_puzzle_is_not_valid": MessageLookupByLibrary.simpleMessage(
      "퍼즐이 유효하지 않습니다",
    ),
    "thinking": MessageLookupByLibrary.simpleMessage("생각 중..."),
    "this_is_the_hardest_sudoku_in_the_world":
        MessageLookupByLibrary.simpleMessage("이것은 세계에서 가장 어려운 스도쿠입니다"),
    "thought_result": MessageLookupByLibrary.simpleMessage("사고 결과"),
    "twitter": MessageLookupByLibrary.simpleMessage("Twitter"),
    "ultra_large": MessageLookupByLibrary.simpleMessage("엄청 큼 (140%)"),
    "update_now": MessageLookupByLibrary.simpleMessage("지금 업데이트"),
    "use_it_now": MessageLookupByLibrary.simpleMessage("지금 사용하기"),
    "value_must_be_between_0_and_9": MessageLookupByLibrary.simpleMessage(
      "값은 0에서 9 사이여야 합니다",
    ),
    "very_small": MessageLookupByLibrary.simpleMessage("매우 작음 (80%)"),
    "voice_cloning": MessageLookupByLibrary.simpleMessage("음성 복제"),
    "welcome_to_use_rwkv": MessageLookupByLibrary.simpleMessage(
      "RWKV 사용을 환영합니다",
    ),
    "white": MessageLookupByLibrary.simpleMessage("백"),
    "white_score": MessageLookupByLibrary.simpleMessage("백 점수"),
    "white_wins": MessageLookupByLibrary.simpleMessage("백 승리!"),
    "you_are_now_using": m2,
    "you_can_now_start_to_chat_with_rwkv": MessageLookupByLibrary.simpleMessage(
      "이제 RWKV와 채팅을 시작할 수 있습니다",
    ),
    "you_can_select_a_role_to_chat": MessageLookupByLibrary.simpleMessage(
      "채팅할 역할을 선택할 수 있습니다",
    ),
  };
}
