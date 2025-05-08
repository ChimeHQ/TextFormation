import Foundation
import Testing

import TextFormation

struct NewlineWithinPairFilterTests {
	@Test func match() throws {
		let system = MockSystem(string: "abcdef")
		var filter = NewNewlineWithinPairFilter<MockSystem>(open: "abc", close: "def")

		system.responses = [
			.applyWhitespace(5, .leading, "\t", NSRange(5..<5)),
			.applyWhitespace(4, .leading, "\t", NSRange(4..<4)),
		]

		let output = try #require(try system.runFilter(&filter, 3..<3, "\n"))
		#expect(output == MutationOutput(selection: NSRange(5..<5), delta: 4))
		#expect(system.string == "abc\n\t\n\tdef")
	}

	@Test func noMatch() throws {
		let system = MockSystem(string: "abcdef")
		var filter = NewNewlineWithinPairFilter<MockSystem>(open: "abc", close: "def")

		system.responses = [
			.applyWhitespace(5, .leading, "\t", NSRange(5..<5)),
			.applyWhitespace(4, .leading, "\t", NSRange(4..<4)),
		]

		let output = try #require(try system.runFilter(&filter, 2..<2, "\n"))
		#expect(output == MutationOutput(selection: NSRange(3..<3), delta: 1))
		#expect(system.string == "ab\ncdef")
	}
}
