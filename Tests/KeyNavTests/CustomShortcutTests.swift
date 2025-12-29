// Tests/KeyNavTests/CustomShortcutTests.swift
import XCTest
@testable import KeyNav

final class CustomShortcutTests: XCTestCase {

    func testCustomShortcutCodable() throws {
        let shortcut = CustomShortcut(
            id: UUID(),
            name: "Reload Safari",
            hotkeyCode: 15,
            hotkeyModifiers: ["command", "option"],
            appBundleId: "com.apple.Safari",
            elementSignature: ElementSignature(
                identifier: "reload-button",
                label: "Reload",
                role: "AXButton",
                path: ["Window", "Toolbar", "Button"]
            ),
            action: .single
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(shortcut)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CustomShortcut.self, from: data)

        XCTAssertEqual(decoded.name, "Reload Safari")
        XCTAssertEqual(decoded.appBundleId, "com.apple.Safari")
        XCTAssertEqual(decoded.action, .single)
    }
}
