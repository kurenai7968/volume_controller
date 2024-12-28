import AVFoundation
import MediaPlayer
import UIKit

public class VolumeController {
  private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
  private let volumeView: MPVolumeView = MPVolumeView()

  public func getVolume() -> Float? {
    do {
      try audioSession.setActive(true)
      return audioSession.outputVolume
    } catch _ {
      return nil
    }
  }

  public func setVolume(volume: Float, showSystemUI: Bool) {
    if showSystemUI {
      volumeView.frame = CGRect()
      volumeView.showsRouteButton = true
      volumeView.removeFromSuperview()
    } else {
      volumeView.frame = CGRect(x: -1000, y: -1000, width: 1, height: 1)
      volumeView.showsRouteButton = false
      UIApplication.shared.keyWindow?.insertSubview(volumeView, at: 0)
    }

    let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
    DispatchQueue.main.async {
      slider?.value = Float(volume)
    }
  }
}
