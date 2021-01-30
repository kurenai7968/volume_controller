import 'package:flutter/material.dart';

import 'package:volume_controller/volume_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController _textController = TextEditingController();
  double _volume = 0;
  double _getVolume = 0;

  @override
  void initState() {
    super.initState();
    VolumeController.volumeListener.listen((volume) {
      setState(() => _volume = volume);
    });
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
            Text('Current volume: $_volume'),
            Row(
              children: [
                Flexible(child: TextField(controller: _textController)),
                RaisedButton(
                  color: Colors.blue,
                  onPressed: () {
                    if (_textController.text != '') {
                      VolumeController.setVolume(
                          double.parse(_textController.text));
                      setState(() {});
                    }
                  },
                  child: Text('Set Volume By Value'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Volume is: $_getVolume'),
                RaisedButton(
                  color: Colors.blue,
                  onPressed: () async {
                    _getVolume = await VolumeController.getVolume();
                    setState(() {});
                  },
                  child: Text('Get Volume'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
