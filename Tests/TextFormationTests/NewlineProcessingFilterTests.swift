import XCTest
import TextStory
@testable import TextFormation

class NewlineProcessingFilterTests: XCTestCase {
    func testMatchingAfter() {
        let interface = TestableTextInterface()
        let providers = WhitespaceProviders(leadingWhitespace: { _, _ in return "lll" },
                                            trailingWhitespace: {  _, _ in return "ttt"})
        let filter = NewlineProcessingFilter(whitespaceProviders: providers)

        let mutation = TextMutation(insert: "\n", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(mutation, in: interface), .discard)

        XCTAssertEqual(interface.string, "\nlll")
        XCTAssertEqual(interface.insertionLocation, 4)
    }

    func testMatchingWithTrailingWhitespace() {
        let interface = TestableTextInterface(" ")
        let providers = WhitespaceProviders(leadingWhitespace: {  _, _ in return "lll" },
                                            trailingWhitespace: {  _, _ in return "ttt"})
        let filter = NewlineProcessingFilter(whitespaceProviders: providers)

        let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

        XCTAssertEqual(interface.insertionLocation, 1)
        XCTAssertEqual(filter.processMutation(mutation, in: interface), .discard)

        XCTAssertEqual(interface.string, "ttt\nlll")
        XCTAssertEqual(interface.insertionLocation, 7)
    }

    func testMatchingWithTrailingTab() {
        let interface = TestableTextInterface("abc\t")
        let providers = WhitespaceProviders(leadingWhitespace: {  _, _ in return "lll" },
                                            trailingWhitespace: {  _, _ in return "ttt"})
        let filter = NewlineProcessingFilter(whitespaceProviders: providers)

        let mutation = TextMutation(insert: "\n", at: 4, limit: 4)

        XCTAssertEqual(filter.processMutation(mutation, in: interface), .discard)

        XCTAssertEqual(interface.string, "abcttt\nlll")
        XCTAssertEqual(interface.insertionLocation, 10)
    }
}
