import Foundation
import Testing

import TextFormation

struct OpenPairReplacementFilterTests {
	@Test func match() throws {
		let system = MockSystem(string: " ")
		var filter = NewOpenPairReplacementFilter<MockSystem>(open: "abc", close: "def")

		let output = try #require(try system.runFilter(&filter, 0..<1, "abc"))
		#expect(output == MutationOutput(selection: NSRange(3..<4), delta: 6))
		#expect(system.string == "abc def")
	}

	@Test func insertMatch() throws {
		let system = MockSystem(string: " ")
		var filter = NewOpenPairReplacementFilter<MockSystem>(open: "abc", close: "def")

		let output = try #require(try system.runFilter(&filter, 0..<0, "abc"))
		#expect(output == MutationOutput(selection: NSRange(3..<3), delta: 3))
		#expect(system.string == "abc ")
	}
}
