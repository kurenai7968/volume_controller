import AVFoundation
import Foundation

extension Comparable {
  func clamp(to limits: ClosedRange<Self>) -> Self {
    return min(max(self, limits.lowerBound), limits.upperBound)
  }
}
