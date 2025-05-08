import Foundation
import Testing

import TextFormation

struct ClosePairFilterTests {
	@Test func matching() throws {
		let system = MockSystem(string: "")
		var filter = NewClosePairFilter<MockSystem>(open: " do |", close: "|")

		let openOutput = try #require(try system.runFilter(&filter, 0..<0, " do |"))
		#expect(openOutput == MutationOutput(selection: NSRange(5..<5), delta: 5))
		#expect(system.string == " do |")

		let output = try #require(try filter.processMutation(5..<5, "a", system))
		
		#expect(output == MutationOutput(selection: NSRange(6..<6), delta: 2))
		#expect(system.string == " do |a|")
	}
	
	@Test func closeAfterMatching() throws {
		let system = MockSystem(string: "")
		var filter = NewClosePairFilter<MockSystem>(open: " do |", close: "|")

		let openOutput = try #require(try system.runFilter(&filter, 0..<0, " do |"))
		#expect(openOutput == MutationOutput(selection: NSRange(5..<5), delta: 5))
		#expect(system.string == " do |")

		let output = try #require(try system.runFilter(&filter, 5..<5, "|"))
		
		#expect(output == MutationOutput(selection: NSRange(6..<6), delta: 1))
		#expect(system.string == " do ||")
	}
	
