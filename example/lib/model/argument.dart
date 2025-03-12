enum Argument {
  temperature,
  topK,
  topP,
  presencePenalty,
  frequencyPenalty,
  penaltyDecay,
  maxLength,
  ;

  bool get configureable => switch (this) {
        temperature => true,
        topK => true,
        topP => true,
        presencePenalty => true,
        frequencyPenalty => true,
        penaltyDecay => false,
        maxLength => true,
      };

  int get fixedDecimals => switch (this) {
        temperature => 1,
        topK => 0,
        topP => 2,
        presencePenalty => 1,
        frequencyPenalty => 1,
        penaltyDecay => 3,
        maxLength => 0,
      };

  double get min => switch (this) {
        temperature => 0.2,
        topK => 1,
        topP => 0.0,
        presencePenalty => 0.0,
        frequencyPenalty => 0.0,
        penaltyDecay => 0.0,
        maxLength => 10,
      };

  double get max => switch (this) {
        temperature => 2.0,
        topK => 1024,
        topP => 1.0,
        presencePenalty => 1.0,
        frequencyPenalty => 1.0,
        penaltyDecay => 1.0,
        maxLength => 64000,
      };

  double get reasonDefaults => switch (this) {
        temperature => 1.0,
        topK => 128,
        topP => 0.3,
        presencePenalty => 0.5,
        frequencyPenalty => 0.5,
        penaltyDecay => 0.996,
        maxLength => 4000,
      };

  double get chatDefaults => switch (this) {
        temperature => 2.0,
        topK => 128,
        topP => 0.5,
        presencePenalty => 0.5,
        frequencyPenalty => 0.5,
        penaltyDecay => 0.996,
        maxLength => 2000,
      };
}
