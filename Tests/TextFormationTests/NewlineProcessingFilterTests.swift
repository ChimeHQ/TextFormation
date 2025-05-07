import XCTest
import TextStory
@testable import TextFormation

final class NewlineProcessingFilterTests: XCTestCase {
	@MainActor
	private static let providers = WhitespaceProviders(leadingWhitespace: { _, _ in "\t" },
													   trailingWhitespace: {  _, _ in " "})

	@MainActor
    func testMatchingAfter() {
        let interface = TextInterfaceAdapter()
        let filter = NewlineProcessingFilter()

        let mutation = TextMutation(insert: "\n", at: 0, limit: 0)

		XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "\n\t")
        XCTAssertEqual(interface.insertionLocation, 2)
    }

	@MainActor
    func testMatchingWithTrailingWhitespace() {
        let interface = TextInterfaceAdapter("a")
        let filter = NewlineProcessingFilter()

        let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

        XCTAssertEqual(interface.insertionLocation, 1)
        XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "a \n\t")
        XCTAssertEqual(interface.insertionLocation, 4)
    }

	@MainActor
	func testMatchingAfterWhitespaceOnlyLine() {
		let interface = TextInterfaceAdapter("\t")
		let filter = NewlineProcessingFilter()

		let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

		XCTAssertEqual(interface.insertionLocation, 1)
		XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

		XCTAssertEqual(interface.string, "\t\n\t")
		XCTAssertEqual(interface.insertionLocation, 3)
	}

	@MainActor
    func testMatchingWithCharactersAndTrailingTab() {
        let interface = TextInterfaceAdapter("abc\t")
        let filter = NewlineProcessingFilter()

        let mutation = TextMutation(insert: "\n", at: 4, limit: 4)

        XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "abc \n\t")
        XCTAssertEqual(interface.insertionLocation, 6)
    }

	@MainActor
	func testNewlineAfterLeadingOnlyLine() {
		let interface = TextInterfaceAdapter("\t\n\t")
		let filter = NewlineProcessingFilter()

		let mutation = TextMutation(insert: "\n", at: 3, limit: 3)

		XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

		XCTAssertEqual(interface.string, "\t\n\t\n\t")
		XCTAssertEqual(interface.insertionLocation, 5)
	}

	@MainActor
    func testMatchingWithUnknownNewline() {
        let interface = TextInterfaceAdapter("")
        let filter = NewlineProcessingFilter(newline: "crlf")

        let mutation = TextMutation(insert: "crlf", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "crlf\t")
        XCTAssertEqual(interface.insertionLocation, 5)
    }

	@MainActor
    func testMatchingWithUnknownNewlineAndTrailingWhitespace() {
        let interface = TextInterfaceAdapter(" ")
        let filter = NewlineProcessingFilter(newline: "crlf")

        let mutation = TextMutation(insert: "crlf", at: 1, limit: 1)

        XCTAssertEqual(interface.insertionLocation, 1)
        XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, " crlf\t")
        XCTAssertEqual(interface.insertionLocation, 6)
    }

	@MainActor
    func testMatchingWithUnknownNewlineAndTrailingTab() {
        let interface = TextInterfaceAdapter("abc\t")
        let filter = NewlineProcessingFilter(newline: "crlf")

        let mutation = TextMutation(insert: "crlf", at: 4, limit: 4)

        XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "abc crlf\t")
        XCTAssertEqual(interface.insertionLocation, 9)
    }
}

import Testing

struct NewNewlineProcessingFilterTests {
	@Test func matchingAfterNothing() throws {
		let system = MockSystem(string: "")
		var filter = NewNewlineProcessingFilter<MockSystem>()

		system.responses = [
			.applyLeadingWhitespace("aaa", NSRange(1..<1)),
			.applyTrailingWhitespace("bbb", NSRange(0..<0)),
		]

		let output = try #require(try filter.processMutation(0..<0, "\n", system))

		#expect(output == MutationOutput(selection: NSRange(7..<7), delta: 7))
		#expect(system.string == "bbb\naaa")
	}
	
	@Test func matchingAfterNewline() throws {
		let system = MockSystem(string: "\n")
		var filter = NewNewlineProcessingFilter<MockSystem>()

		system.responses = [
			.applyLeadingWhitespace("aaa", NSRange(2..<2)),
			.applyTrailingWhitespace("bbb", NSRange(1..<1)),
		]

		let output = try #require(try filter.processMutation(1..<1, "\n", system))

		#expect(output == MutationOutput(selection: NSRange(8..<8), delta: 7))
		#expect(system.string == "\nbbb\naaa")
	}
}
