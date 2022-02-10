import XCTest
import TextStory
@testable import TextFormation

class LineLeadingWhitespaceFilterTests: XCTestCase {
    func testMatching() {
        let interface = TestableTextInterface()
        let filter = LineLeadingWhitespaceFilter(string: "abc", leadingWhitespaceProvider: { _, _ in
            return "\t"
        })

        let mutation = TextMutation(insert: "abc", at: 0, limit: 0)

        XCTAssertEqual(filter.processMutation(mutation, in: interface), .discard)

        XCTAssertEqual(interface.string, "\tabc")
    }

    func testMatchingWithMoreInPrefix() {
        let interface = TestableTextInterface("def ")
        let filter = LineLeadingWhitespaceFilter(string: "abc", leadingWhitespaceProvider: { _, _ in
            return "\t"
        })
        filter.mustHaveWhitespacePrefix = false

        let mutation = TextMutation(insert: "abc", at: 4, limit: 4)

        XCTAssertEqual(filter.processMutation(mutation, in: interface), .discard)

        XCTAssertEqual(interface.string, "\tdef abc")
    }

    func testMatchingWithDifferentIndentation() {
        let interface = TestableTextInterface(" ")
        let filter = LineLeadingWhitespaceFilter(string: "abc", leadingWhitespaceProvider: { _, _ in
            return "\t"
        })

        let mutation = TextMutation(insert: "abc", at: 1, limit: 1)

        XCTAssertEqual(filter.processMutation(mutation, in: interface), .discard)

        XCTAssertEqual(interface.string, "\tabc")
    }

    func testMatchingWithSame() {
        let interface = TestableTextInterface("\t")
        let filter = LineLeadingWhitespaceFilter(string: "\n", leadingWhitespaceProvider: { _, _ in
            return "\t"
        })

        let mutation = TextMutation(insert: "\n", at: 1, limit: 1)

        XCTAssertEqual(filter.processMutation(mutation, in: interface), .discard)

        XCTAssertEqual(interface.string, "\t\n")
    }
}
