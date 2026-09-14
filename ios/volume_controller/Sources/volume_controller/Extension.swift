import AVFoundation
import Foundation

extension Comparable {
  func clamp(to limits: ClosedRange<Self>) -> Self {
    return min(max(self, limits.lowerBound), limits.upperBound)
  }
}

extension AVAudioSession {
  func getVolume() -> Float {
    return outputVolume
  }

  /// Activates the session for outputVolume KVO without taking exclusive audio focus.
  /// Does not deactivate on listener cancel so a host app's session is left intact.
  func prepareForVolumeObservation() {
    do {
      try setCategory(.playback, options: [.mixWithOthers])
      try setActive(true)
    } catch {
      print("Error preparing audio session for volume observation: \(error)")
    }
  }
}
