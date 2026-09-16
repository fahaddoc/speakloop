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

      expect(capture.cancelCalls, greaterThanOrEqualTo(1));
      expect(controller.state, RecordingState.idle);
    },
  );

  test('starting a new capture clears old audio and blocks playback', () async {
    final capture = _FakeCapture(path: 'first.opus');
    final playback = _FakePlayback();
    final controller = RecordingController(
      capture: capture,
      playback: playback,
    );
    await controller.toggleRecord();
    await controller.toggleRecord();
    expect(controller.recordingPath, 'first.opus');

    await controller.toggleRecord();
    await controller.play();

    expect(controller.state, RecordingState.recording);
    expect(controller.recordingPath, isNull);
    expect(playback.playCalls, 0);
  });

  test('discard invalidates a recording stop that completes late', () async {
    final capture = _FakeCapture(waitForStop: true);
    final controller = RecordingController(
      capture: capture,
      playback: _FakePlayback(),
    );
    await controller.toggleRecord();
    final stopping = controller.toggleRecord();
    await Future<void>.delayed(Duration.zero);

    await controller.discard();
    capture.completeStop('late.opus');
    await stopping;

    expect(controller.state, RecordingState.idle);
    expect(controller.recordingPath, isNull);
  });

  test('failed microphone cleanup stays retryable', () async {
    final capture = _FakeCapture(cancelFailures: 1);
    final controller = RecordingController(
      capture: capture,
      playback: _FakePlayback(),
    );
    await controller.toggleRecord();

    await controller.discard();
    expect(controller.needsCaptureCleanup, isTrue);
    expect(controller.message, contains('browser microphone control'));

    await controller.discard();
    expect(controller.needsCaptureCleanup, isFalse);
  });
}

class _FakeCapture implements AudioCapture {
  _FakeCapture({
    this.path = 'recording.opus',
    bool waitForStart = false,
    bool waitForStop = false,
    this.cancelFailures = 0,
  }) : _startCompleter = waitForStart ? Completer<void>() : null,
       _stopCompleter = waitForStop ? Completer<String?>() : null;
  final String? path;
  final Completer<void>? _startCompleter;
  final Completer<String?>? _stopCompleter;
  int cancelFailures;
  int cancelCalls = 0;
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<void> start() => _startCompleter?.future ?? Future.value();
  @override
  Future<String?> stop() => _stopCompleter?.future ?? Future.value(path);
  @override
  Future<void> cancel() async {
    cancelCalls++;
    if (cancelFailures > 0) {
      cancelFailures--;
      throw StateError('cancel failed');
    }
  }

  @override
  Future<void> dispose() async {}

  void completeStart() => _startCompleter?.complete();
  void completeStop(String? value) => _stopCompleter?.complete(value);
}

class _FakePlayback implements AudioPlayback {
  _FakePlayback({this.failPlay = false});
  final bool failPlay;
  final _completions = StreamController<void>.broadcast();
  int playCalls = 0;
  @override
  Stream<void> get onComplete => _completions.stream;
  @override
  Future<void> play(String path) async {
    playCalls++;
    if (failPlay) throw StateError('decode failed');
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {
    await _completions.close();
  }
}
