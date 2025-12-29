// Tests/KeyNavTests/WebAreaTraversalTests.swift
import XCTest
@testable import KeyNav

final class WebAreaTraversalTests: XCTestCase {

    // MARK: - Browser Type Detection

    func testWebKitBrowserDetection() {
        let detector = BrowserTypeDetector()

        XCTAssertEqual(detector.detect(bundleIdentifier: "com.apple.Safari"), .webkit)
        XCTAssertEqual(detector.detect(bundleIdentifier: "com.apple.SafariTechnologyPreview"), .webkit)
    }

    func testChromiumBrowserDetection() {
        let detector = BrowserTypeDetector()

        XCTAssertEqual(detector.detect(bundleIdentifier: "com.google.Chrome"), .chromium)
        XCTAssertEqual(detector.detect(bundleIdentifier: "com.microsoft.edgemac"), .chromium)
        XCTAssertEqual(detector.detect(bundleIdentifier: "com.brave.Browser"), .chromium)
        XCTAssertEqual(detector.detect(bundleIdentifier: "com.operasoftware.Opera"), .chromium)
    }

    func testFirefoxBrowserDetection() {
        let detector = BrowserTypeDetector()

        XCTAssertEqual(detector.detect(bundleIdentifier: "org.mozilla.firefox"), .firefox)
    }

    func testUnknownAppDetection() {
        let detector = BrowserTypeDetector()

        XCTAssertEqual(detector.detect(bundleIdentifier: "com.example.unknownapp"), .unknown)
    }

    // MARK: - Search Strategy Selection

    func testWebKitUsesMultiKeySearch() {
        let strategy = WebAreaSearchStrategy()

        let searchKeys = strategy.searchKeys(for: .webkit)

        // WebKit supports multiple search keys
        XCTAssertGreaterThan(searchKeys.count, 1)
        XCTAssertTrue(searchKeys.contains("AXLinkSearchKey"))
        XCTAssertTrue(searchKeys.contains("AXButtonSearchKey"))
    }

    func testChromiumUsesSingleKeyFallback() {
        let strategy = WebAreaSearchStrategy()

        let searchKeys = strategy.searchKeys(for: .chromium)

        // Chromium (~v90) may not support multi-key search
        // Use broader search or fallback
        XCTAssertFalse(searchKeys.isEmpty)
    }

    func testFirefoxSearchStrategy() {
        let strategy = WebAreaSearchStrategy()

        let searchKeys = strategy.searchKeys(for: .firefox)

        XCTAssertFalse(searchKeys.isEmpty)
    }

    // MARK: - Available Search Keys

    func testAllAvailableSearchKeys() {
        let strategy = WebAreaSearchStrategy()

        let allKeys = strategy.allAvailableSearchKeys

        // Should include keys for common interactive elements
        XCTAssertTrue(allKeys.contains("AXLinkSearchKey"))
        XCTAssertTrue(allKeys.contains("AXButtonSearchKey"))
        XCTAssertTrue(allKeys.contains("AXTextFieldSearchKey"))
        XCTAssertTrue(allKeys.contains("AXControlSearchKey"))
    }

    func testSearchKeyCount() {
        let strategy = WebAreaSearchStrategy()

        let allKeys = strategy.allAvailableSearchKeys

        // At least 4 main search keys
        XCTAssertGreaterThanOrEqual(allKeys.count, 4)
    }
}
