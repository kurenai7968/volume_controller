import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_controller/src/constants.dart';
import 'package:volume_controller_example/home_page.dart';
import 'package:volume_controller_example/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel(ChannelName.methodChannel);
  const eventChannel = EventChannel(ChannelName.eventChannel);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      switch (call.method) {
        case MethodName.getVolume:
          return 0.42;
        case MethodName.isMuted:
          return false;
        default:
          return null;
      }
    });
    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(onListen: (arguments, events) {}),
    );
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
    messenger.setMockStreamHandler(eventChannel, null);
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1.0,
    TargetPlatform platform = TargetPlatform.android,
    double dpr = 2.0,
  }) async {
    tester.view.physicalSize = Size(size.width * dpr, size.height * dpr);
    tester.view.devicePixelRatio = dpr;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final padding = platform == TargetPlatform.iOS
        ? const EdgeInsets.only(top: 47, bottom: 34)
        : const EdgeInsets.only(top: 24, bottom: 16);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(buildLightScheme()).copyWith(platform: platform),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              padding: padding,
              viewPadding: padding,
            ),
            child: child!,
          );
        },
        home: HomePage(
          themeMode: ThemeMode.light,
          onToggleTheme: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows live volume and mute controls', (tester) async {
    await pumpHome(tester);

    expect(find.text('Volume Controller'), findsOneWidget);
    expect(find.text('42%'), findsOneWidget);
    expect(find.text('Audible'), findsOneWidget);
    expect(find.text('Mute'), findsOneWidget);
    expect(find.text('Read now'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('does not overflow on a compact iPhone', (tester) async {
    await pumpHome(
      tester,
      size: const Size(320, 568),
      textScale: 1.3,
      platform: TargetPlatform.iOS,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Show system UI'), findsOneWidget);
    expect(find.text('Read now'), findsOneWidget);
  });

  testWidgets('does not overflow at 200% text scale', (tester) async {
    await pumpHome(
      tester,
      size: const Size(360, 640),
      textScale: 2.0,
      platform: TargetPlatform.android,
    );

    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Read now'));
    expect(find.text('Mute'), findsOneWidget);
    expect(find.text('Show system UI'), findsOneWidget);
  });

  testWidgets('does not overflow in landscape', (tester) async {
    await pumpHome(
      tester,
      size: const Size(568, 320),
      platform: TargetPlatform.iOS,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('42%'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('commits volume when the slider is released', (tester) async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      calls.add(call);
      switch (call.method) {
        case MethodName.getVolume:
          return 0.42;
        case MethodName.isMuted:
          return false;
        default:
          return null;
      }
    });

    await pumpHome(tester);
    final slider = find.byType(Slider);
    final gesture = await tester.startGesture(tester.getCenter(slider));
    await gesture.moveBy(const Offset(48, 0));
    await tester.pump();

    expect(
      calls.where((call) => call.method == MethodName.setVolume),
      isEmpty,
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(
      calls.where((call) => call.method == MethodName.setVolume),
      isNotEmpty,
    );
  });

  testWidgets('rapid volume updates do not throw duplicate keys', (tester) async {
    await pumpHome(tester);
    final gesture = await tester.startGesture(tester.getCenter(find.byType(Slider)));
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.moveBy(const Offset(-80, 0));
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump(const Duration(milliseconds: 40));

    expect(tester.takeException(), isNull);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
