import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

enum RecordingState { idle, recording, ready, playing, unavailable }

class RecordingController extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  RecordingState state = RecordingState.idle;
  String? recordingPath;
  String? message;

  RecordingController() {
    _player.onPlayerComplete.listen((_) {
      state = RecordingState.ready;
      notifyListeners();
    });
  }

  Future<void> toggleRecord() async {
    if (state == RecordingState.recording) {
      recordingPath = await _recorder.stop();
      state = recordingPath == null
          ? RecordingState.idle
          : RecordingState.ready;
      notifyListeners();
      return;
    }
    try {
      if (!await _recorder.hasPermission()) {
        state = RecordingState.unavailable;
        message = 'Microphone access was not granted. You can still practise and self-rate.';
      } else {
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.opus),
          path: 'speakloop-practice.opus',
        );
        state = RecordingState.recording;
        message = null;
      }
    } on Object {
      state = RecordingState.unavailable;
      message = 'Recording is unavailable here. You can still practise aloud and self-rate.';
    }
    notifyListeners();
  }

  Future<void> play() async {
    final path = recordingPath;
    if (path == null) return;
    state = RecordingState.playing;
    notifyListeners();
    await _player.play(
      path.startsWith('blob:') || path.startsWith('http')
          ? UrlSource(path)
          : DeviceFileSource(path),
    );
  }

  Future<void> discard() async {
    await _player.stop();
    recordingPath = null;
    state = RecordingState.idle;
    message = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}
