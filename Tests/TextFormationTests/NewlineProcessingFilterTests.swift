import XCTest
import TextStory
@testable import TextFormation

@MainActor
final class NewlineProcessingFilterTests: XCTestCase {
	private static let providers = WhitespaceProviders(leadingWhitespace: { _, _ in "\t" },
													   trailingWhitespace: {  _, _ in " "})

    func testMatchingAfter() {
        let interface = TextInterfaceAdapter()
        let filter = NewlineProcessingFilter()

        let mutation = TextMutation(insert: "\n", at: 0, limit: 0)

		XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "\n\t")
        XCTAssertEqual(interface.insertionLocation, 2)
    }

    func testMatchingWithTrailingWhitespace() {
        let interface = TextInterfaceAdapter("a")
        let filter = NewlineProcessingFilter()

        let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

        XCTAssertEqual(interface.insertionLocation, 1)
        XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "a \n\t")
        XCTAssertEqual(interface.insertionLocation, 4)
    }

	func testMatchingAfterWhitespaceOnlyLine() {
		let interface = TextInterfaceAdapter("\t")
		let filter = NewlineProcessingFilter()

		let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

		XCTAssertEqual(interface.insertionLocation, 1)
		XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

		XCTAssertEqual(interface.string, "\t\n\t")
		XCTAssertEqual(interface.insertionLocation, 3)
	}

    func testMatchingWithCharactersAndTrailingTab() {
        let interface = TextInterfaceAdapter("abc\t")
        let filter = NewlineProcessingFilter()

        let mutation = TextMutation(insert: "\n", at: 4, limit: 4)

        XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "abc \n\t")
        XCTAssertEqual(interface.insertionLocation, 6)
    }

	func testNewlineAfterLeadingOnlyLine() {
		let interface = TextInterfaceAdapter("\t\n\t")
		let filter = NewlineProcessingFilter()

		let mutation = TextMutation(insert: "\n", at: 3, limit: 3)

		XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

		XCTAssertEqual(interface.string, "\t\n\t\n\t")
		XCTAssertEqual(interface.insertionLocation, 5)
	}

    func testMatchingWithUnknownNewline() {
        let interface = TextInterfaceAdapter("")
        let filter = NewlineProcessingFilter(newline: "crlf")

        let mutation = TextMutation(insert: "crlf", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "crlf\t")
        XCTAssertEqual(interface.insertionLocation, 5)
    }

    func testMatchingWithUnknownNewlineAndTrailingWhitespace() {
        let interface = TextInterfaceAdapter(" ")
        let filter = NewlineProcessingFilter(newline: "crlf")

        let mutation = TextMutation(insert: "crlf", at: 1, limit: 1)

        XCTAssertEqual(interface.insertionLocation, 1)
        XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, " crlf\t")
        XCTAssertEqual(interface.insertionLocation, 6)
    }

    func testMatchingWithUnknownNewlineAndTrailingTab() {
        let interface = TextInterfaceAdapter("abc\t")
        let filter = NewlineProcessingFilter(newline: "crlf")

        let mutation = TextMutation(insert: "crlf", at: 4, limit: 4)

        XCTAssertEqual(filter.processMutation(mutation, in: interface, with: Self.providers), .discard)

        XCTAssertEqual(interface.string, "abc crlf\t")
        XCTAssertEqual(interface.insertionLocation, 9)
    }
}
