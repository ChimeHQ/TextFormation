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
		let filter = NewLineLeadingWhitespaceFilter(string: "abc")

		let output = try #require(try filter.processMutation(NSRange(0..<0), string: "abc", in: system))
		
		#expect(output == MutationOutput(selection: NSRange(1..<1), delta: 0))
		#expect(system.string == "\tabc")
	}
}
