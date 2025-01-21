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
  Future<void> setVolume(double volume) async {
    _methodChannel.invokeMethod(MethodName.setVolume, {
      MethodArgument.volume: volume.clamp(0.0, 1.0),
      MethodArgument.showSystemUI: showSystemUI,
    });
  }
}
