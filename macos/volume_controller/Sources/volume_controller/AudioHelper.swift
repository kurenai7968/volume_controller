import AudioToolbox
import CoreAudio

public class AudioHelper {
  private static let channelElements: [UInt32] = [1, 2]

  static func getDefaultOutputDeviceID() -> AudioObjectID? {
    var defaultDeviceID = AudioObjectID(0)
    var size = UInt32(MemoryLayout.size(ofValue: defaultDeviceID))
    var propertyAddress = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDefaultOutputDevice,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )

    let status = AudioObjectGetPropertyData(
      AudioObjectID(kAudioObjectSystemObject),
      &propertyAddress,
      0,
      nil,
      &size,
      &defaultDeviceID
    )

    return status == noErr ? defaultDeviceID : nil
  }

  static func getVolume() -> Float {
    guard let deviceID = getDefaultOutputDeviceID() else {
      print("Could not get default output device ID")
      return 0.0
    }

    if let volume = getScalar(deviceID: deviceID, selector: kAudioDevicePropertyVolumeScalar, element: kAudioObjectPropertyElementMain) {
      return volume
    }

    let channelVolumes = channelElements.compactMap {
      getScalar(deviceID: deviceID, selector: kAudioDevicePropertyVolumeScalar, element: $0)
    }
    guard !channelVolumes.isEmpty else {
      print("Error getting volume: no volume channels available")
      return 0.0
    }

    return channelVolumes.reduce(0, +) / Float(channelVolumes.count)
  }

  static func setVolume(volume: Float) {
    guard let deviceID = getDefaultOutputDeviceID() else {
      print("Could not get default output device ID")
      return
    }

    let clamped = min(max(volume, 0.0), 1.0)
    if setScalar(deviceID: deviceID, selector: kAudioDevicePropertyVolumeScalar, element: kAudioObjectPropertyElementMain, value: clamped) {
      return
    }

    var didSet = false
    for element in channelElements {
      if setScalar(deviceID: deviceID, selector: kAudioDevicePropertyVolumeScalar, element: element, value: clamped) {
        didSet = true
      }
    }

    if !didSet {
      print("Error setting volume: no volume channels available")
    }
  }

  static func setMute(isMute: Bool) {
    guard let deviceID = getDefaultOutputDeviceID() else {
      print("Could not get default output device ID")
      return
    }

    let mute: UInt32 = isMute ? 1 : 0
    if setMuteValue(deviceID: deviceID, element: kAudioObjectPropertyElementMain, mute: mute) {
      return
    }

    var didSet = false
    for element in channelElements {
      if setMuteValue(deviceID: deviceID, element: element, mute: mute) {
        didSet = true
      }
    }

    if !didSet {
      print("Error setting mute: no mute channels available")
    }
  }

  static func isMuted() -> Bool {
    guard let deviceID = getDefaultOutputDeviceID() else {
      print("Could not get default output device ID")
      return false
    }

    if let mute = getMuteValue(deviceID: deviceID, element: kAudioObjectPropertyElementMain) {
      return mute == 1
    }

    let channelMutes = channelElements.compactMap {
      getMuteValue(deviceID: deviceID, element: $0)
    }
    guard !channelMutes.isEmpty else {
      print("Error getting mute status: no mute channels available")
      return false
    }

    return channelMutes.allSatisfy { $0 == 1 }
  }

  static func volumePropertyAddresses(deviceID: AudioObjectID) -> [AudioObjectPropertyAddress] {
    propertyAddresses(
      deviceID: deviceID,
      selector: kAudioDevicePropertyVolumeScalar)
  }

  static func mutePropertyAddresses(deviceID: AudioObjectID) -> [AudioObjectPropertyAddress] {
    propertyAddresses(
      deviceID: deviceID,
      selector: kAudioDevicePropertyMute)
  }

  static func defaultOutputDeviceAddress() -> AudioObjectPropertyAddress {
    AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDefaultOutputDevice,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
  }

  private static func propertyAddresses(
    deviceID: AudioObjectID,
    selector: AudioObjectPropertySelector
  ) -> [AudioObjectPropertyAddress] {
    var addresses: [AudioObjectPropertyAddress] = []
    let elements = [kAudioObjectPropertyElementMain] + channelElements
    for element in elements {
      var address = AudioObjectPropertyAddress(
        mSelector: selector,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: element
      )
      if AudioObjectHasProperty(deviceID, &address) {
        addresses.append(address)
      }
    }
    return addresses
  }

  private static func getScalar(
    deviceID: AudioObjectID,
    selector: AudioObjectPropertySelector,
    element: UInt32
  ) -> Float? {
    var address = AudioObjectPropertyAddress(
      mSelector: selector,
      mScope: kAudioDevicePropertyScopeOutput,
      mElement: element
    )
    guard AudioObjectHasProperty(deviceID, &address) else { return nil }

    var value: Float32 = 0
    var size = UInt32(MemoryLayout.size(ofValue: value))
    let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &value)
    guard status == noErr else { return nil }
    return Float(value)
  }

  private static func setScalar(
    deviceID: AudioObjectID,
    selector: AudioObjectPropertySelector,
    element: UInt32,
    value: Float
  ) -> Bool {
    var address = AudioObjectPropertyAddress(
      mSelector: selector,
      mScope: kAudioDevicePropertyScopeOutput,
      mElement: element
    )
    guard AudioObjectHasProperty(deviceID, &address) else { return false }

    var newValue = Float32(value)
    let size = UInt32(MemoryLayout.size(ofValue: newValue))
    return AudioObjectSetPropertyData(deviceID, &address, 0, nil, size, &newValue) == noErr
  }

  private static func getMuteValue(deviceID: AudioObjectID, element: UInt32) -> UInt32? {
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyMute,
      mScope: kAudioDevicePropertyScopeOutput,
      mElement: element
    )
    guard AudioObjectHasProperty(deviceID, &address) else { return nil }

    var mute: UInt32 = 0
    var size = UInt32(MemoryLayout.size(ofValue: mute))
    let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &mute)
    guard status == noErr else { return nil }
    return mute
  }

  private static func setMuteValue(deviceID: AudioObjectID, element: UInt32, mute: UInt32) -> Bool {
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyMute,
      mScope: kAudioDevicePropertyScopeOutput,
      mElement: element
    )
    guard AudioObjectHasProperty(deviceID, &address) else { return false }

    var value = mute
    let size = UInt32(MemoryLayout.size(ofValue: value))
    return AudioObjectSetPropertyData(deviceID, &address, 0, nil, size, &value) == noErr
  }
}
