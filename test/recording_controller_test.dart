import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:speakloop/features/practice/recording_controller.dart';

void main() {
  test('discard cancels an active recording', () async {
    final capture = _FakeCapture();
    final playback = _FakePlayback();
    final controller = RecordingController(
      capture: capture,
      playback: playback,
    );

    await controller.toggleRecord();
    await controller.discard();

    expect(capture.cancelCalls, 1);
    expect(controller.state, RecordingState.idle);
    expect(controller.recordingPath, isNull);
  });

  test(
    'playback failure restores ready state with an honest message',
    () async {
      final capture = _FakeCapture(path: 'recording.opus');
      final playback = _FakePlayback(failPlay: true);
      final controller = RecordingController(
        capture: capture,
        playback: playback,
      );
      await controller.toggleRecord();
      await controller.toggleRecord();

      await controller.play();

      expect(controller.state, RecordingState.ready);
      expect(controller.message, contains('play'));
    },
  );

  test(
    'discard invalidates a microphone start that is still pending',
    () async {
      final capture = _FakeCapture(waitForStart: true);
      final controller = RecordingController(
        capture: capture,
        playback: _FakePlayback(),
      );

      final starting = controller.toggleRecord();
      await Future<void>.delayed(Duration.zero);
      await controller.discard();
      capture.completeStart();
      await starting;

      expect(capture.cancelCalls, 1);
      expect(controller.state, RecordingState.idle);
    },
  );
}

class _FakeCapture implements AudioCapture {
  _FakeCapture({this.path = 'recording.opus', bool waitForStart = false})
    : _startCompleter = waitForStart ? Completer<void>() : null;
  final String? path;
  final Completer<void>? _startCompleter;
  int cancelCalls = 0;
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<void> start() => _startCompleter?.future ?? Future.value();
  @override
  Future<String?> stop() async => path;
  @override
  Future<void> cancel() async {
    cancelCalls++;
  }

  @override
  Future<void> dispose() async {}

  void completeStart() => _startCompleter?.complete();
}

class _FakePlayback implements AudioPlayback {
  _FakePlayback({this.failPlay = false});
  final bool failPlay;
  final _completions = StreamController<void>.broadcast();
  @override
  Stream<void> get onComplete => _completions.stream;
  @override
  Future<void> play(String path) async {
    if (failPlay) throw StateError('decode failed');
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {
    await _completions.close();
  }
}
