import XCTest
import TextStory
@testable import TextFormation

class ClosePairFilterTests: XCTestCase {
    func testMatching() {
        let filter = ClosePairFilter(open: " do |", close: "|")
        let storage = StringStorage()

        let openMutation = TextMutation(insert: " do |", at: 0, limit: 0)
        
        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .stop)
        storage.applyMutation(openMutation)

        let nextMutation = TextMutation(insert: "a", at: 5, limit: 5)
        XCTAssertEqual(filter.processMutation(nextMutation, in: storage), .stop)
        storage.applyMutation(nextMutation)

        XCTAssertEqual(storage.string, " do |a|")
    }

    func testCloseAfterMatching() {
        let filter = ClosePairFilter(open: " do |", close: "|")
        let storage = StringStorage()

        let openMutation = TextMutation(insert: " do |", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .stop)
        storage.applyMutation(openMutation)

        let nextMutation = TextMutation(insert: "|", at: 5, limit: 5)
        XCTAssertEqual(filter.processMutation(nextMutation, in: storage), .stop)
        storage.applyMutation(nextMutation)

        XCTAssertEqual(storage.string, " do ||")
    }

    func testDeleteAfterMatchingOpen() {
        let filter = ClosePairFilter(open: " do |", close: "|")
        let storage = StringStorage()

        let openMutation = TextMutation(insert: " do |", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .stop)
        storage.applyMutation(openMutation)

        let nextMutation = TextMutation(delete: NSRange(4..<5), limit: 5)
        XCTAssertEqual(filter.processMutation(nextMutation, in: storage), .none)
        storage.applyMutation(nextMutation)

        XCTAssertEqual(storage.string, " do ")
    }

    func testMatchWithOpenReplacement() {
        let filter = ClosePairFilter(open: "abc", close: "def")
        let storage = StringStorage("yz")

        let openMutation = TextMutation(string: "abc", range: NSRange(0..<1), limit: 1)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .stop)
        storage.applyMutation(openMutation)

        let nextMutation = TextMutation(insert: " ", at: 3, limit: 4)
        XCTAssertEqual(filter.processMutation(nextMutation, in: storage), .stop)
        storage.applyMutation(nextMutation)

        XCTAssertEqual(storage.string, "abc defz")
    }

    func testMatchWithCloseReplacement() {
        let filter = ClosePairFilter(open: "abc", close: "def")
        let storage = StringStorage("yz")

        let openMutation = TextMutation(string: "abc", range: NSRange(0..<1), limit: 1)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .stop)
        storage.applyMutation(openMutation)

        let nextMutation = TextMutation(string: " ", range: NSRange(3..<4), limit: 4)
        XCTAssertEqual(filter.processMutation(nextMutation, in: storage), .none)
        storage.applyMutation(nextMutation)

        XCTAssertEqual(storage.string, "abc ")
    }

    func testNewlineAfterMatch() {
        let filter = ClosePairFilter(open: "{", close: "}")
        let storage = StringStorage()

        let openMutation = TextMutation(insert: "{", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .stop)
        storage.applyMutation(openMutation)

        let nextMutation = TextMutation(insert: "\n", at: 1, limit: 1)
        XCTAssertEqual(filter.processMutation(nextMutation, in: storage), .stop)
        storage.applyMutation(nextMutation)

        XCTAssertEqual(storage.string, "{\n}")
    }

    func testIndentingNewlineAfterMatch() {
        let filter = ClosePairFilter(open: "{", close: "}", indenter: { _ in
            return .success("\t")
        })

        let storage = StringStorage()

        let openMutation = TextMutation(insert: "{", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .stop)
        storage.applyMutation(openMutation)

        let nextMutation = TextMutation(insert: "\n", at: 1, limit: 1)
        XCTAssertEqual(filter.processMutation(nextMutation, in: storage), .stop)
        storage.applyMutation(nextMutation)

        XCTAssertEqual(storage.string, "{\n\t\n}")
    }

    func testMatchingWithDoubleOpen() {
        let filter = ClosePairFilter(open: "(", close: ")")
        let storage = StringStorage()

        let openMutation = TextMutation(insert: "(", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .stop)
        storage.applyMutation(openMutation)

        let secondOpenMutation = TextMutation(insert: "(", at: 1, limit: 1)
        XCTAssertEqual(filter.processMutation(secondOpenMutation, in: storage), .stop)
        storage.applyMutation(secondOpenMutation)

        let nextMutation = TextMutation(insert: "a", at: 2, limit: 2)
        XCTAssertEqual(filter.processMutation(nextMutation, in: storage), .stop)
        storage.applyMutation(nextMutation)

        let unrelatedMutation = TextMutation(insert: "b", at: 3, limit: 3)
        XCTAssertEqual(filter.processMutation(unrelatedMutation, in: storage), .none)
        storage.applyMutation(unrelatedMutation)

        XCTAssertEqual(storage.string, "((ab))")
    }

    func testMatchingWithTripleOpen() {
        let filter = ClosePairFilter(open: "(", close: ")")
        let storage = StringStorage()

        let openMutation = TextMutation(insert: "(", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(openMutation, in: storage), .stop)
        storage.applyMutation(openMutation)

        let secondOpenMutation = TextMutation(insert: "(", at: 1, limit: 1)
        XCTAssertEqual(filter.processMutation(secondOpenMutation, in: storage), .stop)
        storage.applyMutation(secondOpenMutation)

        let thirdOpenMutation = TextMutation(insert: "(", at: 2, limit: 2)
        XCTAssertEqual(filter.processMutation(thirdOpenMutation, in: storage), .stop)
        storage.applyMutation(thirdOpenMutation)

        let nextMutation = TextMutation(insert: "a", at: 3, limit: 3)
        XCTAssertEqual(filter.processMutation(nextMutation, in: storage), .stop)
        storage.applyMutation(nextMutation)

        let unrelatedMutation = TextMutation(insert: "b", at: 4, limit: 4)
        XCTAssertEqual(filter.processMutation(unrelatedMutation, in: storage), .none)
        storage.applyMutation(unrelatedMutation)

        XCTAssertEqual(storage.string, "(((ab)))")
    }
}
