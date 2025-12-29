// Sources/KeyNav/Shortcuts/CustomShortcut.swift
import Foundation

enum ClickAction: String, Codable {
    case single
    case double
    case right
}

struct ElementSignature: Codable, Equatable {
    let identifier: String?
    let label: String
    let role: String
    let path: [String]
}

struct CustomShortcut: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var hotkeyCode: UInt16
    var hotkeyModifiers: [String]
    var appBundleId: String
    var elementSignature: ElementSignature
    var action: ClickAction

    static func == (lhs: CustomShortcut, rhs: CustomShortcut) -> Bool {
        lhs.id == rhs.id
    }
}
