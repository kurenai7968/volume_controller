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

  init(audioSession: AVAudioSession) {
    self.audioSession = audioSession
  }

  public var isObservingVolume: Bool {
    return isObserving
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    let args = arguments as? [String: Any]
    let fetchInitialVolume = args?[EventArgument.fetchInitialVolume] as? Bool ?? false

    self.eventSink = events
    registerVolumeObserver()

    if fetchInitialVolume {
      emit(audioSession.getVolume(), with: events)
    }

    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    removeVolumeObserver()
    return nil
  }

  private func registerVolumeObserver() {
    guard !isObserving else { return }

    audioSession.prepareForVolumeObservation()
    audioSession.addObserver(
      self,
      forKeyPath: volumeKey,
      options: .new,
      context: nil)
    isObserving = true
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
    emit(audioSession.getVolume())
  }

  public func sendVolumeChangeEvent() {
    emit(audioSession.getVolume())
  }

  public func resumeVolumeObservation() {
    guard isObserving else { return }
    audioSession.prepareForVolumeObservation()
    sendVolumeChangeEvent()
  }

  private func emit(_ volume: Float, with sink: FlutterEventSink? = nil) {
    let eventSink = sink ?? self.eventSink

    DispatchQueue.main.async {
      eventSink?(volume)
    }
  }
}
