import Foundation
import Testing

import TextFormation

struct NewStandardOpenPairFilterTests {
	@Test func matchOpen() throws {
		let system = MockSystem(string: "")
		var filter = NewStandardOpenPairFilter<MockSystem>(open: "{", close: "}")

		let openOutput = try #require(try system.runFilter(&filter, 0..<0, "{"))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<1), delta: 1))
		#expect(system.string == "{")

		let output = try #require(try system.runFilter(&filter, 1..<1, "a"))
		#expect(output == MutationOutput(selection: NSRange(2..<2), delta: 2))
		#expect(system.string == "{a}")
	}

	@Test func matchOpenWithSame() throws {
		let system = MockSystem(string: "")
		var filter = NewStandardOpenPairFilter<MockSystem>(same: "-")

		let openOutput = try #require(try system.runFilter(&filter, 0..<0, "-"))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<1), delta: 1))
		#expect(system.string == "-")

		let output = try #require(try system.runFilter(&filter, 1..<1, "a"))
		#expect(output == MutationOutput(selection: NSRange(2..<2), delta: 2))
		#expect(system.string == "-a-")
	}

	@Test func closeWithoutLeadingWhitespace() throws {
		let system = MockSystem(string: "a")
		var filter = NewStandardOpenPairFilter<MockSystem>(open: "{", close: "}")

		let openOutput = try #require(try system.runFilter(&filter, 1..<1, "}"))
		#expect(openOutput == MutationOutput(selection: NSRange(2..<2), delta: 1))
		#expect(system.string == "a}")
	}

	@Test func testSkipCloseAfterMatchingOpen() throws {
		let system = MockSystem(string: "")
		var filter = NewStandardOpenPairFilter<MockSystem>(open: "{", close: "}")

		let openOutput = try #require(try system.runFilter(&filter, 0..<0, "{"))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<1), delta: 1))
		#expect(system.string == "{")

		let output = try #require(try system.runFilter(&filter, 1..<1, "a"))
		#expect(output == MutationOutput(selection: NSRange(2..<2), delta: 2))
		#expect(system.string == "{a}")

		let closeOutput = try #require(try system.runFilter(&filter, 2..<2, "}"))
		#expect(closeOutput == MutationOutput(selection: NSRange(3..<3), delta: 0))
		#expect(system.string == "{a}")
	}
	
	@Test func applyWhitespaceOnClose() throws {
		let system = MockSystem(string: "")
		var filter = NewStandardOpenPairFilter<MockSystem>(open: "{", close: "}")

		system.responses = [
			.whitespaceTextRange(0, .leading, NSRange(0..<0)),
			.applyWhitespace(0, .leading, "\t", NSRange(0..<0)),
		]

		let output = try #require(try system.runFilter(&filter, 0..<0, "}"))
		#expect(output == MutationOutput(selection: NSRange(2..<2), delta: 2))
		#expect(system.string == "\t}")
	}
	
	@Test func surroundRange() throws {
		let system = MockSystem(string: "abc")
		var filter = NewStandardOpenPairFilter<MockSystem>(open: "{", close: "}")

		let openOutput = try #require(try system.runFilter(&filter, 0..<3, "{"))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<4), delta: 2))
		#expect(system.string == "{abc}")

		// now, make sure we don't do anything with that open
		let nextOutput = try #require(try system.runFilter(&filter, 1..<1, "z"))
		#expect(nextOutput == MutationOutput(selection: NSRange(2..<2), delta: 1))
		#expect(system.string == "{zabc}")
	}

	@Test func skipClose() throws {
		let system = MockSystem(string: "}")
		var filter = NewStandardOpenPairFilter<MockSystem>(open: "{", close: "}")

		let openOutput = try #require(try system.runFilter(&filter, 0..<0, "}"))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<1), delta: 0))
		#expect(system.string == "}")
	}

	@Test func doubleOpen() throws {
		let system = MockSystem(string: "")
		var filter = NewStandardOpenPairFilter<MockSystem>(open: "{", close: "}")

		let openOutput = try #require(try system.runFilter(&filter, 0..<0, "{"))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<1), delta: 1))
		#expect(system.string == "{")

		let secondOpenOutput = try #require(try system.runFilter(&filter, 1..<1, "{"))
		#expect(secondOpenOutput == MutationOutput(selection: NSRange(2..<2), delta: 2))
		#expect(system.string == "{{}")

		let output = try #require(try system.runFilter(&filter, 2..<2, "a"))
		#expect(output == MutationOutput(selection: NSRange(3..<3), delta: 2))
		#expect(system.string == "{{a}}")
	}

	@Test func doubleOpenDelete() throws {
		let system = MockSystem(string: "{{}}")
		var filter = NewStandardOpenPairFilter<MockSystem>(open: "{", close: "}")

		let deleteOutput = try #require(try system.runFilter(&filter, 1..<2, ""))
		#expect(deleteOutput == MutationOutput(selection: NSRange(1..<1), delta: -2))
		#expect(system.string == "{}")

		let secondDeleteOutput = try #require(try system.runFilter(&filter, 0..<1, ""))
		#expect(secondDeleteOutput == MutationOutput(selection: NSRange(0..<0), delta: -2))
		#expect(system.string == "")
	}
}