	@Test func deleteAfterMatchingOpen() throws {
		let system = MockSystem(string: "")
		var filter = NewClosePairFilter<MockSystem>(open: " do |", close: "|")

		let openOutput = try #require(try system.runFilter(&filter, 0..<0, " do |"))
		#expect(openOutput == MutationOutput(selection: NSRange(5..<5), delta: 5))
		#expect(system.string == " do |")

		let output = try #require(try system.runFilter(&filter, 4..<5, ""))
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: -1))
		#expect(system.string == " do ")
	}
	
	@Test func matchWithOpenReplacement() throws {
		let system = MockSystem(string: "yz")
		var filter = NewClosePairFilter<MockSystem>(open: "abc", close: "def")

		let openOutput = try #require(try system.runFilter(&filter, 0..<1, "abc"))
		#expect(openOutput == MutationOutput(selection: NSRange(3..<3), delta: 2))
		#expect(system.string == "abcz")

		let output = try #require(try system.runFilter(&filter, 3..<3, " "))
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: 4))
		#expect(system.string == "abc defz")
	}
	
	@Test func matchThenReplacement() throws {
		let system = MockSystem(string: "yz")
		var filter = NewClosePairFilter<MockSystem>(open: "abc", close: "def")

		let openOutput = try #require(try system.runFilter(&filter, 0..<1, "abc"))
		#expect(openOutput == MutationOutput(selection: NSRange(3..<3), delta: 2))
		#expect(system.string == "abcz")

		let output = try #require(try system.runFilter(&filter, 3..<4, " "))
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: 0))
		#expect(system.string == "abc ")
	}
	
	@Test func matchingWithDoubleOpen() throws {
		let system = MockSystem(string: "")
		var filter = NewClosePairFilter<MockSystem>(open: "(", close: ")")

		let openOutput = try #require(try system.runFilter(&filter, 0..<0, "("))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<1), delta: 1))
		#expect(system.string == "(")

		let secondOpenOutput = try #require(try system.runFilter(&filter, 1..<1, "("))
		#expect(secondOpenOutput == MutationOutput(selection: NSRange(2..<2), delta: 2))
		#expect(system.string == "(()")

		let output = try #require(try system.runFilter(&filter, 2..<2, "a"))
		#expect(output == MutationOutput(selection: NSRange(3..<3), delta: 2))
		#expect(system.string == "((a))")

		let unrelatedOutput = try #require(try system.runFilter(&filter, 3..<3, "b"))
		#expect(unrelatedOutput == MutationOutput(selection: NSRange(4..<4), delta: 1))
		#expect(system.string == "((ab))")
	}
	
	@Test func matchingWithTripleOpen() throws {
		let system = MockSystem(string: "")
		var filter = NewClosePairFilter<MockSystem>(open: "(", close: ")")

		let openOutput = try #require(try system.runFilter(&filter, 0..<0, "("))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<1), delta: 1))
		#expect(system.string == "(")

		let secondOpenOutput = try #require(try system.runFilter(&filter, 1..<1, "("))
		#expect(secondOpenOutput == MutationOutput(selection: NSRange(2..<2), delta: 2))
		#expect(system.string == "(()")

		let thirdOpenOutput = try #require(try system.runFilter(&filter, 2..<2, "("))
		#expect(thirdOpenOutput == MutationOutput(selection: NSRange(3..<3), delta: 2))
		#expect(system.string == "((())")

		let output = try #require(try system.runFilter(&filter, 3..<3, "a"))
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: 2))
		#expect(system.string == "(((a)))")

		let unrelatedOutput = try #require(try system.runFilter(&filter, 4..<4, "b"))
		#expect(unrelatedOutput == MutationOutput(selection: NSRange(5..<5), delta: 1))
		#expect(system.string == "(((ab)))")
	}
	
	@Test func matchThenNewline() throws {
		let system = MockSystem(string: "")
		var filter = NewClosePairFilter<MockSystem>(open: "abc", close: "def")
		system.responses = [
			.applyWhitespace(5, .leading, "\t", NSRange(5..<5)),
			.applyWhitespace(4, .leading, "\t", NSRange(4..<4)),
		]
		
		let openOutput = try #require(try system.runFilter(&filter, 0..<0, "abc"))
		#expect(openOutput == MutationOutput(selection: NSRange(3..<3), delta: 3))
		#expect(system.string == "abc")

		let output = try #require(try system.runFilter(&filter, 3..<3, "\n"))
		#expect(output == MutationOutput(selection: NSRange(5..<5), delta: 7))
		#expect(system.string == "abc\n\t\n\tdef")
	}
	
	@Test func matchingWithSameOpenClose() throws {
		let system = MockSystem(string: "")
		var filter = NewClosePairFilter<MockSystem>(open: "'", close: "'")

		let openOutput = try #require(try system.runFilter(&filter, 0..<0, "'"))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<1), delta: 1))
		#expect(system.string == "'")

		let output = try #require(try system.runFilter(&filter, 1..<1, "a"))
		#expect(output == MutationOutput(selection: NSRange(2..<2), delta: 2))
		#expect(system.string == "'a'")
	}
	
	@Test func closeAfterMatchingWithSameOpenClose() throws {
		let system = MockSystem(string: "")
		var filter = NewClosePairFilter<MockSystem>(open: "'", close: "'")

		let openOutput = try #require(try system.runFilter(&filter, 0..<0, "'"))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<1), delta: 1))
		#expect(system.string == "'")

		let output = try #require(try system.runFilter(&filter, 1..<1, "'"))
		#expect(output == MutationOutput(selection: NSRange(2..<2), delta: 1))
		#expect(system.string == "''")
	}
	
	@Test func anotherMutationAfterCloseAfterMatchingWithSameOpenClose() throws {
		let system = MockSystem(string: "")
		var filter = NewClosePairFilter<MockSystem>(open: "'", close: "'")

		let openOutput = try #require(try system.runFilter(&filter, 0..<0, "'"))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<1), delta: 1))
		#expect(system.string == "'")
		
		let closeOutput = try #require(try system.runFilter(&filter, 1..<1, "'"))
		#expect(closeOutput == MutationOutput(selection: NSRange(2..<2), delta: 1))
		#expect(system.string == "''")

		let output1 = try #require(try system.runFilter(&filter, 2..<2, "a"))
		#expect(output1 == MutationOutput(selection: NSRange(3..<3), delta: 1))
		#expect(system.string == "''a")

		let output2 = try #require(try system.runFilter(&filter, 3..<3, "b"))
		#expect(output2 == MutationOutput(selection: NSRange(4..<4), delta: 1))
		#expect(system.string == "''ab")
	}
	
	@Test func matchWithReplacementWithSameOpenClose() throws {
		let system = MockSystem(string: "yz")
		var filter = NewClosePairFilter<MockSystem>(open: "'", close: "'")

		let openOutput = try #require(try system.runFilter(&filter, 0..<1, "'"))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<1), delta: 0))
		#expect(system.string == "'z")

		let output = try #require(try system.runFilter(&filter, 1..<1, " "))
		#expect(output == MutationOutput(selection: NSRange(2..<2), delta: 2))
		#expect(system.string == "' 'z")
	}

	@Test func matchThenReplacementWithSameOpenClose() throws {
		let system = MockSystem(string: "yz")
		var filter = NewClosePairFilter<MockSystem>(open: "'", close: "'")

		let openOutput = try #require(try system.runFilter(&filter, 0..<1, "'"))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<1), delta: 0))
		#expect(system.string == "'z")

		let output = try #require(try system.runFilter(&filter, 1..<2, " "))
		#expect(output == MutationOutput(selection: NSRange(2..<2), delta: 0))
		#expect(system.string == "' ")
	}
}
