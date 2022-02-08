import XCTest
import TextStory
@testable import TextFormation

class DeleteCloseFilterTests: XCTestCase {
    func testDeleteOpenWithMatchingClose() {
        let filter = DeleteCloseFilter(open: "{", close: "}")
        let interface = TestableTextInterface("{}")

        interface.selectedRange = NSRange(0..<1)

        let mutation = TextMutation(delete: interface.selectedRange, limit: 2)

        XCTAssertEqual(interface.runFilter(filter, on: mutation), .stop)

        XCTAssertEqual(interface.string, "")
        XCTAssertEqual(interface.selectedRange, NSRange(0..<0))
    }

    func testDeleteOpenWithMatchingCloseWithPrefixAndSuffix() {
        let filter = DeleteCloseFilter(open: "{", close: "}")
        let interface = TestableTextInterface("ll{}tt")

        interface.selectedRange = NSRange(2..<3)

        let mutation = TextMutation(delete: interface.selectedRange, limit: 6)

        XCTAssertEqual(interface.runFilter(filter, on: mutation), .stop)

        XCTAssertEqual(interface.string, "lltt")
        XCTAssertEqual(interface.selectedRange, NSRange(2..<2))
    }

    func testDeleteOpenWithoutMatchingClose() {
        let filter = DeleteCloseFilter(open: "{", close: "}")
        let interface = TestableTextInterface("ll{ }tt")

        interface.selectedRange = NSRange(2..<3)

        let mutation = TextMutation(delete: interface.selectedRange, limit: 7)

        XCTAssertEqual(interface.runFilter(filter, on: mutation), .none)

        XCTAssertEqual(interface.string, "ll }tt")
        XCTAssertEqual(interface.selectedRange, NSRange(2..<2))
    }

}
