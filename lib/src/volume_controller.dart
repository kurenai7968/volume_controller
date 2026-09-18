import 'dart:async';

import 'package:flutter/services.dart';
import 'package:volume_controller/src/constants.dart';

/// Provides access to the system volume.
///
/// Mute is a system switch on Windows, macOS, Linux, and Android API 23+.
/// On iOS and older Android, mute is volume `0`, and unmute restores the
/// previous level saved by this plugin.
class VolumeController {
  /// Singleton instance of VolumeController
  static final VolumeController _instance = VolumeController._();

  /// Get the singleton instance of VolumeController
  static VolumeController get instance => _instance;

  /// Method channel for communicating with platform methods.
  final MethodChannel _methodChannel = const MethodChannel(
    ChannelName.methodChannel,
  );

  /// Event channel for communicating with platform events.
  final EventChannel _eventChannel = const EventChannel(
    ChannelName.eventChannel,
  );

  StreamSubscription<double>? _volumeListener;
  Stream<double>? _volumeStream;

  /// Whether to show the system UI when changing the volume.
  ///
  /// Supported on Android and iOS only.
  bool showSystemUI = true;

  /// Private constructor for singleton
  VolumeController._();

  /// Listens for system volume changes.
  ///
  /// If [fetchInitialVolume] is true, the current volume is sent immediately.
  StreamSubscription<double> addListener(
    void Function(double)? onData, {
    bool fetchInitialVolume = true,
  }) {
    _volumeStream ??= _eventChannel
        .receiveBroadcastStream({
          EventArgument.fetchInitialVolume: fetchInitialVolume,
        })
        .map((event) => (event as num).toDouble());

    final previous = _volumeListener;
    final subscription = _volumeStream!.listen(onData);
    _volumeListener = subscription;
    previous?.cancel();

    return subscription;
  }

  /// Cancels the volume listener.
  Future<void> removeListener() async {
    final listener = _volumeListener;
    if (listener == null) {
      return;
    }

    await listener.cancel();

    // addListener may have replaced this subscription during the await.
    if (!identical(_volumeListener, listener)) {
      return;
    }

    _volumeListener = null;
    _volumeStream = null;
  }

  /// Current system volume, from `0.0` to `1.0`.
  Future<double> getVolume() async {
    return await _methodChannel
        .invokeMethod<double>(MethodName.getVolume)
        .then<double>((double? value) => value ?? 0);
  }

  /// Sets the system volume. Values outside `0.0`–`1.0` are clamped.
  Future<void> setVolume(double volume) async {
    await _methodChannel.invokeMethod(MethodName.setVolume, {
      MethodArgument.volume: volume,
      MethodArgument.showSystemUI: showSystemUI,
    });
  }

  /// Whether the system volume is muted.
  Future<bool> isMuted() async {
    return await _methodChannel
        .invokeMethod<bool>(MethodName.isMuted)
        .then<bool>((value) => value ?? false);
  }

  /// Mutes or unmutes the system volume.
  Future<void> setMute(bool mute) async {
    await _methodChannel.invokeMethod(MethodName.setMute, {
      MethodArgument.isMute: mute,
      MethodArgument.showSystemUI: showSystemUI,
    });
  }
}
