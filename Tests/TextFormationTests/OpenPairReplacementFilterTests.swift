import XCTest
import TextStory
@testable import TextFormation

class OpenPairReplacementFilterTests: XCTestCase {
    func testMatch() {
        let filter = OpenPairReplacementFilter(open: "abc", close: "def")
        let storage = StringStorage(" ")

        let openMutation = TextMutation(string: "abc", range: NSRange(0..<1), limit: 1)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .discard)
        XCTAssertEqual(storage.string, "abc def")
    }

    func testInsertMatch() {
        let filter = OpenPairReplacementFilter(open: "abc", close: "def")
        let storage = StringStorage(" ")

        let openMutation = TextMutation(string: "abc", range: NSRange(0..<0), limit: 1)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .none)
        XCTAssertEqual(storage.string, " ")
    }
}
