// Sources/KeyNav/Core/CJKVKeyboardDetector.swift
import Foundation

/// Detects CJKV (Chinese, Japanese, Korean, Vietnamese) keyboard layouts
struct CJKVKeyboardDetector {
    /// Language code prefixes for CJKV languages
    let cjkvPrefixes: [String] = ["ko", "ja", "vi", "zh"]

    /// Check if a language code represents a CJKV layout
    /// - Parameter languageCode: The language code to check (e.g., "ko", "ja-JP", "zh-Hans")
    /// - Returns: True if the language is CJKV
    func isCJKV(languageCode: String) -> Bool {
        let lowercased = languageCode.lowercased()

        for prefix in cjkvPrefixes {
            if lowercased == prefix || lowercased.hasPrefix(prefix + "-") {
                return true
            }
        }

        return false
    }
}
