import AVFoundation
import Foundation

extension Comparable {
  func clamp(to limits: ClosedRange<Self>) -> Self {
    return min(max(self, limits.lowerBound), limits.upperBound)
  }
}

extension AVAudioSession {
  func getVolume() -> Float {
    do {
      try setActive(true)
      return outputVolume
    } catch {
      print("Error activating audio session: \(error)")
      return 0
    }
  }

  func activateAudioSession() {
    do {
      try setActive(true)
    } catch {
      print("Error activating audio session: \(error)")
    }
  }

  func deactivateAudioSession() {
    do {
      try setActive(false)
    } catch {
      print("Error deactivating audio session: \(error)")
    }
  }

  func setAudioSessionCategory() {
    do {
      try setCategory(.playback, options: .mixWithOthers)
    } catch {
      print("Error setting audio session category: \(error)")
    }
  }
}
