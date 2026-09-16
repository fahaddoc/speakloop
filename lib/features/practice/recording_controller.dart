import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

enum RecordingState {
  idle,
  starting,
  recording,
  stopping,
  ready,
  playing,
  unavailable,
}

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
      if (state != RecordingState.playing) return;
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
  bool needsCaptureCleanup = false;
  int _operation = 0;

  Future<void> toggleRecord() async {
    if (needsCaptureCleanup) {
      state = RecordingState.unavailable;
      message = 'Retry microphone cleanup before starting another recording.';
      notifyListeners();
      return;
    }
    if (state == RecordingState.starting || state == RecordingState.stopping) {
      return;
    }
    if (state == RecordingState.recording) {
      await _stopRecording();
      return;
    }
    await _startRecording();
  }

  Future<void> _startRecording() async {
    final operation = ++_operation;
    recordingPath = null;
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
          await _cancelCapture();
          return;
        }
        state = RecordingState.recording;
      }
    } on Object {
      if (operation != _operation) return;
      state = RecordingState.unavailable;
      message = 'Recording is unavailable here. You can still practise aloud and self-rate.';
    }
    notifyListeners();
  }

  Future<void> _stopRecording() async {
    final operation = ++_operation;
    state = RecordingState.stopping;
    notifyListeners();
    try {
      final path = await _capture.stop();
      if (operation != _operation) return;
      recordingPath = path;
      state = path == null ? RecordingState.idle : RecordingState.ready;
      message = path == null
          ? 'No recording was captured. You can try again.'
          : null;
    } on Object {
      final cancelled = await _cancelCapture();
      if (operation != _operation) return;
      recordingPath = null;
      needsCaptureCleanup = !cancelled;
      state = RecordingState.unavailable;
      message = cancelled
          ? 'Recording could not be stopped safely. You can still practise and self-rate.'
          : 'Microphone cleanup failed. Use your browser microphone control before trying again.';
    }
    notifyListeners();
  }

  Future<bool> _cancelCapture() async {
    try {
      await _capture.cancel();
      return true;
    } on Object {
      return false;
    }
  }

  Future<void> play() async {
    final path = recordingPath;
    if (path == null || state != RecordingState.ready) return;
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
    recordingPath = null;
    state = RecordingState.idle;
    message = null;
    notifyListeners();
    final captureCancelled = await _cancelCapture();
    needsCaptureCleanup = !captureCancelled;
    var playbackStopped = true;
    try {
      await _playback.stop();
    } on Object {
      playbackStopped = false;
    }
    if (!captureCancelled) {
      message = 'Microphone cleanup failed. Use your browser microphone control, then try Discard again.';
      notifyListeners();
    } else if (!playbackStopped) {
      message = 'Playback cleanup failed, but the recording was removed from this practice.';
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
