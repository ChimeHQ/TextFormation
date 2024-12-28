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

final class MockSystem: TextSystem {
	typealias TextRange = NSRange
	typealias TextPosition = Int

	enum Response: Hashable {
		case applyTrailingWhitespace(String, TextRange)
		case applyLeadingWhitespace(String, TextRange)
	}

	let content: NSMutableString
	var responses: [Response] = []

	init(string: String) {
		self.content = NSMutableString(string: string)
	}

	var string: String {
		content as String
	}

	func offset(from: Int, to toPosition: Int) -> Int {
		toPosition - from
	}

	func positions(composing range: NSRange) -> (Int, Int) {
		(range.lowerBound, range.upperBound)
	}

	func position(from start: Int, offset: Int) -> Int? {
		start + offset
	}

	func textRange(from start: Int, to end: Int) -> NSRange? {
		NSRange(start..<end)
	}

	func substring(in range: NSRange) -> String? {
		content.substring(with: range)
	}

	func applyMutation(_ range: NSRange, string: String) -> TextFormation.MutationOutput<NSRange>? {
		content.replaceCharacters(in: range, with: string)

		let length = string.utf16.count
		let selection = NSRange(location: range.location + length, length: 0)

		return .init(selection: selection, delta: length - range.length)
	}

	func applyTrailingWhitespace(for position: Int) -> TextFormation.MutationOutput<NSRange>? {
		switch responses.removeFirst() {
		case let .applyTrailingWhitespace(value, range):
			return applyMutation(range, string: value)
		default:
			fatalError()
		}
	}

	func applyLeadingWhitespace(for position: Int) -> TextFormation.MutationOutput<NSRange>? {
		switch responses.removeFirst() {
		case let .applyLeadingWhitespace(value, range):
			return applyMutation(range, string: value)
		default:
			fatalError()
		}

	}

}

struct NewNewlineProcessingFilterTests {
	@Test func matchingAfter() throws {
		let system = MockSystem(string: "")
		let filter = NewNewlineProcessingFilter()

		system.responses = [
			.applyLeadingWhitespace("aaa", NSRange(0..<0)),
			.applyTrailingWhitespace("bbb", NSRange(4..<4)),
		]

		let output = try #require(filter.processMutation(NSRange(0..<0), string: "\n", in: system))

		#expect(output == MutationOutput(selection: NSRange(7..<7), delta: 7))
		#expect(system.string == "aaa\nbbb")
	}
}
