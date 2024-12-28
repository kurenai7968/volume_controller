import AVFoundation
import Flutter
import Foundation
import MediaPlayer
import UIKit

public class VolumeListener: NSObject, FlutterStreamHandler {
  private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
  private var eventSink: FlutterEventSink?
  private var isObserving: Bool = false
  private let volumeKey: String = "outputVolume"

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    eventSink = events
    registerVolumeObserver()

    // sink the initial volume
    eventSink?(audioSession.outputVolume)

    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    removeVolumeObserver()

    return nil
  }

  private func registerVolumeObserver() {
    do {
      try audioSession.setCategory(AVAudioSession.Category.playback)
      try audioSession.setActive(true)
      if !isObserving {
        audioSession.addObserver(
          self,
          forKeyPath: volumeKey,
          options: .new,
          context: nil)
        isObserving = true
      }
    } catch (let e) {
      print("Volume Controller Listener occurred error. \(e)")
    }
  }

  private func removeVolumeObserver() {
    if isObserving {
      audioSession.removeObserver(
        self,
        forKeyPath: volumeKey)
      isObserving = false
    }
  }

  override public func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    if keyPath == volumeKey {
      eventSink?(audioSession.outputVolume)
    }
  }
}
