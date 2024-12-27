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

  /// This method listen to the system volume. The volume value will be generated when the volume was changed.
  StreamSubscription<double> listener(Function(double)? onData) {
    if (_volumeListener != null) {
      removeListener();
    }

    _volumeListener = _eventChannel
        .receiveBroadcastStream()
        .map((d) => d as double)
        .listen(onData);

    return _volumeListener!;
  }

  /// This method for canceling volume listener
  void removeListener() {
    _volumeListener?.cancel();
    _volumeListener = null;
  }

  /// This method get the current system volume.
  Future<double> getVolume() async {
    return await _methodChannel
        .invokeMethod<double>(MethodName.getVolume)
        .then<double>((double? value) => value ?? 0);
  }

  /// This method set the system volume between 0.0 to 1.0.
  void setVolume(double volume) {
    _methodChannel.invokeMethod(MethodName.setVolume, {
      MethodArgument.volume: volume,
      MethodArgument.showSystemUI: showSystemUI,
    });
  }

  /// This method set the system volume to max.
  void maxVolume() {
    _methodChannel.invokeMethod(MethodName.setVolume, {
      MethodArgument.volume: 1.0,
      MethodArgument.showSystemUI: showSystemUI,
    });
  }

  /// This method mute the system volume that mean the volume set to min.
  void muteVolume() {
    _methodChannel.invokeMethod(MethodName.setVolume, {
      MethodArgument.volume: 0.0,
      MethodArgument.showSystemUI: showSystemUI,
    });
  }
}
