import 'dart:async';

import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final VolumeController _volumeController;
  late final StreamSubscription<double> _subscription;

  double _currentVolume = 0;
  double _volumeValue = 0;

  @override
  void initState() {
    super.initState();

    _volumeController = VolumeController.instance;

    // Listen to system volume change
    _subscription = _volumeController.addListener((volume) {
      setState(() => _volumeValue = volume);
    }, fetchInitialVolume: true);

    _volumeController.getVolume().then((volume) => _volumeValue = volume);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Volume Plugin example app'),
        ),
        body: Column(
          children: [
            Text('Current volume: $_volumeValue'),
            Row(
              children: [
                Text('Set Volume:'),
                Flexible(
                  child: Slider(
                    min: 0,
                    max: 1,
                    onChanged: (double value) async =>
                        await _volumeController.setVolume(value),
                    value: _volumeValue,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Volume is: $_currentVolume'),
                TextButton(
                  onPressed: () async {
                    _currentVolume = await _volumeController.getVolume();
                    setState(() {});
                  },
                  child: Text('Get Volume'),
                ),
              ],
            ),
            TextButton(
              onPressed: () async => await _volumeController.muteVolume(),
              child: Text('Mute Volume'),
            ),
            TextButton(
              onPressed: () async => await _volumeController.maxVolume(),
              child: Text('Max Volume'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Show system UI:${_volumeController.showSystemUI}'),
                TextButton(
                  onPressed: () => setState(
                    () => _volumeController.showSystemUI =
                        !_volumeController.showSystemUI,
                  ),
                  child: Text('Show/Hide UI'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
