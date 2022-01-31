import XCTest
import TextStory
@testable import TextFormation

class LineIndentationFilterTests: XCTestCase {
    func testMatching() {
        let storage = StringStorage()
        let filter = LineIndentationFilter(string: "abc", provider: { _ in
            return .success("\t")
        })

        let mutation = TextMutation(insert: "abc", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(mutation, in: storage), .discard)

        XCTAssertEqual(storage.string, "\tabc")
    }

    func testMatchingWithDifferentIndentation() {
        let storage = StringStorage(" ")
        let filter = LineIndentationFilter(string: "abc", provider: { _ in
            return .success("\t")
        })

        let mutation = TextMutation(insert: "abc", at: 1, limit: 1)

        XCTAssertEqual(filter.processMutation(mutation, in: storage), .discard)

        XCTAssertEqual(storage.string, "\tabc")
    }

    func testMatchingWithSame() {
        let storage = StringStorage("\t")
        let filter = LineIndentationFilter(string: "\n", provider: { _ in
            return .success("\t")
        })

        let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

        XCTAssertEqual(filter.processMutation(mutation, in: storage), .discard)

        XCTAssertEqual(storage.string, "\t\n")
    }
}
