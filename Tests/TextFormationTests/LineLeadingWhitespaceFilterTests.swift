import XCTest
import TextStory
@testable import TextFormation

final class LineLeadingWhitespaceFilterTests: XCTestCase {
	private static let providers = WhitespaceProviders(leadingWhitespace: { _, _ in "\t" }, trailingWhitespace: WhitespaceProviders.passthroughProvider)

    func testMatching() {
        let interface = TestableTextInterface()
        let filter = LineLeadingWhitespaceFilter(string: "abc")

        let mutation = TextMutation(insert: "abc", at: 0, limit: 0)

		XCTAssertEqual(interface.runFilter(filter, on: mutation, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "\tabc")
    }

    func testMatchingOneCharacterAtATime() {
        let interface = TestableTextInterface("  ")
        let filter = LineLeadingWhitespaceFilter(string: "abc")

		XCTAssertEqual(interface.runFilter(filter, on: TextMutation(insert: "a", at: 2, limit: 2), with: Self.providers), .none)
        XCTAssertEqual(interface.runFilter(filter, on: TextMutation(insert: "b", at: 3, limit: 3), with: Self.providers), .none)
        XCTAssertEqual(interface.runFilter(filter, on: TextMutation(insert: "c", at: 4, limit: 4), with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "\tabc")
    }

    func testMatchingWithWhitespacePrefix() {
        let interface = TestableTextInterface("def ")
        let filter = LineLeadingWhitespaceFilter(string: "abc")
        filter.mustOccurAtLineLeadingWhitespace = false

        let mutation = TextMutation(insert: "abc", at: 4, limit: 4)

        XCTAssertEqual(interface.runFilter(filter, on: mutation, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "\tdef abc")
    }

    func testMatchingWithoutWhitespacePrefix() {
        let interface = TestableTextInterface("def")
        let filter = LineLeadingWhitespaceFilter(string: "abc")

        let mutation = TextMutation(insert: "abc", at: 3, limit: 3)

        XCTAssertEqual(interface.runFilter(filter, on: mutation, with: Self.providers), .none)

        XCTAssertEqual(interface.string, "defabc")
    }


    func testMatchingWithDifferentIndentation() {
        let interface = TestableTextInterface(" ")
        let filter = LineLeadingWhitespaceFilter(string: "abc")

        let mutation = TextMutation(insert: "abc", at: 1, limit: 1)

        XCTAssertEqual(interface.runFilter(filter, on: mutation, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "\tabc")
    }

    func testMatchingWithSame() {
        let interface = TestableTextInterface("\t")
        let filter = LineLeadingWhitespaceFilter(string: "\n")

        let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

        XCTAssertEqual(interface.runFilter(filter, on: mutation, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "\t\n")
    }
}
