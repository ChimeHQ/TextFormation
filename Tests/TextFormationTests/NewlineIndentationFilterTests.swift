import XCTest
import TextStory
@testable import TextFormation

class NewlineIndentationFilterTests: XCTestCase {
    func testMatchingAfter() {
        let storage = StringStorage()
        let filter = NewlineIndentationFilter(provider: { _ in
            return .success("\t")
        })

        let mutation = TextMutation(insert: "\n", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(mutation, in: storage), .discard)

        XCTAssertEqual(storage.string, "\n\t")
    }

    func testMatchingAfterWithDifferentIndentation() {
        let storage = StringStorage(" ")
        let filter = NewlineIndentationFilter(provider: { _ in
            return .success("\t")
        })

        let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

        XCTAssertEqual(filter.processMutation(mutation, in: storage), .discard)

        XCTAssertEqual(storage.string, " \n\t")
    }

    func testMatchingAfterWithSame() {
        let storage = StringStorage("\t")
        let filter = NewlineIndentationFilter(provider: { _ in
            return .success("\t")
        })

        let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

        XCTAssertEqual(filter.processMutation(mutation, in: storage), .discard)

        XCTAssertEqual(storage.string, "\t\n\t")
    }

}
