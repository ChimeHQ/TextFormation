import XCTest
import TextStory
@testable import TextFormation

class NewlineProcessingFilterTests: XCTestCase {
    func testMatchingAfter() {
        let storage = StringStorage()
        let providers = WhitespaceProviders(leadingWhitespace: { _, _ in return "lll" },
                                            trailingWhitespace: {  _, _ in return "ttt"})
        let filter = NewlineProcessingFilter(whitespaceProviders: providers)

        let mutation = TextMutation(insert: "\n", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(mutation, in: storage), .discard)

        XCTAssertEqual(storage.string, "\nlll")
    }

    func testMatchingWithTrailingWhitespace() {
        let storage = StringStorage(" ")
        let providers = WhitespaceProviders(leadingWhitespace: {  _, _ in return "lll" },
                                            trailingWhitespace: {  _, _ in return "ttt"})
        let filter = NewlineProcessingFilter(whitespaceProviders: providers)

        let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

        XCTAssertEqual(filter.processMutation(mutation, in: storage), .discard)

        XCTAssertEqual(storage.string, "ttt\nlll")
    }

    func testMatchingWithTrailingTab() {
        let storage = StringStorage("abc\t")
        let providers = WhitespaceProviders(leadingWhitespace: {  _, _ in return "lll" },
                                            trailingWhitespace: {  _, _ in return "ttt"})
        let filter = NewlineProcessingFilter(whitespaceProviders: providers)

        let mutation = TextMutation(insert: "\n", at: 4, limit: 4)

        XCTAssertEqual(filter.processMutation(mutation, in: storage), .discard)

        XCTAssertEqual(storage.string, "abcttt\nlll")
    }
}
