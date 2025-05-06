import XCTest
import TextStory
@testable import TextFormation

final class ClosePairFilterTests: XCTestCase {
	@MainActor
    func testMatching() {
        let filter = ClosePairFilter(open: " do |", close: "|")
        let interface = TextInterfaceAdapter()

        let openMutation = TextMutation(insert: " do |", at: 0, limit: 0)

        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)
        XCTAssertEqual(interface.selectedRange, NSRange(5..<5))

        let nextMutation = TextMutation(insert: "a", at: 5, limit: 5)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .stop)

        XCTAssertEqual(interface.string, " do |a|")
        XCTAssertEqual(interface.selectedRange, NSRange(6..<6))
    }

	@MainActor
    func testCloseAfterMatching() {
        let filter = ClosePairFilter(open: " do |", close: "|")
        let interface = TextInterfaceAdapter()

        let openMutation = TextMutation(insert: " do |", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)

        let nextMutation = TextMutation(insert: "|", at: 5, limit: 5)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .stop)

        XCTAssertEqual(interface.string, " do ||")
        XCTAssertEqual(interface.selectedRange, NSRange(6..<6))
    }

	@MainActor
    func testDeleteAfterMatchingOpen() {
        let filter = ClosePairFilter(open: " do |", close: "|")
        let interface = TextInterfaceAdapter()

        let openMutation = TextMutation(insert: " do |", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)

        let nextMutation = TextMutation(delete: NSRange(4..<5), limit: 5)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .none)

        XCTAssertEqual(interface.string, " do ")
        XCTAssertEqual(interface.selectedRange, NSRange(4..<4))
    }

	@MainActor
    func testMatchWithOpenReplacement() {
        let filter = ClosePairFilter(open: "abc", close: "def")
        let interface = TextInterfaceAdapter("yz")

        interface.selectedRange = NSRange(0..<1)

        let openMutation = TextMutation(string: "abc", range: interface.selectedRange, limit: 2)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)
        XCTAssertEqual(interface.selectedRange, NSRange(3..<3))

        let nextMutation = TextMutation(insert: " ", at: 3, limit: 4)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .stop)

        XCTAssertEqual(interface.string, "abc defz")
        XCTAssertEqual(interface.selectedRange, NSRange(4..<4))
    }

	@MainActor
    func testMatchThenReplacement() {
        let filter = ClosePairFilter(open: "abc", close: "def")
        let interface = TextInterfaceAdapter("yz")

        interface.selectedRange = NSRange(0..<1)

        let openMutation = TextMutation(string: "abc", range: interface.selectedRange, limit: 2)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)
        XCTAssertEqual(interface.selectedRange, NSRange(3..<3))

        XCTAssertEqual(interface.string, "abcz")
        XCTAssertEqual(interface.selectedRange, NSRange(3..<3))

        let nextMutation = TextMutation(string: " ", range: NSRange(3..<4), limit: 4)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .none)

        XCTAssertEqual(interface.string, "abc ")
        XCTAssertEqual(interface.selectedRange, NSRange(4..<4))
    }

	@MainActor
    func testMatchingWithDoubleOpen() {
        let filter = ClosePairFilter(open: "(", close: ")")
        let interface = TextInterfaceAdapter()

        let openMutation = TextMutation(insert: "(", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)

        let secondOpenMutation = TextMutation(insert: "(", at: 1, limit: 1)
        XCTAssertEqual(interface.runFilter(filter, on: secondOpenMutation), .stop)

        let nextMutation = TextMutation(insert: "a", at: 2, limit: 2)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .stop)

        let unrelatedMutation = TextMutation(insert: "b", at: 3, limit: 3)
        XCTAssertEqual(interface.runFilter(filter, on: unrelatedMutation), .none)

        XCTAssertEqual(interface.string, "((ab))")
        XCTAssertEqual(interface.selectedRange, NSRange(4..<4))
    }

	@MainActor
    func testMatchingWithTripleOpen() {
        let filter = ClosePairFilter(open: "(", close: ")")
        let interface = TextInterfaceAdapter()

        let openMutation = TextMutation(insert: "(", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)

        let secondOpenMutation = TextMutation(insert: "(", at: 1, limit: 1)
        XCTAssertEqual(interface.runFilter(filter, on: secondOpenMutation), .stop)

        let thirdOpenMutation = TextMutation(insert: "(", at: 2, limit: 2)
        XCTAssertEqual(interface.runFilter(filter, on: thirdOpenMutation), .stop)

        let nextMutation = TextMutation(insert: "a", at: 3, limit: 3)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .stop)

        let unrelatedMutation = TextMutation(insert: "b", at: 4, limit: 4)
        XCTAssertEqual(interface.runFilter(filter, on: unrelatedMutation), .none)

        XCTAssertEqual(interface.string, "(((ab)))")
        XCTAssertEqual(interface.insertionLocation, 5)
    }

	@MainActor
    func testMatchThenNewline() {
        let filter = ClosePairFilter(open: "abc", close: "def")
        let interface = TextInterfaceAdapter()

        let openMutation = TextMutation(insert: "abc", at: 0, limit: 0)

        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)
        XCTAssertEqual(interface.selectedRange, NSRange(3..<3))

        let nextMutation = TextMutation(insert: "\n", at: 3, limit: 3)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .discard)

        XCTAssertEqual(interface.string, "abc\n\ndef")
        XCTAssertEqual(interface.selectedRange, NSRange(4..<4))
    }

	@MainActor
    func testMatchThenNewlineWithWhitespaceProviders() {
        var leadingRequests: [(NSRange, String)] = []

        let leadingProvider = { (range: NSRange, interface: TextInterface) -> String in
            leadingRequests.append((range, interface.string))
            return "lll"
        }

        let providers = WhitespaceProviders(leadingWhitespace: leadingProvider,
                                            trailingWhitespace: {  _, _ in return "ttt"})
        let filter = ClosePairFilter(open: "abc", close: "def")
        let interface = TextInterfaceAdapter()

        let openMutation = TextMutation(insert: "abc", at: 0, limit: 0)

        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)
        XCTAssertEqual(interface.selectedRange, NSRange(3..<3))

        let nextMutation = TextMutation(insert: "\n", at: 3, limit: 3)
		XCTAssertEqual(interface.runFilter(filter, on: nextMutation, with: providers), .discard)

        XCTAssertEqual(leadingRequests.count, 2)
        XCTAssertEqual(leadingRequests[0].0, NSRange(4..<4))
        XCTAssertEqual(leadingRequests[0].1, "abc\n\ndef")

        XCTAssertEqual(leadingRequests[1].0, NSRange(8..<8))
        XCTAssertEqual(leadingRequests[1].1, "abc\nlll\ndef")

        XCTAssertEqual(interface.string, "abc\nlll\nllldef")
        XCTAssertEqual(interface.selectedRange, NSRange(7..<7))
    }
}

