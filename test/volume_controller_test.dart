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

  test('setMute uses the instance showSystemUI', () async {
    VolumeController.instance.showSystemUI = false;

    await VolumeController.instance.setMute(true);

    expect(recorded.single.method, MethodName.setMute);
    expect(recorded.single.arguments, {
      MethodArgument.isMute: true,
      MethodArgument.showSystemUI: false,
    });
  });

  test('addListener requests the initial volume from the event channel',
      () async {
    final volumes = <double>[];
    Object? listenArgs;
    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          listenArgs = arguments;
          events.success(0.4);
        },
      ),
    );

    final subscription = VolumeController.instance.addListener(
      volumes.add,
      fetchInitialVolume: true,
    );
    await pumpEventQueue();
    await subscription.cancel();
    VolumeController.instance.removeListener();

    expect(volumes, [0.4]);
    expect(listenArgs, {EventArgument.fetchInitialVolume: true});
  });

  test('addListener can skip the initial volume', () async {
    Object? listenArgs;
    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          listenArgs = arguments;
        },
      ),
    );

    final subscription = VolumeController.instance.addListener(
      (_) {},
      fetchInitialVolume: false,
    );
    await pumpEventQueue();
    await subscription.cancel();

    expect(listenArgs, {EventArgument.fetchInitialVolume: false});
  });

  test('addListener emits native volume events', () async {
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
    final subscription = VolumeController.instance.addListener(
      volumes.add,
      fetchInitialVolume: false,
    );
    final sink = await listenReady.future;
    sink.success(0.55);
    await pumpEventQueue();
    await subscription.cancel();

    expect(volumes, [0.55]);
  });
}
