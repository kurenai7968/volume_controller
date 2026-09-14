import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_controller/src/constants.dart';
import 'package:volume_controller/volume_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel(ChannelName.methodChannel);
  const eventChannel = EventChannel(ChannelName.eventChannel);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<MethodCall> recorded;

  setUp(() {
    recorded = <MethodCall>[];
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      recorded.add(call);
      switch (call.method) {
        case MethodName.getVolume:
          return 0.4;
        case MethodName.isMuted:
          return false;
        case MethodName.setVolume:
        case MethodName.setMute:
          return null;
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
    messenger.setMockStreamHandler(eventChannel, null);
    VolumeController.instance.removeListener();
    VolumeController.instance.showSystemUI = true;
  });

  test('isMuted treats a null platform result as unmuted', () async {
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      if (call.method == MethodName.isMuted) {
        return null;
      }
      return false;
    });

    expect(await VolumeController.instance.isMuted(), isFalse);
  });

  test('setVolume uses the instance showSystemUI by default', () async {
    VolumeController.instance.showSystemUI = false;

    await VolumeController.instance.setVolume(0.3);

    expect(recorded, hasLength(1));
    expect(recorded.single.method, MethodName.setVolume);
    expect(recorded.single.arguments, {
      MethodArgument.volume: 0.3,
      MethodArgument.showSystemUI: false,
    });
  });

  test('setVolume and setMute accept a per-call showSystemUI override', () async {
    await VolumeController.instance.setVolume(0.8, showSystemUI: true);
    await VolumeController.instance.setMute(true, showSystemUI: false);

    expect(recorded[0].arguments[MethodArgument.showSystemUI], isTrue);
    expect(recorded[1].method, MethodName.setMute);
    expect(recorded[1].arguments, {
      MethodArgument.isMute: true,
      MethodArgument.showSystemUI: false,
    });
  });

  test('addListener fetches the current volume when requested', () async {
    final volumes = <double>[];
    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(onListen: (arguments, events) {}),
    );

    final subscription = VolumeController.instance.addListener(
      volumes.add,
      fetchInitialVolume: true,
    );
    await pumpEventQueue();
    await subscription.cancel();
    VolumeController.instance.removeListener();

    expect(volumes, [0.4]);
    expect(
      recorded.where((call) => call.method == MethodName.getVolume),
      isNotEmpty,
    );
  });

  test('volumeChanges emits native volume events', () async {
    final listenReady = Completer<MockStreamHandlerEventSink>();
    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          listenReady.complete(events);
        },
      ),
    );

    final volumes = <double>[];
    final subscription = VolumeController.instance.volumeChanges.listen(
      volumes.add,
    );
    final sink = await listenReady.future;
    sink.success(0.55);
    await pumpEventQueue();
    await subscription.cancel();

    expect(volumes, [0.55]);
  });
}
