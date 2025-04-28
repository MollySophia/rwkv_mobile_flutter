enum ToRWKV {
  clearStates,
  dumpLog,
  generate,
  generateBlocking,
  getEnableReasoning,
  getIsGenerating,
  getPrefillAndDecodeSpeed,
  getPrompt,
  getResponseBufferContent,
  getResponseBufferIds,
  getSamplerParams,
  @Deprecated("")
  getTTSSpkNames,
  initRuntime,
  loadTTSModels,
  loadVisionEncoder,
  loadWhisperEncoder,
  message,
  releaseModel,
  releaseTTSModels,
  releaseVisionEncoder,
  releaseWhisperEncoder,
  runTTS,
  @Deprecated('Use runTTS instead')
  runTTSWithPredefinedSpk,
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
  stop,
  ;
}
