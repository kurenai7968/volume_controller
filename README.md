# Volume Controller

[![pub package](https://img.shields.io/pub/v/volume_controller.svg)](https://pub.dev/packages/volume_controller)
[![license](https://img.shields.io/github/license/kurenai7968/volume_controller)](https://github.com/kurenai7968/volume_controller/blob/master/LICENSE)

Control and observe the system volume on Android, iOS, macOS, Windows, and Linux.

## Requirements

- Flutter `>=3.44.0`
- Dart `^3.12.0`

The iOS plugin uses the scene lifecycle APIs introduced for Flutter plugins in Flutter 3.38.

## Supported Platforms

| Platform | Supported |
| -------- | --------- |
| Android  | ✅        |
| iOS      | ✅        |
| macOS    | ✅        |
| Windows  | ✅        |
| Linux    | ✅        |

## Notes

- iOS volume control must be tested on a real device. The simulator does not support system volume control.
- `showSystemUI` is supported on Android and iOS only.
- Mute is not volume `0` on every platform:
  - **Windows, macOS, Linux:** system mute. Volume can stay non-zero while muted.
  - **Android API 23+:** `STREAM_MUSIC` mute (`isStreamMute` / `ADJUST_MUTE`).
  - **Android API 21–22:** mute sets volume to `0` and unmute restores the previous volume saved by the plugin.
  - **iOS:** there is no public system media mute API. `isMuted()` is `volume == 0`. `setMute(true)` sets volume to `0`; `setMute(false)` restores the previous volume saved by the plugin. iOS 26 `AVAudioSession.setOutputMuted` is not used, because it mutes this app's audio session rather than the system volume.

## Variables

### ShowSystemUI

Show or hide the volume system UI. The default value is `true`. Supported on iOS and Android only.

```dart
VolumeController.instance.showSystemUI = true;
```

## Functions

### GetVolume

Get the current system volume.

```dart
double volume = await VolumeController.instance.getVolume();
```

### SetVolume

Set the system volume. The input should be in the range `0.0` to `1.0`.

```dart
await VolumeController.instance.setVolume(double volume);
```

### AddListener

Add a listener to monitor system volume changes.

- `fetchInitialVolume`: This parameter is optional and is used to fetch the initial volume when the listener is added. The default value is `true`.

```dart
VolumeController.instance.addListener((volume) {
  // Do something with the volume
}, fetchInitialVolume: true);
```

### RemoveListener

Remove the volume listener.

```dart
VolumeController.instance.removeListener();
```

### IsMuted

Check whether the system is muted.

```dart
bool isMuted = await VolumeController.instance.isMuted();
```

### SetMute

Mute or unmute the system volume.

```dart
await VolumeController.instance.setMute(bool mute);
```
