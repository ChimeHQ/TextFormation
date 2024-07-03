import XCTest
import TextStory
@testable import TextFormation

final class OpenPairReplacementFilterTests: XCTestCase {
	@MainActor
    func testMatch() {
        let filter = OpenPairReplacementFilter(open: "abc", close: "def")
        let interface = TextInterfaceAdapter(" ")

        let openMutation = TextMutation(string: "abc", range: NSRange(0..<1), limit: 1)

        XCTAssertEqual(filter.processMutation(openMutation, in: interface), .discard)
        XCTAssertEqual(interface.string, "abc def")
    }

	@MainActor
    func testInsertMatch() {
        let filter = OpenPairReplacementFilter(open: "abc", close: "def")
        let interface = TextInterfaceAdapter(" ")

        let openMutation = TextMutation(string: "abc", range: NSRange(0..<0), limit: 1)

        XCTAssertEqual(filter.processMutation(openMutation, in: interface), .none)
        XCTAssertEqual(interface.string, " ")
    }
}
