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
        topK => false,
        topP => true,
        presencePenalty => true,
        frequencyPenalty => true,
        penaltyDecay => true,
        maxLength => true,
      };

  bool get show => switch (this) {
        temperature => true,
        topK => false,
        topP => true,
        presencePenalty => true,
        frequencyPenalty => true,
        penaltyDecay => true,
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

  double? get step => switch (this) {
        temperature => 0.1,
        topK => null,
        topP => 0.05,
        presencePenalty => null,
        frequencyPenalty => null,
        penaltyDecay => 0.001,
        maxLength => 100,
      };

  double get min => switch (this) {
        temperature => 0.2,
        topK => 0,
        topP => 0.0,
        presencePenalty => 0.0,
        frequencyPenalty => 0.0,
        penaltyDecay => 0.99,
        maxLength => 100,
      };

  double get max => switch (this) {
        temperature => 2.0,
        topK => 0,
        topP => 1.0,
        presencePenalty => 1.0,
        frequencyPenalty => 1.0,
        penaltyDecay => 0.999,
        maxLength => 10000,
      };

  double get reasonDefaults => switch (this) {
        temperature => 1.0,
        topK => 500,
        topP => 0.3,
        presencePenalty => 0.5,
        frequencyPenalty => 0.5,
        penaltyDecay => 0.996,
        maxLength => 4000,
      };

  double get defaults => switch (this) {
        temperature => 1.0,
        topK => 500,
        topP => 0.3,
        presencePenalty => 0.5,
        frequencyPenalty => 0.5,
        penaltyDecay => 0.996,
        maxLength => 2000,
      };
}
