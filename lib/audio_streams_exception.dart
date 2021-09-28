class AudioStreamsException implements Exception {
  String code;
  String? message;

  AudioStreamsException(this.code, this.message);

  @override
  String toString() => '$runtimeType($code, $message)';
}
