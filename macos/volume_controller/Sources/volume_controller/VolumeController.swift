import AVFoundation
import AudioToolbox
import Cocoa
import CoreAudio
import MediaPlayer

public class VolumeController {
  public func getVolume() -> Float? {
    let volume = AudioHelper.getVolume()

    return Float(volume)
  }

  public func setVolume(volume: Float) {
    AudioHelper.setVolume(volume: volume)
  }
}
