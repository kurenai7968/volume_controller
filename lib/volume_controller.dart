import 'dart:async';

import 'package:flutter/services.dart';

/// Provide the iOS/Androd system volume.
class VolumeController {
  /// This method channel is used to communicate with iOS/Android method.
  static const MethodChannel _methodChannel =
      MethodChannel('com.kurenai7968.volume_controller.method');

  /// This event channel is used to communicate with iOS/Android event.
  static const EventChannel _eventChannel =
      EventChannel('com.kurenai7968.volume_controller.volume_listener_event');

  /// This method listen to the system volume. The volume value will be generated when the volume was changed.
  static Stream<double> get volumeListener {
    return _eventChannel.receiveBroadcastStream().map((d) => d as double);
  }

  /// This method set the system volume between 0.0 to 1.0.
  static void setVolume(double volume) {
    _methodChannel.invokeMethod('setVolume', {"volume": volume});
  }

  /// This method set the system volume to max.
  static void maxVolume() {
    _methodChannel.invokeMethod('setVolume', {"volume": 1.0});
  }

  /// This method mute the system volume that mean the volume set to min.
  static void muteVolume() {
    _methodChannel.invokeMethod('setVolume', {"volume": 0.0});
  }

  /// This method get the current system volume.
  static Future<double> getVolume() async {
    return await _methodChannel
        .invokeMethod<double>('getVolume')
        .then<double>((double? value) => value ?? 0);
  }
}
