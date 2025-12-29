// Sources/KeyNav/Core/HintModeAnalytics.swift
import Foundation

/// Tracks analytics for hint mode to improve UX
/// Records deadends (invalid sequences) and other metrics
final class HintModeAnalytics {

    /// Shared instance for app-wide analytics
    static let shared = HintModeAnalytics()

    /// Count of deadend sequences typed by user
    private(set) var deadendCount: Int = 0

    /// Most recent deadend sequences (for debugging/logging)
    private(set) var recentDeadends: [String] = []

    /// Maximum number of recent deadends to keep
    private let maxRecentDeadends = 10

    /// Records a deadend (invalid sequence that doesn't match any hint)
    func recordDeadend(typedSequence: String) {
        deadendCount += 1
        recentDeadends.append(typedSequence)

        // Keep only recent deadends
        if recentDeadends.count > maxRecentDeadends {
            recentDeadends.removeFirst()
        }

        #if DEBUG
        print("[Analytics] Deadend: '\(typedSequence)' (total: \(deadendCount))")
        #endif
    }

    /// Resets all analytics
    func reset() {
        deadendCount = 0
        recentDeadends.removeAll()
    }
}
