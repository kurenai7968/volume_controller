import 'dart:async';

import 'package:flutter/services.dart';
import 'package:volume_controller/src/constants.dart';

/// Provides access to the system volume.
///
/// Mute is not the same on every platform:
/// - Windows, macOS, and Linux use the system mute switch, so volume can stay
///   non-zero while muted.
/// - Android (API 23+) mutes `STREAM_MUSIC` the same way. Older Android
///   versions simulate mute by setting the volume to `0` and restoring the
///   previous level on unmute.
/// - iOS has no public system media mute API. [isMuted] is `volume == 0`, and
///   [setMute] sets the volume to `0` or restores the previous level saved by
///   this plugin. iOS 26 `AVAudioSession.setOutputMuted` is not used; it would
///   mute this app's session, not Music or the system volume slider.
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

  /// Volume listener subscription
  StreamSubscription<double>? _volumeListener;

  /// Whether to show the system UI when changing the volume.
  ///
  /// Supported on Android and iOS only.
  bool showSystemUI = true;

  /// Private constructor for singleton
  VolumeController._();

  /// Adds a listener for volume changes.
  ///
  /// This method listens to the system volume. The volume value will be
  /// generated when the volume changes. Optionally, the initial volume can be
  /// fetched and provided to the listener immediately.
  StreamSubscription<double> addListener(
    void Function(double)? onData, {
    bool fetchInitialVolume = true,
  }) {
    removeListener();

    _volumeListener = _eventChannel
        .receiveBroadcastStream({
          EventArgument.fetchInitialVolume: fetchInitialVolume,
        })
        .map((event) => (event as num).toDouble())
        .listen(onData);

    return _volumeListener!;
  }

  /// Cancels the volume listener.
  void removeListener() {
    _volumeListener?.cancel();
    _volumeListener = null;
  }

  /// Gets the current system volume.
  ///
  /// The value is in the range `0.0` (minimum) to `1.0` (maximum).
  Future<double> getVolume() async {
    return await _methodChannel
        .invokeMethod<double>(MethodName.getVolume)
        .then<double>((double? value) => value ?? 0);
  }

  /// Sets the system volume to the specified level.
  ///
  /// [volume] should be a double between `0.0` (minimum) and `1.0` (maximum).
  /// Values outside that range are clamped by the native implementations.
  Future<void> setVolume(double volume) async {
    await _methodChannel.invokeMethod(MethodName.setVolume, {
      MethodArgument.volume: volume,
      MethodArgument.showSystemUI: showSystemUI,
    });
  }

  /// Gets the current system volume mute status.
  ///
  /// On Windows, macOS, Linux, and Android API 23+, this is the OS mute
  /// switch. On iOS and older Android versions, this is `true` when the
  /// reported volume is `0`.
  Future<bool> isMuted() async {
    return await _methodChannel
        .invokeMethod<bool>(MethodName.isMuted)
        .then<bool>((value) => value ?? false);
  }

  /// Sets the system volume mute status.
  ///
  /// On iOS, mute sets the volume to `0` and unmute restores the previous
  /// volume saved by this plugin. Unmute is a no-op if this plugin has not
  /// muted since the last non-zero [setVolume].
  Future<void> setMute(bool mute) async {
    await _methodChannel.invokeMethod(MethodName.setMute, {
      MethodArgument.isMute: mute,
      MethodArgument.showSystemUI: showSystemUI,
    });
  }
}
