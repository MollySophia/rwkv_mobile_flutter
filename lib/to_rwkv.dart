enum ToRWKV {
  clearStates,
  dumpLog,
  generateAsync,
  generate,
  getEnableReasoning,
  getIsGenerating,
  getPrefillAndDecodeSpeed,
  getPrompt,
  getTTSGenerationProgress,
  getTTSOutputFileList,

  /// 获取responseBufferContentstop之后responseBufferContent还保留着，然后resume之后responseBufferContent会先短暂清空，然后变成stop前已经生成了的内容并接着生成
  getResponseBufferContent,
  getResponseBufferIds,
  getSamplerParams,
  initRuntime,
  loadTTSModels,
  loadTTSTextNormalizer,
  loadVisionEncoder,
  loadWhisperEncoder,
  releaseModel,
  releaseTTSModels,
  releaseVisionEncoder,
  releaseWhisperEncoder,
  runChatAsync,
  runTTS,
  runTTSAsync,
  setAudioPrompt,
  setBosToken,
  setEnableReasoning,
  setEosToken,
  setGenerationStopToken,
  setMaxLength,
  setPrompt,
  setSamplerParams,

  /// decoder steps的api
  ///
  /// 范围3～10吧，越高越慢越精细，可以做成参数
  ///
  /// 默认值现在是5
  ///
  /// args['cfmSteps'] as int
  setTTSCFMSteps,
  setThinkingToken,
  setTokenBanned,
  setUserRole,
  setVisionPrompt,

  /// stop之后responseBufferContent还保留着，然后resume之后responseBufferContent会先短暂清空，然后变成stop前已经生成了的内容并接着生成
  stop,
  ;
}
