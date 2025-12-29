// Tests/KeyNavTests/TrieTests.swift
import XCTest
@testable import KeyNav

final class TrieTests: XCTestCase {

    var trie: Trie!

    override func setUp() {
        super.setUp()
        trie = Trie()
    }

    override func tearDown() {
        trie = nil
        super.tearDown()
    }

    // MARK: - Contains Tests

    func test_contains_true() {
        trie.insert("abc")
        XCTAssertTrue(trie.contains("abc"))
    }

    func test_contains_false() {
        trie.insert("abc")
        XCTAssertFalse(trie.contains("xyz"))
    }

    func test_contains_false_for_prefix_only() {
        trie.insert("abc")
        XCTAssertFalse(trie.contains("ab"), "Should not contain partial prefix")
    }

    // MARK: - isPrefix Tests

    func test_is_prefix_true() {
        trie.insert("abc")
        XCTAssertTrue(trie.isPrefix("ab"))
    }

    func test_is_prefix_true_when_equal() {
        trie.insert("abc")
        XCTAssertTrue(trie.isPrefix("abc"))
    }

    func test_is_prefix_false() {
        trie.insert("abc")
        XCTAssertFalse(trie.isPrefix("xyz"))
    }

    func test_is_prefix_true_when_empty_string() {
        trie.insert("abc")
        XCTAssertTrue(trie.isPrefix(""), "Empty string is prefix of everything")
    }

    func test_is_prefix_false_when_longer() {
        trie.insert("abc")
        XCTAssertFalse(trie.isPrefix("abcd"), "Longer string is not a prefix")
    }

    // MARK: - doesTerminatingPrefixExist Tests

    func test_does_terminating_prefix_exist_1() {
        // Insert 'a' and 'abc' - 'a' is a terminating prefix of 'abc'
        trie.insert("a")
        trie.insert("abc")
        XCTAssertTrue(trie.doesTerminatingPrefixExist("abc"))
    }

    func test_does_terminating_prefix_exist_2() {
        // Insert only 'abc' - no terminating prefix for 'abc' itself
        trie.insert("abc")
        XCTAssertFalse(trie.doesTerminatingPrefixExist("abc"))
    }

    func test_does_terminating_prefix_exist_3() {
        // Insert 'ab' and 'abc' - 'ab' is a terminating prefix of 'abc'
        trie.insert("ab")
        trie.insert("abc")
        XCTAssertTrue(trie.doesTerminatingPrefixExist("abc"))
    }

    // MARK: - Multiple Insert Tests

    func test_multiple_inserts() {
        trie.insert("aa")
        trie.insert("ab")
        trie.insert("abc")

        XCTAssertTrue(trie.contains("aa"))
        XCTAssertTrue(trie.contains("ab"))
        XCTAssertTrue(trie.contains("abc"))
        XCTAssertFalse(trie.contains("a"))
        XCTAssertFalse(trie.contains("abcd"))
    }

    func test_get_all_words() {
        trie.insert("aa")
        trie.insert("ab")
        trie.insert("abc")

        let words = trie.getAllWords()
        XCTAssertEqual(Set(words), Set(["aa", "ab", "abc"]))
    }

    // MARK: - Get Words With Prefix Tests

    func test_get_words_with_prefix() {
        trie.insert("aa")
        trie.insert("ab")
        trie.insert("abc")
        trie.insert("xyz")

        let wordsWithA = trie.getWordsWithPrefix("a")
        XCTAssertEqual(Set(wordsWithA), Set(["aa", "ab", "abc"]))

        let wordsWithAB = trie.getWordsWithPrefix("ab")
        XCTAssertEqual(Set(wordsWithAB), Set(["ab", "abc"]))
    }
}
