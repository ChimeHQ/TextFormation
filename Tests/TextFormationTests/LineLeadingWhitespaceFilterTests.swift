import Foundation
import Testing

import TextFormation

struct NewLineLeadingWhitespaceFilterTests {
	@Test func testMatching() throws {
		let system = MockSystem(string: "")
		var filter = NewLineLeadingWhitespaceFilter<MockSystem>(string: "abc")

		system.responses = [
			.whitespaceTextRange(0, .leading, NSRange(0..<0)),
			.applyWhitespace(0, .leading, "\t", NSRange(0..<0)),
		]
		
		let output = try #require(try system.runFilter(&filter, 0..<0, "abc"))
		
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: 4))
		#expect(system.string == "\tabc")
	}
	
	@Test func matchingOneCharacterAtATime() throws {
		let system = MockSystem(string: "")
		var filter = NewLineLeadingWhitespaceFilter<MockSystem>(string: "abc")
		
		system.responses = [
			.whitespaceTextRange(2, .leading, NSRange(0..<0)),
			.applyWhitespace(0, .leading, "\t", NSRange(0..<0)),
		]

		#expect(try system.runFilter(&filter, 0..<0, "a") != nil)
		#expect(try system.runFilter(&filter, 1..<1, "b") != nil)
		let output = try #require(try system.runFilter(&filter, 2..<2, "c"))
		
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: 2))
		#expect(system.string == "\tabc")
	}
	
	@Test func matchingWithWhitespacePrefix() throws {
		let system = MockSystem(string: "def ")
		var filter = NewLineLeadingWhitespaceFilter<MockSystem>(string: "abc")
		filter.mustOccurAtLineLeadingWhitespace = false

		system.responses = [
			.whitespaceTextRange(4, .leading, NSRange(0..<0)),
			.applyWhitespace(0, .leading, "\t", NSRange(0..<0)),
		]

		let output = try #require(try system.runFilter(&filter, 4..<4, "abc"))

		#expect(output == MutationOutput(selection: NSRange(8..<8), delta: 4))
		#expect(system.string == "\tdef abc")
	}
	
	@Test func matchingWithoutWhitespacePrefix() throws {
		let system = MockSystem(string: "def")
		var filter = NewLineLeadingWhitespaceFilter<MockSystem>(string: "abc")
		
		system.responses = [
			.whitespaceTextRange(3, .leading, NSRange(0..<0)),
			.applyWhitespace(0, .leading, "\t", NSRange(0..<0)),
		]

		let output = try #require(try system.runFilter(&filter, 3..<3, "abc"))
		
		#expect(output == MutationOutput(selection: NSRange(6..<6), delta: 3))
		#expect(system.string == "defabc")
	}
	
	@Test func matchingWithDifferentIndentation() throws {
		let system = MockSystem(string: " ")
		var filter = NewLineLeadingWhitespaceFilter<MockSystem>(string: "abc")

		system.responses = [
			.whitespaceTextRange(1, .leading, NSRange(0..<1)),
			.applyWhitespace(0, .leading, "\t", NSRange(0..<1)),
		]
		
		let output = try #require(try system.runFilter(&filter, 1..<1, "abc"))
		
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: 3))
		#expect(system.string == "\tabc")
	}
	
	@Test func matchingWithSameIndentation() throws {
		let system = MockSystem(string: "\t")
		var filter = NewLineLeadingWhitespaceFilter<MockSystem>(string: "abc")

		system.responses = [
			.whitespaceTextRange(1, .leading, NSRange(0..<1)),
			.applyWhitespace(0, .leading, "\t", NSRange(0..<1)),
		]
		
		let output = try #require(try system.runFilter(&filter, 1..<1, "abc"))
		
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: 3))
		#expect(system.string == "\tabc")
	}
	
	@Test func noMatch() throws {
		let system = MockSystem(string: "")
		var filter = NewLineLeadingWhitespaceFilter<MockSystem>(string: "abc")

		let output = try #require(try system.runFilter(&filter, 0..<0, "ab"))
		#expect(output == MutationOutput(selection: NSRange(2..<2), delta: 2))
		#expect(system.string == "ab")
	}
}
