import XCTest
import TextStory
@testable import TextFormation

class StandardOpenPairFilterTests: XCTestCase {
    func testMatchOpen() {
        let filter = StandardOpenPairFilter(open: "{", close: "}")
        let interface = TestableTextInterface()

        let openMutation = TextMutation(insert: "{", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .none)

        let nextMutation = TextMutation(insert: "a", at: 1, limit: 1)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .none)

        XCTAssertEqual(interface.string, "{a}")
        XCTAssertEqual(interface.insertionLocation, 2)
    }

    func testSkipCloseAfterMatchingOpen() {
        let filter = StandardOpenPairFilter(open: "{", close: "}")
        let interface = TestableTextInterface()

        let openMutation = TextMutation(insert: "{", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .none)

        let nextMutation = TextMutation(insert: "a", at: 1, limit: 1)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .none)

        XCTAssertEqual(interface.string, "{a}")

        let closeMutation = TextMutation(insert: "}", at: 2, limit: 2)
        XCTAssertEqual(interface.runFilter(filter, on: closeMutation), .none)
        
        XCTAssertEqual(interface.string, "{a}")
        XCTAssertEqual(interface.insertionLocation, 3)
    }

    func testApplyWhitespaceOnClose() {
        let providers = WhitespaceProviders(leadingWhitespace: { _, _ in return "lll" },
                                            trailingWhitespace: {  _, _ in return "ttt"})
        let filter = StandardOpenPairFilter(open: "{", close: "}", whitespaceProviders: providers)
        let interface = TestableTextInterface()

        let openMutation = TextMutation(insert: "}", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .discard)

        XCTAssertEqual(interface.string, "lll}")
        XCTAssertEqual(interface.insertionLocation, 4)
    }

    func testSurroundRange() {
        let filter = StandardOpenPairFilter(open: "{", close: "}")
        let interface = TestableTextInterface("abc")

        interface.selectedRange = NSRange(0..<3)

        let openMutation = TextMutation(string: "{", range: interface.selectedRange, limit: 3)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .discard)

        XCTAssertEqual(interface.string, "{abc}")
        XCTAssertEqual(interface.selectedRange, NSRange(1..<4))

        interface.selectedRange = NSRange(1..<1)

        // now, make sure we don't do anything with that open
        let nextMutation = TextMutation(insert: "z", at: 1, limit: 1)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .none)

        XCTAssertEqual(interface.string, "{zabc}")
        XCTAssertEqual(interface.insertionLocation, 2)
    }

    func testSkipClose() {
        let filter = StandardOpenPairFilter(open: "{", close: "}")
        let interface = TestableTextInterface("}")

        let openMutation = TextMutation(insert: "}", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .none)

        XCTAssertEqual(interface.string, "}")
        XCTAssertEqual(interface.insertionLocation, 1)
    }

    func testDoubleOpen() {
        let filter = StandardOpenPairFilter(open: "{", close: "}")
        let interface = TestableTextInterface()

        let openMutation = TextMutation(insert: "{", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: openMutation), .none)

        let doubleOpenMutation = TextMutation(insert: "{", at: 1, limit: 1)
        XCTAssertEqual(interface.runFilter(filter, on: doubleOpenMutation), .none)

        let nextMutation = TextMutation(insert: "a", at: 2, limit: 2)
        XCTAssertEqual(interface.runFilter(filter, on: nextMutation), .none)

        XCTAssertEqual(interface.string, "{{a}}")
        XCTAssertEqual(interface.insertionLocation, 3)
    }

    func testDoubleOpenDelete() {
        let filter = StandardOpenPairFilter(open: "{", close: "}")
        let interface = TestableTextInterface("{{}}")

        interface.insertionLocation = 2

        let firstDeleteMutation = TextMutation(delete: NSRange(1..<2), limit: 4)
        XCTAssertEqual(interface.runFilter(filter, on: firstDeleteMutation), .none)

        XCTAssertEqual(interface.insertionLocation, 1)

        let secondDeleteMutation = TextMutation(delete: NSRange(0..<1), limit: 4)
        XCTAssertEqual(interface.runFilter(filter, on: secondDeleteMutation), .none)

        XCTAssertEqual(interface.string, "")
        XCTAssertEqual(interface.insertionLocation, 0)
    }
}
