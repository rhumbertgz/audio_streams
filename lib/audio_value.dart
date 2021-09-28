class AudioValue {
  /// True after [AudioController.initialize] has completed successfully.
  final bool isInitialized;
  final bool isStreamingAudio;

  const AudioValue({
    this.isInitialized = false,
    this.isStreamingAudio = false,
  });

  const AudioValue.uninitialized()
      : this(isInitialized: false, isStreamingAudio: false);

  AudioValue copyWith({
    bool isInitialized = false,
    bool isStreamingAudio = false,
  }) {
    return AudioValue(
      isInitialized: isInitialized,
      isStreamingAudio: isStreamingAudio,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'isInitialized: $isInitialized,'
        'isStreamingAudio: $isStreamingAudio)';
  }
}
