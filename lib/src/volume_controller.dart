import 'dart:async';

import 'package:flutter/services.dart';
import 'package:volume_controller/src/constants.dart';

/// Provide the iOS/Android system volume.
class VolumeController {
  /// Singleton class instance
  static final VolumeController _instance = VolumeController._();

  /// Get the singleton instance of VolumeController
  static VolumeController get instance => _instance;

  /// This method channel is used to communicate with iOS/Android method.
  final MethodChannel _methodChannel = MethodChannel(ChannelName.methodChannel);

  /// This event channel is used to communicate with iOS/Android event.
  final EventChannel _eventChannel = EventChannel(ChannelName.eventChannel);

  /// Volume Listener Subscription
  StreamSubscription<double>? _volumeListener;

  /// This variable is used to store the system volume.
  bool showSystemUI = true;

  /// Singleton constructor
  VolumeController._();

  /// Adds a listener for volume changes.
  ///
  /// This method listen to the system volume. The volume value will be generated when the volume was changed.
  /// Optionally, the initial volume can be fetched and provided to the listener immediately.
  StreamSubscription<double> addListener(
    Function(double)? onData, {
    bool fetchInitialVolume = true,
  }) {
    if (_volumeListener != null) {
      removeListener();
    }

    _volumeListener = _eventChannel
        .receiveBroadcastStream({
          EventArgument.fetchInitialVolume: fetchInitialVolume,
        })
        .map((d) => d as double)
        .listen(onData);

    return _volumeListener!;
  }

  /// Cancels the volume listener.
  ///
  /// This method stops listening to volume changes and cleans up the listener.
  void removeListener() {
    _volumeListener?.cancel();
    _volumeListener = null;
  }

  /// Gets the current system volume.
  ///
  /// This method retrieves the current volume level of the system.
  Future<double> getVolume() async {
    return await _methodChannel
        .invokeMethod<double>(MethodName.getVolume)
        .then<double>((double? value) => value ?? 0);
  }

  /// Sets the system volume to the specified level.
  ///
  /// This method sets the system volume to the given level. The volume
  /// value should be a double between 0.0 (minimum volume) and 1.0 (maximum volume).
  Future<void> setVolume(double volume) async {
    _methodChannel.invokeMethod(MethodName.setVolume, {
      MethodArgument.volume: volume,
      MethodArgument.showSystemUI: showSystemUI,
    });
  }

  /// Gets the current system volume mute status.
  Future<bool> isMuted() async {
    return await _methodChannel
        .invokeMethod<bool>(MethodName.isMuted)
        .then<bool>((value) => value!);
  }

  /// Sets the system volume mute status.
  Future<void> setMute(bool mute) async {
    _methodChannel.invokeMethod(MethodName.setMute, {
      MethodArgument.isMute: mute,
      MethodArgument.showSystemUI: showSystemUI,
    });
  }
}
