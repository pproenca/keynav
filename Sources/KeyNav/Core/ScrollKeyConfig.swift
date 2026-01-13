// Sources/KeyNav/Core/ScrollKeyConfig.swift
import Foundation

/// Configuration for scroll mode key bindings
/// Default uses Vim-style HJKL navigation
struct ScrollKeyConfig: Codable, Equatable {
    let left: String
    let down: String
    let up: String
    let right: String
    let halfPageDown: String
    let halfPageUp: String
    let toTop: String  // 'g' for gg
    let toBottom: String  // 'G' (Shift+G)

    /// Default Vim-style configuration
    init(
        left: String = "h",
        down: String = "j",
        up: String = "k",
        right: String = "l",
        halfPageDown: String = "d",
        halfPageUp: String = "u",
        toTop: String = "g",
        toBottom: String = "G"
    ) {
        self.left = left
        self.down = down
        self.up = up
        self.right = right
        self.halfPageDown = halfPageDown
        self.halfPageUp = halfPageUp
        self.toTop = toTop
        self.toBottom = toBottom
    }

    /// Validates that all keys are unique (case-insensitive except toTop/toBottom pair)
    var isValid: Bool {
        // toTop and toBottom can share the same letter (g and G)
        let directionalKeys = [left, down, up, right, halfPageDown, halfPageUp]
        let lowercaseDirectional = directionalKeys.map { $0.lowercased() }

        // Check directional keys are unique among themselves
        if Set(lowercaseDirectional).count != directionalKeys.count {
            return false
        }

        // Check toTop/toBottom don't conflict with directional keys
        // (they can be g and G, same letter different case)
        let toTopLower = toTop.lowercased()
        let toBottomLower = toBottom.lowercased()

        // toTop and toBottom must be the same base letter OR both unique from directional
        if toTopLower == toBottomLower {
            // Same letter (like g/G) - make sure it doesn't conflict with directional
            return !lowercaseDirectional.contains(toTopLower)
        } else {
            // Different letters - both must be unique from directional and each other
            return !lowercaseDirectional.contains(toTopLower) && !lowercaseDirectional.contains(toBottomLower)
        }
    }

    /// Parses configuration from comma-separated string
    /// Format: "left,down,up,right,halfPageDown,halfPageUp,toTop,toBottom"
    /// Example: "h,j,k,l,d,u,g,G"
    static func fromString(_ string: String) -> ScrollKeyConfig? {
        let parts = string.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }

        // Need at least 8 keys for full config, or 4 for basic navigation
        guard parts.count >= 4 else { return nil }

        if parts.count >= 8 {
            return ScrollKeyConfig(
                left: parts[0],
                down: parts[1],
                up: parts[2],
                right: parts[3],
                halfPageDown: parts[4],
                halfPageUp: parts[5],
                toTop: parts[6],
                toBottom: parts[7]
            )
        } else if parts.count >= 6 {
            return ScrollKeyConfig(
                left: parts[0],
                down: parts[1],
                up: parts[2],
                right: parts[3],
                halfPageDown: parts[4],
                halfPageUp: parts[5]
            )
        } else {
            return ScrollKeyConfig(
                left: parts[0],
                down: parts[1],
                up: parts[2],
                right: parts[3]
            )
        }
    }

    /// Converts configuration to comma-separated string
    func toString() -> String {
        return [left, down, up, right, halfPageDown, halfPageUp, toTop, toBottom].joined(separator: ",")
    }
}
