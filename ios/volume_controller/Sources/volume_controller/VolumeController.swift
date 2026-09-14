import AVFoundation
import Flutter
import MediaPlayer
import UIKit

public class VolumeController {
  private let audioSession: AVAudioSession
  private let volumeView: MPVolumeView = MPVolumeView()
  private var tempMuteVolume: Float?
  private let maxSliderAttempts = 8
  private let sliderRetryDelay: TimeInterval = 0.02

  private var keyWindow: UIWindow? {
    if #available(iOS 13.0, *) {
      return UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first(where: { $0.isKeyWindow })
    } else {
      return UIApplication.shared.keyWindow
    }
  }

  init(audioSession: AVAudioSession) {
    self.audioSession = audioSession
  }

  public func getVolume() -> Float {
    return audioSession.getVolume()
  }

  public func setVolume(
    volume: Float,
    showSystemUI: Bool,
    completion: @escaping (FlutterError?) -> Void
  ) {
    let clampedVolume = volume.clamp(to: 0.0...1.0)
    if clampedVolume != 0.0 {
      tempMuteVolume = nil
    }

    applyVolume(clampedVolume, showSystemUI: showSystemUI, attempt: 0, completion: completion)
  }

  public func isMuted() -> Bool {
    return getVolume() == 0
  }

  public func setMute(
    isMute: Bool,
    showSystemUI: Bool,
    completion: @escaping (FlutterError?) -> Void
  ) {
    if isMute {
      tempMuteVolume = getVolume()
      setVolume(volume: 0, showSystemUI: showSystemUI, completion: completion)
      return
    }

    guard let previousVolume = tempMuteVolume else {
      completion(nil)
      return
    }

    setVolume(volume: previousVolume, showSystemUI: showSystemUI) { [weak self] error in
      if error == nil {
        self?.tempMuteVolume = nil
      }
      completion(error)
    }
  }

  private func applyVolume(
    _ volume: Float,
    showSystemUI: Bool,
    attempt: Int,
    completion: @escaping (FlutterError?) -> Void
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        completion(
          FlutterError(
            code: "SetVolumeError",
            message: "Volume controller was released.",
            details: nil))
        return
      }

      self.configureVolumeView(showSystemUI: showSystemUI)

      guard let slider = self.volumeSlider() else {
        if attempt + 1 < self.maxSliderAttempts {
          DispatchQueue.main.asyncAfter(deadline: .now() + self.sliderRetryDelay) {
            self.applyVolume(
              volume,
              showSystemUI: showSystemUI,
              attempt: attempt + 1,
              completion: completion)
          }
          return
        }

        completion(
          FlutterError(
            code: "SetVolumeError",
            message: "Volume slider is unavailable.",
            details: nil))
        return
      }

      slider.setValue(volume, animated: false)
      slider.sendActions(for: .valueChanged)
      completion(nil)
    }
  }

  private func configureVolumeView(showSystemUI: Bool) {
    if showSystemUI {
      volumeView.showsRouteButton = true
      volumeView.removeFromSuperview()
      return
    }

    volumeView.frame = CGRect(x: -1000, y: -1000, width: 1, height: 1)
    volumeView.showsRouteButton = false
    if volumeView.superview == nil {
      keyWindow?.insertSubview(volumeView, at: 0)
    }
  }

  private func volumeSlider() -> UISlider? {
    return volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
  }
}
