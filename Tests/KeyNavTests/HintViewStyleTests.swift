// Tests/KeyNavTests/HintViewStyleTests.swift
import XCTest
@testable import KeyNav

final class HintViewStyleTests: XCTestCase {

    // MARK: - Hint Colors

    func testHintViewHasDefaultMatchedTextColor() {
        let hintView = HintView(frame: .zero)

        // Matched text should be golden brown: RGB(212, 172, 58)
        let expectedColor = NSColor(calibratedRed: 212/255.0, green: 172/255.0, blue: 58/255.0, alpha: 1.0)

        XCTAssertNotNil(hintView.hintMatchedTextColor)
        // Compare color components (colors may not be directly equal due to color space)
        assertColorsEqual(hintView.hintMatchedTextColor, expectedColor)
    }

    func testHintViewHasDefaultUnmatchedTextColor() {
        let hintView = HintView(frame: .zero)

        // Unmatched text should be black
        XCTAssertEqual(hintView.hintTextColor, NSColor.black)
    }

    func testHintViewHasDefaultBackgroundColor() {
        let hintView = HintView(frame: .zero)

        // Background should be pale yellow: RGB(255, 224, 112)
        let expectedColor = NSColor(calibratedRed: 255/255.0, green: 224/255.0, blue: 112/255.0, alpha: 1.0)

        assertColorsEqual(hintView.hintBackgroundColor, expectedColor)
    }

    func testHintViewHasDefaultBorderWidth() {
        let hintView = HintView(frame: .zero)

        XCTAssertEqual(hintView.hintBorderWidth, 1.0)
    }

    func testHintViewHasDefaultCornerRadius() {
        let hintView = HintView(frame: .zero)

        XCTAssertEqual(hintView.hintCornerRadius, 3.0)
    }

    func testHintViewHasDefaultTextSize() {
        let hintView = HintView(frame: .zero)

        XCTAssertEqual(hintView.hintFont.pointSize, 11.0)
    }

    // MARK: - HintViewModel

    func testHintViewModelWithNoMatchedRange() {
        let viewModel = HintViewModel(label: "AS", frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        XCTAssertNil(viewModel.matchedRange)
        XCTAssertEqual(viewModel.label, "AS")
    }

    func testHintViewModelWithPartialMatchedRange() {
        let label = "AS"
        let matchedRange = label.startIndex..<label.index(label.startIndex, offsetBy: 1)
        let viewModel = HintViewModel(label: label, frame: CGRect(x: 0, y: 0, width: 100, height: 100), matchedRange: matchedRange)

        XCTAssertNotNil(viewModel.matchedRange)
        XCTAssertEqual(String(label[viewModel.matchedRange!]), "A")
    }

    func testHintViewModelWithFullMatchedRange() {
        let label = "AS"
        let matchedRange = label.startIndex..<label.endIndex
        let viewModel = HintViewModel(label: label, frame: CGRect(x: 0, y: 0, width: 100, height: 100), matchedRange: matchedRange)

        XCTAssertNotNil(viewModel.matchedRange)
        XCTAssertEqual(String(label[viewModel.matchedRange!]), "AS")
    }

    // MARK: - Helper

    private func assertColorsEqual(_ color1: NSColor, _ color2: NSColor, tolerance: CGFloat = 0.01, file: StaticString = #file, line: UInt = #line) {
        // Convert to calibrated RGB color space for comparison
        guard let c1 = color1.usingColorSpace(.sRGB),
              let c2 = color2.usingColorSpace(.sRGB) else {
            XCTFail("Could not convert colors to sRGB", file: file, line: line)
            return
        }

        XCTAssertEqual(c1.redComponent, c2.redComponent, accuracy: tolerance, "Red components differ", file: file, line: line)
        XCTAssertEqual(c1.greenComponent, c2.greenComponent, accuracy: tolerance, "Green components differ", file: file, line: line)
        XCTAssertEqual(c1.blueComponent, c2.blueComponent, accuracy: tolerance, "Blue components differ", file: file, line: line)
    }
}
