import CoreAudio
import FlutterMacOS

public class VolumeListener: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var defaultDeviceID: AudioObjectID?
  private var isObserving = false
  private var observedAddresses: [AudioObjectPropertyAddress] = []

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    let args = arguments as? [String: Any]
    let fetchInitialVolume = args?[EventArgument.fetchInitialVolume] as? Bool ?? false

    self.eventSink = events
    startObservingVolumeChanges()

    if fetchInitialVolume {
      emit(AudioHelper.getVolume(), with: events)
    }

    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopObservingVolumeChanges()
    self.eventSink = nil
    return nil
  }

  private let propertyListener: AudioObjectPropertyListenerProc = {
    (_, _, _, inClientData) in
    guard let inClientData else {
      return noErr
    }
    let listener = Unmanaged<VolumeListener>.fromOpaque(inClientData).takeUnretainedValue()
    listener.handlePropertyChange()
    return noErr
  }

  private func startObservingVolumeChanges() {
    guard !isObserving else { return }

    addListener(
      objectID: AudioObjectID(kAudioObjectSystemObject),
      address: AudioHelper.defaultOutputDeviceAddress())

    observeCurrentOutputDevice()
    isObserving = true
  }

  private func stopObservingVolumeChanges() {
    guard isObserving else { return }

    removeListener(
      objectID: AudioObjectID(kAudioObjectSystemObject),
      address: AudioHelper.defaultOutputDeviceAddress())
    removeCurrentOutputDeviceListeners()
    isObserving = false
  }

  private func handlePropertyChange() {
    let currentDeviceID = AudioHelper.getDefaultOutputDeviceID()
    if currentDeviceID != defaultDeviceID {
      removeCurrentOutputDeviceListeners()
      observeCurrentOutputDevice()
    }
    notifyVolumeChange()
  }

  private func observeCurrentOutputDevice() {
    defaultDeviceID = AudioHelper.getDefaultOutputDeviceID()
    guard let deviceID = defaultDeviceID else {
      print("Could not get default output device ID")
      return
    }

    let addresses =
      AudioHelper.volumePropertyAddresses(deviceID: deviceID)
      + AudioHelper.mutePropertyAddresses(deviceID: deviceID)
    for address in addresses {
      addListener(objectID: deviceID, address: address)
      observedAddresses.append(address)
    }
  }

  private func removeCurrentOutputDeviceListeners() {
    guard let deviceID = defaultDeviceID else { return }
    for address in observedAddresses {
      removeListener(objectID: deviceID, address: address)
    }
    observedAddresses.removeAll()
    defaultDeviceID = nil
  }

  private func addListener(objectID: AudioObjectID, address: AudioObjectPropertyAddress) {
    var mutableAddress = address
    let status = AudioObjectAddPropertyListener(
      objectID, &mutableAddress, propertyListener, Unmanaged.passUnretained(self).toOpaque())
    if status != noErr {
      print("Error adding audio property listener: \(status)")
    }
  }

  private func removeListener(objectID: AudioObjectID, address: AudioObjectPropertyAddress) {
    var mutableAddress = address
    let status = AudioObjectRemovePropertyListener(
      objectID, &mutableAddress, propertyListener, Unmanaged.passUnretained(self).toOpaque())
    if status != noErr {
      print("Error removing audio property listener: \(status)")
    }
  }

  private func notifyVolumeChange() {
    emit(AudioHelper.getVolume())
  }

  private func emit(_ volume: Float, with sink: FlutterEventSink? = nil) {
    let eventSink = sink ?? self.eventSink

    DispatchQueue.main.async {
      eventSink?(volume)
    }
  }
}
