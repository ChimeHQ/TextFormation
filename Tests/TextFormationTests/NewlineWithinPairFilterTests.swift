import Foundation
import Testing

import TextFormation

struct NewNewlineWithinPairFilterTests {
	@Test func match() throws {
		let system = MockSystem(string: "abcdef")
		var filter = NewNewlineWithinPairFilter<MockSystem>(open: "abc", close: "def")

		system.responses = [
			.applyLeadingWhitespace("\t", NSRange(5..<5)),
			.applyLeadingWhitespace("\t", NSRange(4..<4)),
		]

		let output = try #require(try system.runFilter(&filter, 3..<3, "\n"))
		#expect(output == MutationOutput(selection: NSRange(5..<5), delta: 4))
		#expect(system.string == "abc\n\t\n\tdef")
	}

	@Test func noMatch() throws {
		let system = MockSystem(string: "abcdef")
		var filter = NewNewlineWithinPairFilter<MockSystem>(open: "abc", close: "def")

		system.responses = [
			.applyLeadingWhitespace("\t", NSRange(5..<5)),
			.applyLeadingWhitespace("\t", NSRange(4..<4)),
		]

		let output = try #require(try system.runFilter(&filter, 2..<2, "\n"))
		#expect(output == MutationOutput(selection: NSRange(3..<3), delta: 1))
		#expect(system.string == "ab\ncdef")
	}
}
