import XCTest
import TextStory
@testable import TextFormation

class ConsecutiveCharacterRecognizerTests: XCTestCase {
    func testMatching() {
        let recognizer = ConsecutiveCharacterRecognizer(matching: "abc")

        XCTAssertEqual(recognizer.state, .idle)
        XCTAssertTrue(recognizer.processMutation(TextMutation(insert: "a", at: 0, limit: 0)))
        XCTAssertEqual(recognizer.state, .tracking(1, 1))
        XCTAssertFalse(recognizer.processMutation(TextMutation(insert: "b", at: 1, limit: 1)))
        XCTAssertEqual(recognizer.state, .tracking(2, 2))
        XCTAssertTrue(recognizer.processMutation(TextMutation(insert: "c", at: 2, limit: 2)))
        XCTAssertEqual(recognizer.state, .triggered(3))
    }

    func testMatchingWithMultiCharacterMutations() {
        let recognizer = ConsecutiveCharacterRecognizer(matching: "abc")

        XCTAssertEqual(recognizer.state, .idle)
        XCTAssertTrue(recognizer.processMutation(TextMutation(insert: "a", at: 0, limit: 0)))
        XCTAssertEqual(recognizer.state, .tracking(1, 1))
        XCTAssertTrue(recognizer.processMutation(TextMutation(insert: "bc", at: 1, limit: 1)))
        XCTAssertEqual(recognizer.state, .triggered(3))
    }

    func testMatchingWithSingleMultiCharacterMutation() {
        let recognizer = ConsecutiveCharacterRecognizer(matching: "abc")

        XCTAssertEqual(recognizer.state, .idle)
        XCTAssertTrue(recognizer.processMutation(TextMutation(insert: "abc", at: 0, limit: 0)))
        XCTAssertEqual(recognizer.state, .triggered(3))
    }

    func testMatchingWithReplacementMutation() {
        let recognizer = ConsecutiveCharacterRecognizer(matching: "abc")

        XCTAssertEqual(recognizer.state, .idle)
        XCTAssertTrue(recognizer.processMutation(TextMutation(string: "abc", range: NSRange(0..<3), limit: 3)))
        XCTAssertEqual(recognizer.state, .triggered(3))
    }

    func testMatchingMutationWithMoreCharacters() {
        let recognizer = ConsecutiveCharacterRecognizer(matching: "abc")

        XCTAssertEqual(recognizer.state, .idle)
        XCTAssertFalse(recognizer.processMutation(TextMutation(string: "abcd", range: NSRange(0..<0), limit: 0)))
        XCTAssertEqual(recognizer.state, .idle)
    }

    func testNonMatchingMutationWithMoreCharacters() {
        let recognizer = ConsecutiveCharacterRecognizer(matching: "abc")

        XCTAssertEqual(recognizer.state, .idle)
        XCTAssertFalse(recognizer.processMutation(TextMutation(string: "def", range: NSRange(0..<0), limit: 0)))
        XCTAssertEqual(recognizer.state, .idle)
    }

    func testDeleteMutation() {
        let recognizer = ConsecutiveCharacterRecognizer(matching: "abc")

        XCTAssertEqual(recognizer.state, .idle)
        XCTAssertFalse(recognizer.processMutation(TextMutation(delete: NSRange(0..<1), limit: 1)))
        XCTAssertEqual(recognizer.state, .idle)
    }
}
