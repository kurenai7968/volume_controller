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
- listener: listen system volume
    > VolumeController().listener((volume) { // TODO });
- removeListener: cancel listen system volume
    > VolumeController().removeListener()

## Usage example of a new feature update

![Screenshot_20231118-162138](https://github.com/Swan1993/volume_controller/assets/59397057/d9bfea7c-be7c-49e8-9852-14505b890966)


![20231120_051156](https://github.com/Swan1993/volume_controller/assets/59397057/0ce5747c-5718-45c7-b009-6e45f8bb3e97)


```dart
VolumeSlider(
                display: Display.HORIZONTAL,
                sliderActiveColor: Theme.of(context).primaryColor,
                muteIconColor: Theme.of(context).primaryColor,
                upVolumeIconColor: Theme.of(context).primaryColor,
                visibleWidget: true,
                sliderInActiveColor: Theme.of(context).dividerColor,
              ),
              VolumeSlider(
                display: Display.VERTICAL,
                sliderActiveColor: Theme.of(context).primaryColor,
                muteIconColor: Theme.of(context).primaryColor,
                upVolumeIconColor: Theme.of(context).primaryColor,
                visibleWidget: true,
                sliderInActiveColor: Theme.of(context).dividerColor,
              ),

Container(
              color: Colors.amber,
              width: 100,
              height: 250,
              child: const DragDirectionVolume(
                width: 100,
                height: 250,
              ),
```
## Usage

```dart
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
    // Listen to system volume change
    VolumeController().listener((volume) {
      setState(() => _volumeListenerValue = volume);
    });

    VolumeController().getVolume().then((volume) => _setVolumeValue = volume);
  }

  @override
  void dispose() {
    VolumeController().removeListener();
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
