import 'dart:async';

import 'package:flutter/services.dart';

/// Provide the iOS/Androd system volume.
class VolumeController {
  /// Singleton class instance
  static VolumeController? _instance;

  /// This method channel is used to communicate with iOS/Android method.
  MethodChannel _methodChannel =
      MethodChannel('com.kurenai7968.volume_controller.method');

  /// This event channel is used to communicate with iOS/Android event.
  EventChannel _eventChannel =
      EventChannel('com.kurenai7968.volume_controller.volume_listener_event');

  /// This value is used to determine whether showing system UI
  bool showSystemUI = true;

  /// Volume Listener Subscription
  StreamSubscription<double>? _volumeListener;

  /// Singleton constructor
  VolumeController._();

  /// Singleton factory
  factory VolumeController() {
    if (_instance == null) _instance = VolumeController._();
    return _instance!;
  }

  /// This method listen to the system volume. The volume value will be generated when the volume was changed.
  StreamSubscription<double> listener(Function(double)? onData) {
    _volumeListener = _eventChannel
        .receiveBroadcastStream()
        .map((d) => d as double)
        .listen(onData);
    return _volumeListener!;
  }

  /// This method for canceling volume listener
  void removeListener() {
    _volumeListener?.cancel();
  }

  /// This method get the current system volume.
  Future<double> getVolume() async {
    return await _methodChannel
        .invokeMethod<double>('getVolume')
        .then<double>((double? value) => value ?? 0);
  }

  /// This method set the system volume between 0.0 to 1.0.
  void setVolume(double volume, {bool? showSystemUI}) {
    _methodChannel.invokeMethod('setVolume',
        {"volume": volume, "showSystemUI": showSystemUI ?? this.showSystemUI});
  }

  /// This method set the system volume to max.
  void maxVolume({bool? showSystemUI}) {
    _methodChannel.invokeMethod('setVolume',
        {"volume": 1.0, "showSystemUI": showSystemUI ?? this.showSystemUI});
  }

  /// This method mute the system volume that mean the volume set to min.
  void muteVolume({bool? showSystemUI}) {
    _methodChannel.invokeMethod('setVolume',
        {"volume": 0.0, "showSystemUI": showSystemUI ?? this.showSystemUI});
  }
}
