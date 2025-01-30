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
}
