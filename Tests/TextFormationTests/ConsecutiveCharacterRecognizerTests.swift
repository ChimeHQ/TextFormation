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

    func testMatchingAfterDuplicatePrefix() {
        let recognizer = ConsecutiveCharacterRecognizer(matching: "abc")

        XCTAssertEqual(recognizer.state, .idle)
        XCTAssertTrue(recognizer.processMutation(TextMutation(insert: "a", at: 0, limit: 0)))
        XCTAssertEqual(recognizer.state, .tracking(1, 1))
        XCTAssertFalse(recognizer.processMutation(TextMutation(insert: "a", at: 1, limit: 1)))
        XCTAssertEqual(recognizer.state, .tracking(2, 1))
        XCTAssertTrue(recognizer.processMutation(TextMutation(insert: "bc", at: 2, limit: 2)))
        XCTAssertEqual(recognizer.state, .triggered(4))
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
}

import Testing

struct NewConsecutiveCharacterRecognizerTests {
	@Test func matching() throws {
		let system = MockSystem(string: "")
		var recognizer = NewConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")
		
		#expect(try recognizer.processMutation(.init(range: NSRange(0..<0), interface: system, string: "a")) == false)
		#expect(try recognizer.processMutation(.init(range: NSRange(1..<1), interface: system, string: "b")) == false)
		#expect(try recognizer.processMutation(.init(range: NSRange(2..<2), interface: system, string: "c")) == true)
	}
	
	@Test func matchingWithMultiCharacterMutations() throws {
		let system = MockSystem(string: "")
		var recognizer = NewConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")

		#expect(try recognizer.processMutation(.init(range: NSRange(0..<0), interface: system, string: "a")) == false)
		#expect(try recognizer.processMutation(.init(range: NSRange(1..<1), interface: system, string: "bc")) == true)
	}
	
	@Test func matchingAfterDuplicatePrefix() throws {
		let system = MockSystem(string: "")
		var recognizer = NewConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")

		#expect(try recognizer.processMutation(.init(range: NSRange(0..<0), interface: system, string: "a")) == false)
		#expect(try recognizer.processMutation(.init(range: NSRange(1..<1), interface: system, string: "a")) == false)
		#expect(try recognizer.processMutation(.init(range: NSRange(2..<2), interface: system, string: "bc")) == true)
	}

	@Test func matchingWithSingleMultiCharacterMutation() throws {
		let system = MockSystem(string: "")
		var recognizer = NewConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")

		#expect(try recognizer.processMutation(.init(range: NSRange(0..<0), interface: system, string: "abc")) == true)
	}
	
	@Test func matchingWithReplacementMutation() throws {
		let system = MockSystem(string: "abc")
		var recognizer = NewConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")

		#expect(try recognizer.processMutation(.init(range: NSRange(0..<3), interface: system, string: "abc")) == true)
	}
	
	@Test func matchingMutationWithMoreCharacters() throws {
		let system = MockSystem(string: "abc")
		var recognizer = NewConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")

		#expect(try recognizer.processMutation(.init(range: NSRange(0..<0), interface: system, string: "abcd")) == false)
	}
	
	@Test func nonMatchingMutationWithMoreCharacters() throws {
		let system = MockSystem(string: "abc")
		var recognizer = NewConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")

		#expect(try recognizer.processMutation(.init(range: NSRange(0..<0), interface: system, string: "def")) == false)
	}
}
