import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

enum RecordingState { idle, starting, recording, ready, playing, unavailable }

abstract interface class AudioCapture {
  Future<bool> hasPermission();
  Future<void> start();
  Future<String?> stop();
  Future<void> cancel();
  Future<void> dispose();
}

abstract interface class AudioPlayback {
  Stream<void> get onComplete;
  Future<void> play(String path);
  Future<void> stop();
  Future<void> dispose();
}

class DeviceAudioCapture implements AudioCapture {
  final AudioRecorder _recorder = AudioRecorder();
  @override
  Future<bool> hasPermission() => _recorder.hasPermission();
  @override
  Future<void> start() => _recorder.start(
    const RecordConfig(encoder: AudioEncoder.opus),
    path: 'speakloop-practice.opus',
  );
  @override
  Future<String?> stop() => _recorder.stop();
  @override
  Future<void> cancel() => _recorder.cancel();
  @override
  Future<void> dispose() => _recorder.dispose();
}

class DeviceAudioPlayback implements AudioPlayback {
  final AudioPlayer _player = AudioPlayer();
  @override
  Stream<void> get onComplete => _player.onPlayerComplete;
  @override
  Future<void> play(String path) => _player.play(
    path.startsWith('blob:') || path.startsWith('http')
        ? UrlSource(path)
        : DeviceFileSource(path),
  );
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> dispose() => _player.dispose();
}

class RecordingController extends ChangeNotifier {
  RecordingController({AudioCapture? capture, AudioPlayback? playback})
    : _capture = capture ?? DeviceAudioCapture(),
      _playback = playback ?? DeviceAudioPlayback() {
    _completionSubscription = _playback.onComplete.listen((_) {
      state = RecordingState.ready;
      notifyListeners();
    });
  }

  final AudioCapture _capture;
  final AudioPlayback _playback;
  late final StreamSubscription<void> _completionSubscription;
  RecordingState state = RecordingState.idle;
  String? recordingPath;
  String? message;
  int _operation = 0;

  Future<void> toggleRecord() async {
    if (state == RecordingState.starting) return;
    if (state == RecordingState.recording) {
      try {
        recordingPath = await _capture.stop();
        state = recordingPath == null
            ? RecordingState.idle
            : RecordingState.ready;
        message = recordingPath == null
            ? 'No recording was captured. You can try again.'
            : null;
      } on Object {
        try {
          await _capture.cancel();
        } on Object {
          // The user-facing state below remains safe even if cleanup also fails.
        }
        recordingPath = null;
        state = RecordingState.unavailable;
        message = 'Recording could not be stopped safely. You can still practise and self-rate.';
      }
      notifyListeners();
      return;
    }
    final operation = ++_operation;
    state = RecordingState.starting;
    message = null;
    notifyListeners();
    try {
      if (!await _capture.hasPermission()) {
        if (operation != _operation) return;
        state = RecordingState.unavailable;
        message = 'Microphone access was not granted. You can still practise and self-rate.';
      } else {
        if (operation != _operation) return;
        await _capture.start();
        if (operation != _operation) {
          await _capture.cancel();
          return;
        }
        state = RecordingState.recording;
        message = null;
      }
    } on Object {
      if (operation != _operation) return;
      state = RecordingState.unavailable;
      message = 'Recording is unavailable here. You can still practise aloud and self-rate.';
    }
    notifyListeners();
  }

  Future<void> play() async {
    final path = recordingPath;
    if (path == null) return;
    state = RecordingState.playing;
    message = null;
    notifyListeners();
    try {
      await _playback.play(path);
    } on Object {
      state = RecordingState.ready;
      message = 'This recording could not be played. You can discard it and try again.';
      notifyListeners();
    }
  }

  Future<void> discard() async {
    _operation++;
    final wasRecording = state == RecordingState.recording;
    recordingPath = null;
    state = RecordingState.idle;
    message = null;
    notifyListeners();
    try {
      if (wasRecording) await _capture.cancel();
      await _playback.stop();
    } on Object {
      message = 'The recording stopped with an error, but it has been removed from this practice.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_completionSubscription.cancel());
    unawaited(_capture.dispose());
    unawaited(_playback.dispose());
    super.dispose();
  }
}
