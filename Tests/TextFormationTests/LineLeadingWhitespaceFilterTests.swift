import XCTest
import TextStory
@testable import TextFormation

final class LineLeadingWhitespaceFilterTests: XCTestCase {
	@MainActor
	private static let providers = WhitespaceProviders(leadingWhitespace: { _, _ in "\t" }, trailingWhitespace: WhitespaceProviders.passthroughProvider)

	@MainActor
    func testMatching() {
        let interface = TextInterfaceAdapter()
        let filter = LineLeadingWhitespaceFilter(string: "abc")

        let mutation = TextMutation(insert: "abc", at: 0, limit: 0)

		XCTAssertEqual(interface.runFilter(filter, on: mutation, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "\tabc")
    }

	@MainActor
    func testMatchingOneCharacterAtATime() {
        let interface = TextInterfaceAdapter("  ")
        let filter = LineLeadingWhitespaceFilter(string: "abc")

		XCTAssertEqual(interface.runFilter(filter, on: TextMutation(insert: "a", at: 2, limit: 2), with: Self.providers), .none)
        XCTAssertEqual(interface.runFilter(filter, on: TextMutation(insert: "b", at: 3, limit: 3), with: Self.providers), .none)
        XCTAssertEqual(interface.runFilter(filter, on: TextMutation(insert: "c", at: 4, limit: 4), with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "\tabc")
    }

	@MainActor
    func testMatchingWithWhitespacePrefix() {
        let interface = TextInterfaceAdapter("def ")
        let filter = LineLeadingWhitespaceFilter(string: "abc")
        filter.mustOccurAtLineLeadingWhitespace = false

        let mutation = TextMutation(insert: "abc", at: 4, limit: 4)

        XCTAssertEqual(interface.runFilter(filter, on: mutation, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "\tdef abc")
    }

	@MainActor
    func testMatchingWithoutWhitespacePrefix() {
        let interface = TextInterfaceAdapter("def")
        let filter = LineLeadingWhitespaceFilter(string: "abc")

        let mutation = TextMutation(insert: "abc", at: 3, limit: 3)

        XCTAssertEqual(interface.runFilter(filter, on: mutation, with: Self.providers), .none)

        XCTAssertEqual(interface.string, "defabc")
    }

	@MainActor
    func testMatchingWithDifferentIndentation() {
        let interface = TextInterfaceAdapter(" ")
        let filter = LineLeadingWhitespaceFilter(string: "abc")

        let mutation = TextMutation(insert: "abc", at: 1, limit: 1)

        XCTAssertEqual(interface.runFilter(filter, on: mutation, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "\tabc")
    }

	@MainActor
    func testMatchingWithSame() {
        let interface = TextInterfaceAdapter("\t")
        let filter = LineLeadingWhitespaceFilter(string: "\n")

        let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

        XCTAssertEqual(interface.runFilter(filter, on: mutation, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "\t\n")
    }
}

import Testing

struct NewLineLeadingWhitespaceFilterTests {
	@Test func testMatching() throws {
		let system = MockSystem(string: "")
		var filter = NewLineLeadingWhitespaceFilter<MockSystem>(string: "abc")

		system.responses = [
			.componentTextRange(.leadingWhitespace, 0, NSRange(0..<0)),
			.applyLeadingWhitespace("\t", NSRange(0..<0)),
		]
		
		let output = try #require(try filter.processMutation(NSRange(0..<0), string: "abc", in: system))
		
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: 4))
		#expect(system.string == "\tabc")
	}
	
	@Test func matchingOneCharacterAtATime() throws {
		let system = MockSystem(string: "")
		var filter = NewLineLeadingWhitespaceFilter<MockSystem>(string: "abc")
		
		system.responses = [
			.componentTextRange(.leadingWhitespace, 2, NSRange(0..<0)),
			.applyLeadingWhitespace("\t", NSRange(0..<0)),
		]

		#expect(try filter.processMutation(NSRange(0..<0), string: "a", in: system) != nil)
		#expect(try filter.processMutation(NSRange(1..<1), string: "b", in: system) != nil)
		let output = try #require(try filter.processMutation(NSRange(2..<2), string: "c", in: system))
		
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: 2))
		#expect(system.string == "\tabc")
	}
	
	@Test func matchingWithWhitespacePrefix() throws {
		let system = MockSystem(string: "def ")
		var filter = NewLineLeadingWhitespaceFilter<MockSystem>(string: "abc")
		filter.mustOccurAtLineLeadingWhitespace = false

		system.responses = [
			.componentTextRange(.leadingWhitespace, 4, NSRange(0..<0)),
			.applyLeadingWhitespace("\t", NSRange(0..<0)),
		]

		let output = try #require(try filter.processMutation(NSRange(4..<4), string: "abc", in: system))
		
		#expect(output == MutationOutput(selection: NSRange(8..<8), delta: 4))
		#expect(system.string == "\tdef abc")
	}
	
	@Test func matchingWithoutWhitespacePrefix() throws {
		let system = MockSystem(string: "def")
		var filter = NewLineLeadingWhitespaceFilter<MockSystem>(string: "abc")
		
		system.responses = [
			.componentTextRange(.leadingWhitespace, 3, NSRange(0..<0)),
			.applyLeadingWhitespace("\t", NSRange(0..<0)),
		]

		let output = try #require(try filter.processMutation(NSRange(3..<3), string: "abc", in: system))
		
		#expect(output == MutationOutput(selection: NSRange(6..<6), delta: 3))
		#expect(system.string == "defabc")
	}
	
	@Test func matchingWithDifferentIndentation() throws {
		let system = MockSystem(string: " ")
		var filter = NewLineLeadingWhitespaceFilter<MockSystem>(string: "abc")

		system.responses = [
			.componentTextRange(.leadingWhitespace, 1, NSRange(0..<1)),
			.applyLeadingWhitespace("\t", NSRange(0..<1)),
		]
		
		let output = try #require(try filter.processMutation(NSRange(1..<1), string: "abc", in: system))
		
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: 3))
		#expect(system.string == "\tabc")
	}
	
	@Test func matchingWithSameIndentation() throws {
		let system = MockSystem(string: "\t")
		var filter = NewLineLeadingWhitespaceFilter<MockSystem>(string: "abc")

		system.responses = [
			.componentTextRange(.leadingWhitespace, 1, NSRange(0..<1)),
			.applyLeadingWhitespace("\t", NSRange(0..<1)),
		]
		
		let output = try #require(try filter.processMutation(NSRange(1..<1), string: "abc", in: system))
		
		#expect(output == MutationOutput(selection: NSRange(4..<4), delta: 3))
		#expect(system.string == "\tabc")
	}
}
