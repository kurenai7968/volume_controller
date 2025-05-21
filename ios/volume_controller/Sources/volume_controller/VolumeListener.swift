import AVFoundation
import Flutter
import Foundation
import MediaPlayer
import UIKit

public class VolumeListener: NSObject, FlutterStreamHandler {
  private let audioSession: AVAudioSession
  private var eventSink: FlutterEventSink?
  private var isObserving: Bool = false
  private let volumeKey: String = "outputVolume"
  private var didActivateAudioSession: Bool = false

  init(audioSession: AVAudioSession) {
    self.audioSession = audioSession
  }

  public var isObservingVolume: Bool {
    return isObserving
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    let args = arguments as! [String: Any]
    let fetchInitialVolume = args[EventArgument.fetchInitialVolume] as! Bool

    self.eventSink = events
    registerVolumeObserver()

    if fetchInitialVolume {
      events(audioSession.getVolume())
    }

    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    // Only deactivate the audio session if we were the ones that activated it
    if didActivateAudioSession {
      audioSession.deactivateAudioSession()
      didActivateAudioSession = false
    }
    
    eventSink = nil
    removeVolumeObserver()

    return nil
  }

  private func registerVolumeObserver() {
    do {
      try audioSession.setAudioSessionCategory()
      try audioSession.activateAudioSession()
      didActivateAudioSession = true
      
      if !isObserving {
        audioSession.addObserver(
          self,
          forKeyPath: volumeKey,
          options: .new,
          context: nil)
        isObserving = true
      }
    } catch {
      print("Error setting up volume observer: \(error)")
    }
  }

  private func removeVolumeObserver() {
    if isObserving {
      audioSession.removeObserver(self, forKeyPath: volumeKey)
      isObserving = false
    }
  }

  override public func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    guard keyPath == volumeKey else {
      return
    }
    eventSink?(audioSession.getVolume())
  }

  public func sendVolumeChangeEvent() {
    eventSink?(audioSession.getVolume())
  }
}
