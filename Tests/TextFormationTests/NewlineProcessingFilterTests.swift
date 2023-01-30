import XCTest
import TextStory
@testable import TextFormation

class NewlineProcessingFilterTests: XCTestCase {
    func testMatchingAfter() {
        let interface = TestableTextInterface()
        let providers = WhitespaceProviders(leadingWhitespace: { _, _ in "\t" },
                                            trailingWhitespace: {  _, _ in " "})
        let filter = NewlineProcessingFilter(whitespaceProviders: providers)

        let mutation = TextMutation(insert: "\n", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(mutation, in: interface), .discard)

        XCTAssertEqual(interface.string, "\n\t")
        XCTAssertEqual(interface.insertionLocation, 2)
    }

    func testMatchingWithTrailingWhitespace() {
        let interface = TestableTextInterface("a")
        let providers = WhitespaceProviders(leadingWhitespace: {  _, _ in "\t" },
                                            trailingWhitespace: {  _, _ in " "})
        let filter = NewlineProcessingFilter(whitespaceProviders: providers)

        let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

        XCTAssertEqual(interface.insertionLocation, 1)
        XCTAssertEqual(filter.processMutation(mutation, in: interface), .discard)

        XCTAssertEqual(interface.string, "a \n\t")
        XCTAssertEqual(interface.insertionLocation, 4)
    }

	func testMatchingAfterWhitespaceOnlyLine() {
		let interface = TestableTextInterface("\t")
		let providers = WhitespaceProviders(leadingWhitespace: {  _, _ in "\t" },
											trailingWhitespace: {  _, _ in " "})
		let filter = NewlineProcessingFilter(whitespaceProviders: providers)

		let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

		XCTAssertEqual(interface.insertionLocation, 1)
		XCTAssertEqual(filter.processMutation(mutation, in: interface), .discard)

		XCTAssertEqual(interface.string, "\t\n\t")
		XCTAssertEqual(interface.insertionLocation, 3)
	}

    func testMatchingWithCharactersAndTrailingTab() {
        let interface = TestableTextInterface("abc\t")
        let providers = WhitespaceProviders(leadingWhitespace: {  _, _ in return "\t" },
                                            trailingWhitespace: {  _, _ in return " "})
        let filter = NewlineProcessingFilter(whitespaceProviders: providers)

        let mutation = TextMutation(insert: "\n", at: 4, limit: 4)

        XCTAssertEqual(filter.processMutation(mutation, in: interface), .discard)

        XCTAssertEqual(interface.string, "abc \n\t")
        XCTAssertEqual(interface.insertionLocation, 6)
    }

	func testNewlineAfterLeadingOnlyLine() {
		let interface = TestableTextInterface("\t\n\t")
		let providers = WhitespaceProviders(leadingWhitespace: {  _, _ in "\t" },
											trailingWhitespace: {  _, _ in " "})
		let filter = NewlineProcessingFilter(whitespaceProviders: providers)

		let mutation = TextMutation(insert: "\n", at: 3, limit: 3)

		XCTAssertEqual(filter.processMutation(mutation, in: interface), .discard)

		XCTAssertEqual(interface.string, "\t\n\t\n\t")
		XCTAssertEqual(interface.insertionLocation, 5)
	}
}
