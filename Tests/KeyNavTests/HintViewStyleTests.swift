// Tests/KeyNavTests/HintViewStyleTests.swift
import XCTest
@testable import KeyNav

final class HintViewStyleTests: XCTestCase {

    // MARK: - Hint Colors

    func testHintViewHasDefaultMatchedTextColor() {
        let hintView = HintView(frame: .zero)

        // Matched text should use AppearanceColors.hintMatchedText (appearance-aware)
        XCTAssertNotNil(hintView.hintMatchedTextColor)
        XCTAssertEqual(hintView.hintMatchedTextColor, AppearanceColors.hintMatchedText)
    }

    func testHintViewHasDefaultUnmatchedTextColor() {
        let hintView = HintView(frame: .zero)

        // Unmatched text should use AppearanceColors.hintText (appearance-aware)
        XCTAssertEqual(hintView.hintTextColor, AppearanceColors.hintText)
    }

    func testHintViewHasDefaultBackgroundColor() {
        let hintView = HintView(frame: .zero)

        // Background should use AppearanceColors.hintBackground (appearance-aware)
        XCTAssertEqual(hintView.hintBackgroundColor, AppearanceColors.hintBackground)
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

}
