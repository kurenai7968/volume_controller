# Volume Controller

This plugin allows you to control and listen to the system volume on your device. It provides a simple API to get, set, and monitor the system volume.

## Notes

For iOS, you need to test on a real device as the simulator does not support volume control.

## Variables

- `bool showSystemUI`: Show or hide the volume system UI. The default value is `true`.
  Supported on iOS and Android only.

    ```dart
    VolumeController.instance.showSystemUI = true;
    ```

## Functions

- `getVolume`: Get the current volume from the system.

    ```dart
    double volume = await VolumeController.instance.getVolume();
    ```

- `setVolume`: Set the system volume. The input is a double number in the range [0.0, 1.0].

    ```dart
    await VolumeController.instance.setVolume(double volume);
    ```

- `addListener`: Add a listener to monitor system volume changes.
  - `fetchInitialVolume`: This parameter is optional and is used to fetch the initial volume when the listener is added. The default value is `true`.

    ```dart
    VolumeController.instance.addListener((volume) {
      // Do something with the volume
    }, fetchInitialVolume: true);
    ```

- `removeListener`: Remove the volume listener.

    ```dart
    VolumeController.instance.removeListener();
    ```
