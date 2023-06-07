import XCTest
import TextStory
@testable import TextFormation

class NewlineWithinPairFilterTests: XCTestCase {
    func testMatch() {
        var leadingRequests: [(NSRange, String)] = []

        let leadingProvider = { (range: NSRange, interface: TextInterface) -> String in
            leadingRequests.append((range, interface.string))
            return "lll"
        }

        let providers = WhitespaceProviders(leadingWhitespace: leadingProvider,
                                            trailingWhitespace: {  _, _ in return "ttt"})

        let filter = NewlineWithinPairFilter(open: "abc", close: "def")
        let interface = TestableTextInterface("abcdef")

        let mutation = TextMutation(insert: "\n", at: 3, limit: 6)
		XCTAssertEqual(interface.runFilter(filter, on: mutation, with: providers), .discard)

        XCTAssertEqual(leadingRequests.count, 2)
        if leadingRequests.count != 2 {
            return
        }

        XCTAssertEqual(leadingRequests[0].0, NSRange(4..<4))
        XCTAssertEqual(leadingRequests[0].1, "abc\n\ndef")

        XCTAssertEqual(leadingRequests[1].0, NSRange(8..<8))
        XCTAssertEqual(leadingRequests[1].1, "abc\nlll\ndef")

        XCTAssertEqual(interface.string, "abc\nlll\nllldef")
        XCTAssertEqual(interface.selectedRange, NSRange(7..<7))
    }

    func testNoMatch() {
        let providers = WhitespaceProviders(leadingWhitespace: {  _, _ in return "lll"},
                                            trailingWhitespace: {  _, _ in return "ttt"})

        let filter = NewlineWithinPairFilter(open: "abc", close: "def")
        let interface = TestableTextInterface("abcdef")
        interface.insertionLocation = 2

        let mutation = TextMutation(insert: "\n", at: 2, limit: 6)
        XCTAssertEqual(interface.runFilter(filter, on: mutation, with: providers), .none)

        XCTAssertEqual(interface.string, "ab\ncdef")
        XCTAssertEqual(interface.insertionLocation, 3)
    }
}
