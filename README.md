# volume_controller

A Flutter plugin for iOS and Android control system volume.

## Variables

- bool showSystemUI: show or hide volume system UI \
  The default value is true.
    > VolumeController.instance.showSystemUI = true

## Functions

- getVolume: get current volume from system
    > VolumeController.instance.getVolume()
- setVolume: input a double number to set system volume. The range is [0, 1]
    > await VolumeController.instance.setVolume(double volume)
- maxVolume: set the volume to max
    > VolumeController.instance.maxVolume()
- muteVolume: mute the volume
    > VolumeController.instance.muteVolume()
- listener: listen system volume
    > VolumeController.instance.listener((volume) { // do something });
- removeListener: cancel listen system volume
    > VolumeController.instance.removeListener()

## Usage

```dart
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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
    _subscription = _volumeController.listener((volume) {
      setState(() => _volumeValue = volume);
    });

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
                    onChanged: (double value) {
                      _volumeController.setVolume(value);
                    },
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
              onPressed: () => _volumeController.muteVolume(),
              child: Text('Mute Volume'),
            ),
            TextButton(
              onPressed: () => _volumeController.maxVolume(),
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

```
