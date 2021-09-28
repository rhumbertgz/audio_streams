import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'audio_streams_exception.dart';
import 'audio_value.dart';

enum CommonFormat { Int16, Int32 }

class AudioStreams extends ValueNotifier<AudioValue> {
  static const MethodChannel _channel = MethodChannel('audio_streams');
  final int sampleRate;
  final bool interleaved;
  final int channelCount;
  final CommonFormat commonFormat;
  Stream<List<int>> _audioStreamSubscription = const Stream.empty();

  //Control Features
  bool isStreaming = false;
  bool _isDisposed = false;

  AudioStreams(
      this.commonFormat, this.sampleRate, this.channelCount, this.interleaved)
      : super(const AudioValue.uninitialized());

  Future<void> initialize() async {
    if (_isDisposed) {
      return Future<void>.value();
    }
    try {
      await _channel.invokeMethod(
        'initialize',
        <String, dynamic>{
          'commonFormat': _parseCommonFormat(commonFormat),
          'sampleRate': sampleRate,
          'interleaved': interleaved,
          'channelCount': _parseChannelCount(channelCount)
        },
      );
      value = value.copyWith(
        isInitialized: true,
      );
    } on PlatformException catch (e) {
      throw AudioStreamsException(e.code, e.message);
    }
  }

  Stream<List<int>> startAudioStream() {
    if (!value.isInitialized || _isDisposed) {
      throw AudioStreamsException(
        'Uninitialized AudioController',
        'startAudioStream was called on uninitialized AudioController.',
      );
    }
    if (value.isStreamingAudio) {
      throw AudioStreamsException(
        'A mic has started streaming audio.',
        'startAudioStream was called while a mic was streaming audio.',
      );
    }

    try {
      value = value.copyWith(isStreamingAudio: true);
    } on PlatformException catch (e) {
      throw AudioStreamsException(e.code, e.message);
    }
    const EventChannel audioChannel = EventChannel('audio');
    _audioStreamSubscription = audioChannel
        .receiveBroadcastStream()
        .map((dynamic convert) => List<int>.from(convert));
    return _audioStreamSubscription;
  }

  //Releases Microphone
  Future<void> stopAudioStream() async {
    if (!value.isInitialized || _isDisposed) {
      throw AudioStreamsException(
        'Uninitialized AudioController',
        'stopAudioStream was called on uninitialized AudioController.',
      );
    }
    if (!value.isStreamingAudio) {
      throw AudioStreamsException(
        "A mic isn't streaming audio.",
        'stopAudioStream was called while a mic was not streaming audio.',
      );
    }

    try {
      value = value.copyWith(isStreamingAudio: false);
    } on PlatformException catch (e) {
      throw AudioStreamsException(e.code, e.message);
    }

    _audioStreamSubscription = const Stream.empty();
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    super.dispose();
  }

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  String _parseCommonFormat(CommonFormat format) {
    switch (format) {
      case CommonFormat.Int16:
        return "AVAudioCommonFormat.pcmFormatInt16";
      case CommonFormat.Int32:
        return "AVAudioCommonFormat.pcmFormatInt32";
    }
  }

  int _parseChannelCount(int count) {
    switch (count) {
      case 1:
        return 1;
      case 2:
        return 2;
    }
    throw ArgumentError('Unknown ChannelCount value');
  }
}
