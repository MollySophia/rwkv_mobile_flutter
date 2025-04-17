enum TTSInstruction {
  emotion,
  dialect,
  speed,
  role,
  intonation,
  ;

  String get nameCN => switch (this) {
        emotion => "情感",
        dialect => "方言",
        speed => "语速",
        role => "角色扮演",
        intonation => "语气词",
      };

  String get nameEN => switch (this) {
        emotion => "emotion",
        dialect => "dialect",
        speed => "speed",
        role => "role",
        intonation => "intonation",
      };

  bool get forInstruction => switch (this) {
        intonation => false,
        _ => true,
      };

  List<String> get options => switch (this) {
        emotion => [
            "高兴(Happy)",
            "悲伤(Sad)",
            "惊讶(Surprised)",
            "愤怒(Angry)",
            "恐惧(Fearful)",
            "厌恶(Disgusted)",
            "冷静(Calm)",
            "严肃(Serious)",
          ],
        dialect => [
            "粤语",
            "四川话",
            "上海话",
            "郑州话",
            "长沙话",
            "天津话",
          ],
        speed => [
            "快速(Fast)",
            "非常快速(Very Fast)",
            "慢速(Slow)",
            "非常慢速(Very Slow)",
          ],
        role => [
            "神秘(Mysterious)",
            "凶猛(Fierce)",
            "好奇(Curious)",
            "优雅(Elegant)",
            "孤独(Lonely)",
            "机器人(Robot)",
            "小猪佩奇(Peppa)",
          ],
        intonation => [
            "[breath]",
            "[noise]",
            "[laughter]",
            "[cough]",
            "[clucking]",
            "[accent]",
            "[quick_breath]",
            "[hissing]",
            "[sigh]",
            "[vocalized-noise]",
            "[lipsmack]",
            "[mn]",
          ],
      };

//       当然可以～以下是这些声音标签转换成表情 (emoji) 的版本：

// - `[breath]` → 😮‍💨
// - `[noise]` → 🔊
// - `[laughter]` → 😂
// - `[cough]` → 🤧
// - `[clucking]` → 🐔
// - `[accent]` → 🗣️
// - `[quick_breath]` → 😤
// - `[hissing]` → 🐍
// - `[sigh]` → 😔
// - `[vocalized-noise]` → 🎤
// - `[lipsmack]` → 😗
// - `[mn]` → 🤔

// 如果有特定语境或语气，我可以帮你微调！要不要来点更夸张或可爱风格的？

  List<String> get emojiOptions => switch (this) {
        intonation => [
            "😮‍💨",
            "🔊",
            "😂",
            "🤧",
            "🐔",
            "🗣️",
            "😤",
            "🐍",
            "😔",
            "🎤",
            "😗",
            "🤔",
          ],
        _ => [],
      };
}
