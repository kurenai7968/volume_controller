import 'dart:async';

import 'package:flutter/services.dart';

class VolumeController {
  static const MethodChannel _methodChannel =
      MethodChannel('com.kurenai7968.volume_controller.method');
  static const EventChannel _eventChannel =
      EventChannel('com.kurenai7968.volume_controller.volume_listener_event');

  static Stream<double> get volumeListener {
    return _eventChannel.receiveBroadcastStream().map((d) => d as double);
  }

  static void setVolume(double volume) {
    if (volume != null) {
      _methodChannel.invokeMethod('setVolume', {"volume": volume});
    } else {
      print("Volume value cannot be null");
    }
  }

  static Future<double> getVolume() async {
    return await _methodChannel.invokeMethod('getVolume');
  }
}
