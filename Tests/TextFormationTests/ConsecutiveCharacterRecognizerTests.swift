import Foundation
import Testing

import TextFormation

struct ConsecutiveCharacterRecognizerTests {
	@Test func matching() throws {
		let system = MockSystem(string: "")
		var recognizer = ConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")
		
		#expect(try recognizer.processMutation(.init(range: NSRange(0..<0), interface: system, string: "a")) == false)
		#expect(try recognizer.processMutation(.init(range: NSRange(1..<1), interface: system, string: "b")) == false)
		#expect(try recognizer.processMutation(.init(range: NSRange(2..<2), interface: system, string: "c")) == true)
	}
	
	@Test func matchingWithMultiCharacterMutations() throws {
		let system = MockSystem(string: "")
		var recognizer = ConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")

		#expect(try recognizer.processMutation(.init(range: NSRange(0..<0), interface: system, string: "a")) == false)
		#expect(try recognizer.processMutation(.init(range: NSRange(1..<1), interface: system, string: "bc")) == true)
	}
	
	@Test func matchingAfterDuplicatePrefix() throws {
		let system = MockSystem(string: "")
		var recognizer = ConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")

		#expect(try recognizer.processMutation(.init(range: NSRange(0..<0), interface: system, string: "a")) == false)
		#expect(try recognizer.processMutation(.init(range: NSRange(1..<1), interface: system, string: "a")) == false)
		#expect(try recognizer.processMutation(.init(range: NSRange(2..<2), interface: system, string: "bc")) == true)
	}

	@Test func matchingWithSingleMultiCharacterMutation() throws {
		let system = MockSystem(string: "")
		var recognizer = ConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")

		#expect(try recognizer.processMutation(.init(range: NSRange(0..<0), interface: system, string: "abc")) == true)
	}
	
	@Test func matchingWithReplacementMutation() throws {
		let system = MockSystem(string: "abc")
		var recognizer = ConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")

		#expect(try recognizer.processMutation(.init(range: NSRange(0..<3), interface: system, string: "abc")) == true)
	}
	
	@Test func matchingMutationWithMoreCharacters() throws {
		let system = MockSystem(string: "abc")
		var recognizer = ConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")

		#expect(try recognizer.processMutation(.init(range: NSRange(0..<0), interface: system, string: "abcd")) == false)
	}
	
	@Test func nonMatchingMutationWithMoreCharacters() throws {
		let system = MockSystem(string: "abc")
		var recognizer = ConsecutiveCharacterRecognizer<MockSystem>(matching: "abc")

		#expect(try recognizer.processMutation(.init(range: NSRange(0..<0), interface: system, string: "def")) == false)
	}
}
