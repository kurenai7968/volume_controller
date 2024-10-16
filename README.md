# volume_controller

A Flutter plugin for iOS and Android control system volume.

## Variables

- bool showSystemUI: show or hide volume system UI \
  The default value is true.
    > VolumeController().showSystemUI = true

## Functions

- getVolume: get current volume from system
    > VolumeController().getVolume()
- setVolume: input a double number to set system volume. The range is [0, 1]
    > await VolumeController().setVolume(double volume, {bool? showSystemUI})
- maxVolume: set the volume to max
    > VolumeController().maxVolume({bool? showSystemUI})
- muteVolume: mute the volume
    > VolumeController().muteVolume({bool? showSystemUI})
- watchVolume: watches system volume
    > VolumeController().watchVolume()

## Usage

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<double> _subscription; 
  
  double _volumeListenerValue = 0;
  double _getVolume = 0;
  double _setVolumeValue = 0;

  @override
  void initState() {
    super.initState();
    // Listen to system volume change
    _subscription = VolumeController().watchVolume().listen((volume) {
      setState(() => _volumeListenerValue = volume);
    });

    VolumeController().getVolume().then((volume) => _setVolumeValue = volume);
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
            Text('Current volume: $_volumeListenerValue'),
            Row(
              children: [
                Text('Set Volume:'),
                Flexible(
                  child: Slider(
                    min: 0,
                    max: 1,
                    onChanged: (double value) {
                      _setVolumeValue = value;
                      VolumeController().setVolume(_setVolumeValue);
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
                    _getVolume = await VolumeController().getVolume();
                    setState(() {});
                  },
                  child: Text('Get Volume'),
                ),
              ],
            ),
            TextButton(
              onPressed: () => VolumeController().muteVolume(),
              child: Text('Mute Volume'),
            ),
            TextButton(
              onPressed: () => VolumeController().maxVolume(),
              child: Text('Max Volume'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Show system UI:${VolumeController().showSystemUI}'),
                TextButton(
                  onPressed: () => setState(() => VolumeController().showSystemUI = !VolumeController().showSystemUI),
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
```
