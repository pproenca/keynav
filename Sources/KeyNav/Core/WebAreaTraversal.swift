// Sources/KeyNav/Core/WebAreaTraversal.swift
import Foundation

/// Known browser rendering engines
enum BrowserType: Equatable {
    case webkit  // Safari, Safari Technology Preview
    case chromium  // Chrome, Edge, Brave, Opera, etc.
    case firefox  // Firefox (Gecko)
    case unknown
}

/// Detects browser type from bundle identifier
struct BrowserTypeDetector {
    private static let webkitBundles: Set<String> = [
        "com.apple.Safari",
        "com.apple.SafariTechnologyPreview",
    ]

    private static let chromiumBundles: Set<String> = [
        "com.google.Chrome",
        "com.google.Chrome.canary",
        "com.microsoft.edgemac",
        "com.microsoft.edgemac.Dev",
        "com.brave.Browser",
        "com.operasoftware.Opera",
        "com.vivaldi.Vivaldi",
        "org.chromium.Chromium",
    ]

    private static let firefoxBundles: Set<String> = [
        "org.mozilla.firefox",
        "org.mozilla.firefoxdeveloperedition",
        "org.mozilla.nightly",
    ]

    func detect(bundleIdentifier: String) -> BrowserType {
        if Self.webkitBundles.contains(bundleIdentifier) {
            return .webkit
        }
        if Self.chromiumBundles.contains(bundleIdentifier) {
            return .chromium
        }
        if Self.firefoxBundles.contains(bundleIdentifier) {
            return .firefox
        }
        return .unknown
    }
}

/// Strategy for searching web areas based on browser type
struct WebAreaSearchStrategy {
    /// All available search keys for accessibility search
    let allAvailableSearchKeys: [String] = [
        "AXLinkSearchKey",
        "AXButtonSearchKey",
        "AXTextFieldSearchKey",
        "AXControlSearchKey",
        "AXCheckBoxSearchKey",
        "AXRadioGroupSearchKey",
        "AXGraphicSearchKey",
    ]

    /// Returns appropriate search keys based on browser type
    /// - Parameter browserType: The detected browser type
    /// - Returns: Array of search keys to use
    func searchKeys(for browserType: BrowserType) -> [String] {
        switch browserType {
        case .webkit:
            // WebKit supports multi-key parameterized search
            return allAvailableSearchKeys

        case .chromium:
            // Chromium (~v90 and later) may have limited support
            // Use broader control search as fallback
            return ["AXControlSearchKey", "AXLinkSearchKey"]

        case .firefox:
            // Firefox has its own accessibility implementation
            return ["AXControlSearchKey", "AXLinkSearchKey", "AXButtonSearchKey"]

        case .unknown:
            // For unknown browsers, use minimal set
            return ["AXControlSearchKey"]
        }
    }
}
