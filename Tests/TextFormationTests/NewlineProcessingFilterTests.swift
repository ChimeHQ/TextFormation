import Foundation
import Testing

import TextFormation

struct NewNewlineProcessingFilterTests {
	@Test func matchingAfterNothing() throws {
		let system = MockSystem(string: "")
		var filter = NewNewlineProcessingFilter<MockSystem>()

		system.responses = [
			.applyWhitespace(1, .leading, "lll", NSRange(1..<1)),
			.applyWhitespace(0, .trailing, "ttt", NSRange(0..<0)),
		]

		let output = try #require(try system.runFilter(&filter, 0..<0, "\n"))
		#expect(output == MutationOutput(selection: NSRange(7..<7), delta: 7))
		#expect(system.string == "ttt\nlll")
	}
	
	@Test func matchingAfterNewline() throws {
		let system = MockSystem(string: "\n")
		var filter = NewNewlineProcessingFilter<MockSystem>()

		system.responses = [
			.applyWhitespace(2, .leading, "lll", NSRange(2..<2)),
			.applyWhitespace(1, .trailing, "ttt", NSRange(1..<1)),
		]

		let output = try #require(try system.runFilter(&filter, 1..<1, "\n"))
		#expect(output == MutationOutput(selection: NSRange(8..<8), delta: 7))
		#expect(system.string == "\nttt\nlll")
	}
	
	@Test func matchingWithTrailingWhitespace() throws {
		let system = MockSystem(string: "a")
		var filter = NewNewlineProcessingFilter<MockSystem>()

		system.responses = [
			.applyWhitespace(2, .leading, "lll", NSRange(2..<2)),
			.applyWhitespace(1, .trailing, "ttt", NSRange(1..<1)),
		]

		let output = try #require(try system.runFilter(&filter, 1..<1, "\n"))
		#expect(output == MutationOutput(selection: NSRange(8..<8), delta: 7))
		#expect(system.string == "attt\nlll")
	}

	@Test func matchingAfterWhitespaceOnlyLine() throws {
		let system = MockSystem(string: "\t")
		var filter = NewNewlineProcessingFilter<MockSystem>()

		system.responses = [
			.applyWhitespace(2, .leading, "lll", NSRange(2..<2)),
			.applyWhitespace(1, .trailing, "ttt", NSRange(0..<1)),
		]

		let output = try #require(try system.runFilter(&filter, 1..<1, "\n"))
		#expect(output == MutationOutput(selection: NSRange(7..<7), delta: 6))
		#expect(system.string == "ttt\nlll")
	}

	@Test func matchingWithCharactersAndTrailingTab() throws {
		let system = MockSystem(string: "abc\t")
		var filter = NewNewlineProcessingFilter<MockSystem>()

		system.responses = [
			.applyWhitespace(5, .leading, "lll", NSRange(5..<5)),
			.applyWhitespace(4, .trailing, "ttt", NSRange(3..<4)),
		]

		let output = try #require(try system.runFilter(&filter,4..<4, "\n"))
		#expect(output == MutationOutput(selection: NSRange(10..<10), delta: 6))
		#expect(system.string == "abcttt\nlll")
	}

	@Test func newlineAfterLeadingOnlyLine() throws {
		let system = MockSystem(string: "\t\n\t")
		var filter = NewNewlineProcessingFilter<MockSystem>()

		system.responses = [
			.applyWhitespace(4, .leading, "lll", NSRange(4..<4)),
			.applyWhitespace(3, .trailing, "ttt", NSRange(2..<3)),
		]

		let output = try #require(try system.runFilter(&filter, 3..<3, "\n"))
		#expect(output == MutationOutput(selection: NSRange(9..<9), delta: 6))
		#expect(system.string == "\t\nttt\nlll")
	}

	@Test func testMatchingWithCustomSequence() throws {
		let system = MockSystem(string: "")
		var filter = NewNewlineProcessingFilter<MockSystem>(lineEndingSequence: "crlf")

		system.responses = [
			.applyWhitespace(4, .leading, "lll", NSRange(4..<4)),
			.applyWhitespace(0, .trailing, "ttt", NSRange(0..<0)),
		]

		let output = try #require(try system.runFilter(&filter, 0..<0, "crlf"))
		#expect(output == MutationOutput(selection: NSRange(10..<10), delta: 10))
		#expect(system.string == "tttcrlflll")
	}
}
