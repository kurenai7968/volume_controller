import 'dart:async';
import 'dart:io';

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
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();

    _volumeController = VolumeController.instance;

    // Listen to system volume change
    _subscription = _volumeController.addListener((volume) {
      setState(() => _volumeValue = volume);
    }, fetchInitialVolume: true);

    _volumeController
        .isMuted()
        .then((isMuted) => setState(() => _isMuted = isMuted));
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
            if (Platform.isAndroid || Platform.isIOS)
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Is Muted:$_isMuted'),
                TextButton(
                  onPressed: () async {
                    await updateMuteStatus(true);
                  },
                  child: Text('Mute'),
                ),
                TextButton(
                  onPressed: () async {
                    await updateMuteStatus(false);
                  },
                  child: Text('Unmute'),
                ),
                TextButton(
                  onPressed: () async {
                    _isMuted = await _volumeController.isMuted();
                    setState(() {});
                  },
                  child: Text('Update Mute Status'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateMuteStatus(bool isMute) async {
    await _volumeController.setMute(isMute);
    if (Platform.isIOS) {
      // On iOS, the system does not update the mute status immediately
      // You need to wait for the system to update the mute status
      await Future.delayed(Duration(milliseconds: 50));
    }
    _isMuted = await _volumeController.isMuted();

    setState(() {});
  }
}