extension ClosePairFilterTests {
	@MainActor
    func testMatchingWithSameOpenClose() {
        let filter = ClosePairFilter(open: "'", close: "'")
        let interface = TextInterfaceAdapter()

        let openMutation = TextMutation(insert: "'", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)

        let nextMutation = TextMutation(insert: "a", at: 1, limit: 1)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .stop)

        XCTAssertEqual(interface.string, "'a'")
        XCTAssertEqual(interface.insertionLocation, 2)
    }

	@MainActor
    func testCloseAfterMatchingWithSameOpenClose() {
        let filter = ClosePairFilter(open: "'", close: "'")
        let interface = TextInterfaceAdapter()

        let openMutation = TextMutation(insert: "'", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)

        let closeMutation = TextMutation(insert: "'", at: 1, limit: 1)
        XCTAssertEqual(interface.runFilter(filter, on: closeMutation), .stop)

        XCTAssertEqual(interface.string, "''")
        XCTAssertEqual(interface.insertionLocation, 2)
    }

	@MainActor
    func testAnotherMutationAfterCloseAfterMatchingWithSameOpenClose() {
        let filter = ClosePairFilter(open: "'", close: "'")
        let interface = TextInterfaceAdapter()

        let openMutation = TextMutation(insert: "'", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)

        let closeMutation = TextMutation(insert: "'", at: 1, limit: 1)
        XCTAssertEqual(interface.runFilter(filter, on: closeMutation), .stop)

        let nextMutation = TextMutation(insert: "a", at: 2, limit: 2)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .none)

        XCTAssertEqual(interface.string, "''a")
        XCTAssertEqual(interface.insertionLocation, 3)

        let anotherMutation = TextMutation(insert: "b", at: 3, limit: 3)
        XCTAssertEqual(interface.runFilter(filter, on: anotherMutation), .none)

        XCTAssertEqual(interface.string, "''ab")
        XCTAssertEqual(interface.insertionLocation, 4)
    }

	@MainActor
    func testMatchWithReplacementWithSameOpenClose() {
        let filter = ClosePairFilter(open: "'", close: "'")
        let interface = TextInterfaceAdapter("yz")

        interface.selectedRange = NSRange(0..<1)

        let openMutation = TextMutation(string: "'", range: interface.selectedRange, limit: 2)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)

        XCTAssertEqual(interface.string, "'z")
        XCTAssertEqual(interface.selectedRange, NSRange(1..<1))

        let nextMutation = TextMutation(insert: " ", at: 1, limit: 2)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .stop)

        XCTAssertEqual(interface.string, "' 'z")
        XCTAssertEqual(interface.insertionLocation, 2)
    }

	@MainActor
    func testMatchThenReplacementWithSameOpenClose() {
        let filter = ClosePairFilter(open: "'", close: "'")
        let interface = TextInterfaceAdapter("yz")

        interface.selectedRange = NSRange(0..<1)

        let openMutation = TextMutation(string: "'", range: interface.selectedRange, limit: 2)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)

        XCTAssertEqual(interface.string, "'z")
        XCTAssertEqual(interface.insertionLocation, 1)

        let nextMutation = TextMutation(string: " ", range: NSRange(1..<2), limit: 2)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .none)

        XCTAssertEqual(interface.string, "' ")
        XCTAssertEqual(interface.insertionLocation, 2)
    }
}

