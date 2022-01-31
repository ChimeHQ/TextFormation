import XCTest
import TextStory
@testable import TextFormation

class StandardOpenPairFilterTests: XCTestCase {
    func testMatchOpen() {
        let filter = StandardOpenPairFilter(open: "{", close: "}")
        let storage = StringStorage()

        let openMutation = TextMutation(insert: "{", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .none)
        storage.applyMutation(openMutation)

        let nextMutation = TextMutation(insert: "a", at: 1, limit: 1)
        XCTAssertEqual(filter.processMutation(nextMutation, in: storage), .none)
        storage.applyMutation(nextMutation)

        XCTAssertEqual(storage.string, "{a}")
    }

    func testSkipCloseAfterMatchingOpen() {
        let filter = StandardOpenPairFilter(open: "{", close: "}")
        let storage = StringStorage()

        let openMutation = TextMutation(insert: "{", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .none)
        storage.applyMutation(openMutation)

        let nextMutation = TextMutation(insert: "a", at: 1, limit: 1)
        XCTAssertEqual(filter.processMutation(nextMutation, in: storage), .none)
        storage.applyMutation(nextMutation)

        let closeMutation = TextMutation(insert: "}", at: 2, limit: 2)
        XCTAssertEqual(filter.processMutation(closeMutation, in: storage), .none)
        storage.applyMutation(closeMutation)

        XCTAssertEqual(storage.string, "{a}")
    }

    func testSurroundRange() {
        let filter = StandardOpenPairFilter(open: "{", close: "}")
        let storage = StringStorage("abc")

        let openMutation = TextMutation(string: "{", range: NSRange(0..<3), limit: 3)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .discard)
        XCTAssertEqual(storage.string, "{abc}")

        // now, make sure we don't do anything with that open
        let nextMutation = TextMutation(insert: "z", at: 1, limit: 1)
        XCTAssertEqual(filter.processMutation(nextMutation, in: storage), .none)
        storage.applyMutation(nextMutation)

        XCTAssertEqual(storage.string, "{zabc}")
    }

    func testSkipClose() {
        let filter = StandardOpenPairFilter(open: "{", close: "}")
        let storage = StringStorage("}")

        let openMutation = TextMutation(insert: "}", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .none)
        storage.applyMutation(openMutation)
        XCTAssertEqual(storage.string, "}")
    }

    func testDoubleOpen() {
        let filter = StandardOpenPairFilter(open: "{", close: "}")
        let storage = StringStorage()

        let openMutation = TextMutation(insert: "{", at: 0, limit: 0)
        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .none)
        storage.applyMutation(openMutation)

        let doubleOpenMutation = TextMutation(insert: "{", at: 1, limit: 1)
        XCTAssertEqual(filter.processMutation(doubleOpenMutation, in: storage), .none)
        storage.applyMutation(doubleOpenMutation)

        let nextMutation = TextMutation(insert: "a", at: 2, limit: 2)
        XCTAssertEqual(filter.processMutation(nextMutation, in: storage), .none)
        storage.applyMutation(nextMutation)

        XCTAssertEqual(storage.string, "{{a}}")
    }
}
