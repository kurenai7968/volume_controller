import 'package:flutter/material.dart';
import 'package:flutter_plugin/flutter_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _volumeListenerValue = 0;
  double _getVolume = 0;
  double _setVolumeValue = 0;

  @override
  void initState() {
    super.initState();
    FlutterPlugin.volumeListener.listen((volume) {
      setState(() => _volumeListenerValue = volume);
    });
    FlutterPlugin.getVolume().then((volume) => _setVolumeValue = volume);
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
            Text('Current volume: $_volumeListenerValue'),
            Row(
              children: [
                Text('Set Value: '),
                Flexible(
                  child: Slider(
                    min: 0,
                    max: 1,
                    onChanged: (double value) {
                      _setVolumeValue = value;
                      FlutterPlugin.setVolume(_setVolumeValue);
                      setState(() {});
                    },
                    value: _setVolumeValue,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Volume is: $_getVolume'),
                TextButton(
                  onPressed: () async {
                    _getVolume = await FlutterPlugin.getVolume();
                    setState(() {});
                  },
                  child: Text('Get Volume'),
                ),
              ],
            ),
            TextButton(
              onPressed: () => FlutterPlugin.muteVolume(),
              child: Text('Mute Volume'),
            ),
            TextButton(
              onPressed: () => FlutterPlugin.maxVolume(),
              child: Text('Max Volume'),
            ),
          ],
        ),
      ),
    );
  }
}