import Testing

struct NewClosePairFilterTests {
	@Test func matching() throws {
		let system = MockSystem(string: "")
		var filter = NewClosePairFilter<MockSystem>(open: " do |", close: "|")

		let openOutput = try #require(try filter.processMutation(0..<0, " do |", system))
		#expect(openOutput == MutationOutput(selection: NSRange(5..<5), delta: 5))
		#expect(system.string == " do |")

		let output = try #require(try filter.processMutation(5..<5, "a", system))
		
		#expect(output == MutationOutput(selection: NSRange(6..<6), delta: 2))
		#expect(system.string == " do |a|")
	}
	
	@Test func closeAfterMatching() throws {
		let system = MockSystem(string: "")
		var filter = NewClosePairFilter<MockSystem>(open: " do |", close: "|")

		let openOutput = try #require(try filter.processMutation(0..<0, " do |", system))
		#expect(openOutput == MutationOutput(selection: NSRange(5..<5), delta: 5))
		#expect(system.string == " do |")

		let output = try #require(try filter.processMutation(5..<5, "|", system))
		
		#expect(output == MutationOutput(selection: NSRange(6..<6), delta: 1))
		#expect(system.string == " do ||")
	}
	
	@Test func deleteAfterMatchingOpen() throws {
		let system = MockSystem(string: "")
		var filter = NewClosePairFilter<MockSystem>(open: " do |", close: "|")

		let openOutput = try #require(try filter.processMutation(0..<0, " do |", system))
		#expect(openOutput == MutationOutput(selection: NSRange(5..<5), delta: 5))
		#expect(system.string == " do |")

		let output = try #require(try filter.processMutation(4..<5, "", system))
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: -1))
		#expect(system.string == " do ")
	}
	
	@Test func matchWithOpenReplacement() throws {
		let system = MockSystem(string: "yz")
		var filter = NewClosePairFilter<MockSystem>(open: "abc", close: "def")

		let openOutput = try #require(try filter.processMutation(0..<1, "abc", system))
		#expect(openOutput == MutationOutput(selection: NSRange(3..<3), delta: 2))
		#expect(system.string == "abcz")

		let output = try #require(try filter.processMutation(3..<3, " ", system))
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: 4))
		#expect(system.string == "abc defz")
	}
	
	@Test func matchThenReplacement() throws {
		let system = MockSystem(string: "yz")
		var filter = NewClosePairFilter<MockSystem>(open: "abc", close: "def")

		let openOutput = try #require(try filter.processMutation(0..<1, "abc", system))
		#expect(openOutput == MutationOutput(selection: NSRange(3..<3), delta: 2))
		#expect(system.string == "abcz")

		let output = try #require(try filter.processMutation(3..<4, " ", system))
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: 0))
		#expect(system.string == "abc ")
	}
	
	@Test func matchingWithDoubleOpen() throws {
		let system = MockSystem(string: "")
		var filter = NewClosePairFilter<MockSystem>(open: "(", close: ")")

		let openOutput = try #require(try filter.processMutation(0..<0, "(", system))
		#expect(openOutput == MutationOutput(selection: NSRange(1..<1), delta: 1))
		#expect(system.string == "(")

		let secondOpenOutput = try #require(try filter.processMutation(1..<1, "(", system))
		#expect(secondOpenOutput == MutationOutput(selection: NSRange(2..<2), delta: 2))
		#expect(system.string == "(()")

		let output = try #require(try filter.processMutation(2..<2, "a", system))
		#expect(output == MutationOutput(selection: NSRange(3..<3), delta: 2))
		#expect(system.string == "((a))")

		let unrelatedOutput = try #require(try filter.processMutation(3..<3, "b", system))
		#expect(unrelatedOutput == MutationOutput(selection: NSRange(4..<4), delta: 1))
		#expect(system.string == "((ab))")
//
//		let filter = ClosePairFilter(open: "(", close: ")")
//		let interface = TextInterfaceAdapter()
//
//		let openMutation = TextMutation(insert: "(", at: 0, limit: 0)
//		XCTAssertEqual(interface.runFilter(filter, on: openMutation), .stop)
//
//		let secondOpenMutation = TextMutation(insert: "(", at: 1, limit: 1)
//		XCTAssertEqual(interface.runFilter(filter, on: secondOpenMutation), .stop)
//
//		let nextMutation = TextMutation(insert: "a", at: 2, limit: 2)
//		XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .stop)
//
//		let unrelatedMutation = TextMutation(insert: "b", at: 3, limit: 3)
//		XCTAssertEqual(interface.runFilter(filter, on: unrelatedMutation), .none)
//
//		XCTAssertEqual(interface.string, "((ab))")
//		XCTAssertEqual(interface.selectedRange, NSRange(4..<4))
	}
}
