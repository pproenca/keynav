// Tests/KeyNavTests/InputStateTests.swift
import XCTest
@testable import KeyNav

final class InputStateTests: XCTestCase {

    var inputState: InputState!

    override func setUp() {
        super.setUp()
        inputState = InputState()
    }

    override func tearDown() {
        inputState = nil
        super.tearDown()
    }

    // MARK: - Add Key Sequence Tests

    func test_add_key_sequence_returns_false_on_duplicate() {
        XCTAssertTrue(inputState.addKeySequence("abc"))
        XCTAssertFalse(inputState.addKeySequence("abc"), "Duplicate sequence should return false")
    }

    func test_add_key_sequence_returns_false_if_it_is_prefix_of_registered_seq() {
        XCTAssertTrue(inputState.addKeySequence("abc"))
        XCTAssertFalse(inputState.addKeySequence("ab"), "Prefix of existing should return false")
    }

    func test_add_key_sequence_returns_false_if_prefix_is_already_registered() {
        XCTAssertTrue(inputState.addKeySequence("ab"))
        XCTAssertFalse(inputState.addKeySequence("abc"), "Extension of existing should return false")
    }

    func test_add_key_sequence_returns_true_if_common_prefix_but_unambiguous_end() {
        XCTAssertTrue(inputState.addKeySequence("ab"))
        XCTAssertTrue(inputState.addKeySequence("ac"), "Different ending after common prefix should work")
    }

    // MARK: - State Transition Tests

    func test_initialized_to_words_added_transition() {
        XCTAssertEqual(inputState.state, .initialized)
        inputState.addKeySequence("abc")
        XCTAssertEqual(inputState.state, .wordsAdded)
    }

    func test_advancing_on_initialized_state() {
        // Advancing without adding words should go to deadend
        inputState.advance(with: "a")
        XCTAssertEqual(inputState.state, .deadend)
    }

    func test_deadend_transition() {
        inputState.addKeySequence("abc")
        inputState.advance(with: "x") // 'x' is not a valid start
        XCTAssertEqual(inputState.state, .deadend)
    }

    func test_words_added_to_advancable_transition() {
        inputState.addKeySequence("abc")
        inputState.advance(with: "a")
        XCTAssertEqual(inputState.state, .advancable)
    }

    func test_match_transition() {
        inputState.addKeySequence("abc")
        inputState.advance(with: "a")
        inputState.advance(with: "b")
        inputState.advance(with: "c")
        XCTAssertEqual(inputState.state, .match)
    }

    func test_matched_word() {
        inputState.addKeySequence("abc")
        inputState.addKeySequence("abd")

        inputState.advance(with: "a")
        inputState.advance(with: "b")
        inputState.advance(with: "c")

        XCTAssertEqual(inputState.matchedWord, "abc")
    }

    func test_matched_word_alternative() {
        inputState.addKeySequence("abc")
        inputState.addKeySequence("abd")

        inputState.advance(with: "a")
        inputState.advance(with: "b")
        inputState.advance(with: "d")

        XCTAssertEqual(inputState.matchedWord, "abd")
    }

    // MARK: - Reset Tests

    func test_reset_clears_state() {
        inputState.addKeySequence("abc")
        inputState.advance(with: "a")
        inputState.advance(with: "b")

        inputState.reset()

        XCTAssertEqual(inputState.state, .wordsAdded)
        XCTAssertNil(inputState.matchedWord)
        XCTAssertEqual(inputState.currentInput, "")
    }

    func test_reset_preserves_registered_sequences() {
        inputState.addKeySequence("abc")
        inputState.advance(with: "a")
        inputState.reset()

        // Should still be able to match after reset
        inputState.advance(with: "a")
        inputState.advance(with: "b")
        inputState.advance(with: "c")

        XCTAssertEqual(inputState.state, .match)
        XCTAssertEqual(inputState.matchedWord, "abc")
    }
}
