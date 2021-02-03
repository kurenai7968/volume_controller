# volume_controller

A Flutter plugin for iOS and Android get/set/listen system volume.

## Functions

- getVolume: get current volume from system
    > VolumeController.getVolume()
- maxVolume: set the volume to max
    > VolumeController.maxVolume()
- muteVolume: mute the volume
    > VolumeController.muteVolume()
- setVolume: input a double number to set system volume. The range is [0, 1]
    > await VolumeController.setVolume(double volume)
- volumeListener: listen system volume
    > VolumeController.volumeListener.listen((volume) { // TODO });

## Usage

```dart

class _MyAppState extends State<MyApp> {
  double _volumeListenerValue = 0;
  double _getVolume = 0;
  double _setVolumeValue = 0;

  @override
  void initState() {
    super.initState();
    VolumeController.volumeListener.listen((volume) {
      setState(() => _volumeListenerValue = volume);
    });
    VolumeController.getVolume().then((volume) => _setVolumeValue = volume);
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
                      VolumeController.setVolume(_setVolumeValue);
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
                    _getVolume = await VolumeController.getVolume();
                    setState(() {});
                  },
                  child: Text('Get Volume'),
                ),
              ],
            ),
            TextButton(
              onPressed: () => VolumeController.muteVolume(),
              child: Text('Mute Volume'),
            ),
            TextButton(
              onPressed: () => VolumeController.maxVolume(),
              child: Text('Max Volume'),
            ),
          ],
        ),
      ),
    );
  }
}
```
